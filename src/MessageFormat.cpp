#include "MessageFormat.h"
#include "MapValues.h"
#include "ScalarValues.h"
#include "RepeatedValues.h"
#include "TypeCheck.h"

// Due to its excessive and non-specific use of #define, 'k.h' must be included
// after all the protobuf headers to avoid conflicts.
#include <k.h>


// Singleton instance
MessageFormat* MessageFormat::instance = nullptr;

const MessageFormat* MessageFormat::Instance()
{
  if (instance == nullptr)
    instance = new MessageFormat();

  return instance;
}

K MessageFormat::GetMessage(const gpb::Message& msg) const
{
  // Message -> mixed list
  //
  // Determine the number of fields from the message schema, create a mixed list
  // of that size and populate each list item. 
  const auto desc = msg.GetDescriptor();

  K mixed_list = knk(desc->field_count());
  for (int i = 0; i < desc->field_count(); ++i)
    kK(mixed_list)[i] = GetMessageField(msg, desc->field(i));

  return mixed_list;
}

K MessageFormat::GetMessageField(const gpb::Message& msg, const gpb::FieldDescriptor* fd) const
{
  // Field -> discriminated kdb type
  K element;
  const auto refl = msg.GetReflection();
  const auto oneof_desc = fd->containing_oneof();
  if (oneof_desc != nullptr && refl->GetOneofFieldDescriptor(msg, oneof_desc) != fd) {
    // Field is a oneof but not the active oneof - return empty mixed list.
    element = knk(0);
  } else if (fd->is_map()) {
    // Process maps as a special case to create a dictionary
    element = MapValues::Instance()->GetMap(msg, refl, fd);
  } else if (fd->is_repeated()) {
    if (fd->message_type() == nullptr) {
      // Repeated scalar
      element = RepeatedValues::Instance()->GetRepeated(msg, refl, fd);
    } else {
      // Repeated sub-message
      //
      // Determine the number of repeated sub-messages in this message and
      // create a mixed list of that size
      element = knk(refl->FieldSize(msg, fd));
      for (auto i = 0; i < refl->FieldSize(msg, fd); ++i) {
        // Recurse into each sub-message to populate the list
        kK(element)[i] = GetMessage(refl->GetRepeatedMessage(msg, fd, i));
      }
    }
  } else if (fd->cpp_type() == gpb::FieldDescriptor::CPPTYPE_MESSAGE) {
    // Non-repeating sub-message
    //
    // Recurse into the single sub-message
    element = GetMessage(refl->GetMessage(msg, fd));
  } else {
    // Scalar value
    element = ScalarValues::Instance()->GetScalar(msg, refl, fd);
  }

  return element;
}

void MessageFormat::SetMessage(gpb::Message* msg, K k_msg) const
{
  // Mixed list -> message
  const auto desc = msg->GetDescriptor();

  if (desc->field_count() == 1 && k_msg->t != 0) {
    // This is a single field message where the kdb structure isn't a mixed
    // list.  We'll assume that q has removed the surrounding mixed list and
    // bypass the type checking below.  Though not ideal, such usage would be a
    // edge case caused by a strange and unsual proto schema.
    SetMessageField(msg, desc->field(0), k_msg);
  } else {
    // Check the the kdb structure is a mixed list and the list length equals the
    // number of fields in the schema.
    TYPE_CHECK_MESSAGE(k_msg->t != 0, desc->full_name(), 0, k_msg->t);
    TYPE_CHECK_FIELD_NUM(desc->field_count() != k_msg->n, desc->full_name(), desc->field_count(), k_msg->n);

    // Set each field using its mixed list item
    for (int i = 0; i < k_msg->n; ++i)
      SetMessageField(msg, desc->field(i), kK(k_msg)[i]);
  }
}


void MessageFormat::SetMessageField(gpb::Message* msg, const gpb::FieldDescriptor* fd, K k_field) const
{
  // Discriminated kdb type -> field
  const auto& refl = msg->GetReflection();
  const auto oneof_desc = fd->containing_oneof();
  if (oneof_desc != nullptr && k_field->t == 0 && k_field->n == 0) {
    // Field is a oneof but not the active oneof.  Do not set the field,
    // otherwise it would override the active oneof if it has already been
    // processed.
  } else if (fd->is_map()) {
    // Pull the map key-value pairs out of the dictionary
    MapValues::Instance()->SetMap(msg, refl, fd, k_field);
  } else if (fd->is_repeated()) {
    if (fd->message_type() == nullptr) {
      // Repeated scalar
      RepeatedValues::Instance()->SetRepeated(msg, refl, fd, k_field);
    } else {
      // Repeated sub-message
      //
      // Check we have a mixed list containing the sub-messages
      TYPE_CHECK_REPEATED_MESSAGE(k_field->t != 0, fd->full_name(), k_field->t);

      // Iterate the mixed list, recursively populating each sub-message
      for (auto i = 0; i < k_field->n; ++i)
        SetMessage(refl->AddMessage(msg, fd), kK(k_field)[i]);
    }
  } else if (fd->cpp_type() == gpb::FieldDescriptor::CPPTYPE_MESSAGE) {
    // Non-repeating sub-message
    //
    // Recursively populate the sub-message
    SetMessage(refl->MutableMessage(msg, fd), k_field);
  } else {
    // Scalar value
    ScalarValues::Instance()->SetScalar(msg, refl, fd, k_field);
  }
}
