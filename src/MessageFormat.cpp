#include "MessageFormat.h"
#include "MapValues.h"
#include "ScalarValues.h"
#include "RepeatedValues.h"
#include "TypeCheck.h"

// Due to its excessive and non-specific use of #define, 'k.h' must be included
// after all the protobuf headers to avoid conflicts.
#include <k.h>


namespace kx {
namespace protobufkdb {

// Singleton instance
MessageFormat* MessageFormat::instance = nullptr;

const MessageFormat* MessageFormat::Instance()
{
  if (instance == nullptr)
    instance = new MessageFormat();

  return instance;
}

K MessageFormat::GetMessage(const gpb::Message& msg, bool use_field_names) const
{
  // Message -> mixed list or dictionary
  //
  // Determine the number of fields from the message schema, create a mixed list
  // of that size and populate each list item. 
  const auto desc = msg.GetDescriptor();

  K field_values = ktn(0, desc->field_count());
  for (int i = 0; i < desc->field_count(); ++i)
    kK(field_values)[i] = GetMessageField(msg, desc->field(i), use_field_names);

  // If not using field names just return the field values mixed list
  if (!use_field_names)
    return field_values;

  // Create a symbol list containing the field names
  K field_names = ktn(KS, desc->field_count());
  for (int i = 0; i < desc->field_count(); ++i)
    kS(field_names)[i] = ss((S)desc->field(i)->name().c_str());

  // Return dictionary of field names to field values
  return xD(field_names, field_values);
}

K MessageFormat::GetMessageField(const gpb::Message& msg, const gpb::FieldDescriptor* fd, bool use_field_names) const
{
  // Field -> discriminated kdb type
  K element;
  const auto refl = msg.GetReflection();
  const auto oneof_desc = fd->containing_oneof();
  if (oneof_desc != nullptr && refl->GetOneofFieldDescriptor(msg, oneof_desc) != fd) {
    // Field is a oneof but not the active oneof - return empty mixed list.
    element = ktn(0, 0);
  }
  // Add the below functionality once proto3 presence and synthetic oneofs are
  // properly supported (as of protobuf v3.14.0 it's still experimental):
  // https://github.com/protocolbuffers/protobuf/blob/master/docs/implementing_proto3_presence.md
  /* else if (fd->is_singular_with_presence() && !refl->HasField(msg, fd)) {
    // Optional field hasn't been explicitly set so set kdb item to ::
    element = ka(101);
    element->g = 0;
  } */
  else if (fd->is_map()) {
    // Process maps as a special case to create a dictionary
    element = MapValues::Instance()->GetMap(msg, refl, fd, use_field_names);
  } else if (fd->is_repeated()) {
    if (fd->message_type() == nullptr) {
      // Repeated scalar
      element = RepeatedValues::Instance()->GetRepeated(msg, refl, fd);
    } else {
      // Repeated sub-message
      //
      // Determine the number of repeated sub-messages in this message and
      // create a mixed list of that size
      element = ktn(0, refl->FieldSize(msg, fd));
      for (auto i = 0; i < refl->FieldSize(msg, fd); ++i) {
        // Recurse into each sub-message to populate the list
        kK(element)[i] = GetMessage(refl->GetRepeatedMessage(msg, fd, i), use_field_names);
      }
      if (use_field_names) {
        // Parsing a repeated sub-message with field names will have created a
        // mixed list of dictionaries in 'element'.  In order to convert this to
        // a flip table, we first add a dummy :: value to the end of the mixed
        // list.
        K k_null = ka(101);
        k_null->g = 0;
        jk(&element, k_null);

        // Then strip the off trailing :: using the kdb parser.  This will copy
        // the the kdb structure, restructuring it as a flip table.  The old
        // version is r0-ed by kdb and the result used to update 'element' with
        // the new version.
        element = k(0, (S)"{[x] -1 _ x}", element, (K)0);
      }
    }
  } else if (fd->cpp_type() == gpb::FieldDescriptor::CPPTYPE_MESSAGE) {
    // Non-repeating sub-message
    //
    // Recurse into the single sub-message
    element = GetMessage(refl->GetMessage(msg, fd), use_field_names);
  } else {
    // Scalar value
    element = ScalarValues::Instance()->GetScalar(msg, refl, fd);
  }

  return element;
}

void MessageFormat::SetMessage(gpb::Message* msg, K k_msg, bool use_field_names) const
{
  if (use_field_names)
    SetMessageByFieldNames(msg, k_msg, use_field_names);
  else
    SetMessageByIndicies(msg, k_msg, use_field_names);
}

void MessageFormat::SetMessageByIndicies(gpb::Message* msg, K k_msg, bool use_field_names) const
{
  // Mixed list -> message
  const auto desc = msg->GetDescriptor();

  // Ignore entire message if set to ::
  if (k_msg->t == 101)
    return;

  if (desc->field_count() == 1 && k_msg->t != 0) {
    // This is a single field message where the kdb structure isn't a mixed
    // list.  We'll assume that q has removed the surrounding mixed list and
    // bypass the type checking below.  Though not ideal, such usage would be a
    // edge case caused by a strange and unsual proto schema.
    SetMessageField(msg, desc->field(0), k_msg, use_field_names);
  } else {
    // Check the the kdb structure is a mixed list and the list length is greater or equal than
    // number of fields in the schema.
    TYPE_CHECK_MESSAGE(k_msg->t != 0, desc->full_name(), 0, k_msg->t);
    TYPE_CHECK_FIELD_NUM(desc->field_count() > k_msg->n, desc->full_name(), desc->field_count(), k_msg->n);

    // Set each field using its mixed list item
    for (int i = 0; i < desc->field_count(); ++i) {
      const auto fd = desc->field(i);
      // Ignore fields which have been set to ::
      if (kK(k_msg)[i]->t != 101)
        SetMessageField(msg, fd, kK(k_msg)[i], use_field_names);
    }
  }
}

void MessageFormat::SetMessageByFieldNames(gpb::Message* msg, K k_msg, bool use_field_names) const
{
  // Dictionary -> message
  const auto desc = msg->GetDescriptor();

  // Ignore entire message if set to ::
  if (k_msg->t == 101)
    return;

  // Check the the kdb structure is a dictionary where the field_names are a symbol
  // list and the field_values are a mixed list
  TYPE_CHECK_MESSAGE(k_msg->t != 99, desc->full_name(), 99, k_msg->t);
  K field_names = kK(k_msg)[0];
  K field_values = kK(k_msg)[1];
  TYPE_CHECK_FIELD_NAMES(field_names->t != KS, desc->full_name(), KS, field_names->t);
  TYPE_CHECK_FIELD_VALUES(field_values->t != 0, desc->full_name(), 0, field_values->t);

  // Lookup each field using its name
  for (auto i = 0; i < field_names->n; ++i) {
    const std::string field_name = kS(field_names)[i];
    auto fd = desc->FindFieldByName(field_name);

    // Check that we found the field in the message, unless the corresponding
    // field value is set to ::
    TYPE_CHECK_UNKNOWN_FIELD(fd == nullptr && kK(field_values)[i]->t != 101, desc->full_name(), field_name);

    // Ignore fields which have been set to ::
    if (fd != nullptr && kK(field_values)[i]->t != 101)
      SetMessageField(msg, fd, kK(field_values)[i], use_field_names);
  }
}

void MessageFormat::SetMessageField(gpb::Message* msg, const gpb::FieldDescriptor* fd, K k_field, bool use_field_names) const
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
    MapValues::Instance()->SetMap(msg, refl, fd, k_field, use_field_names);
  } else if (fd->is_repeated()) {
    if (fd->message_type() == nullptr) {
      // Repeated scalar
      RepeatedValues::Instance()->SetRepeated(msg, refl, fd, k_field);
    } else {
      if (!use_field_names || k_field->t != 98) {
        // Repeated sub-message
        //
        // Check we have a mixed list containing the sub-messages
        TYPE_CHECK_REPEATED_MESSAGE(k_field->t != 0, fd->full_name(), 0, k_field->t);

        // Iterate the mixed list, recursively populating each sub-message
        for (auto i = 0; i < k_field->n; ++i) {
          // Ignore any submessages set to ::
          if (kK(k_field)[i]->t != 101)
            SetMessage(refl->AddMessage(msg, fd), kK(k_field)[i], use_field_names);
        }
      } else {
        // Repeated sub-message with field names which has been structured as a flip table.
        K flip_values = kK(k_field->k)[1];
        auto flip_length = kK(flip_values)[0]->n;
        for (auto i = 0; i < flip_length; ++i) {
          // Use the kdb parser to slice the flip table, giving us a dictionary
          // for each repeated submessage.
          K dict = k(0, (S)"{[x;y] x[y]}", r1(k_field), kj(i), (K)0);
          SetMessage(refl->AddMessage(msg, fd), dict, use_field_names);

          // Free the temporary slice
          r0(dict);
        }
      }
    }
  } else if (fd->cpp_type() == gpb::FieldDescriptor::CPPTYPE_MESSAGE) {
    // Non-repeating sub-message
    //
    // Recursively populate the sub-message
    SetMessage(refl->MutableMessage(msg, fd), k_field, use_field_names);
  } else {
    // Scalar value
    ScalarValues::Instance()->SetScalar(msg, refl, fd, k_field);
  }
}

} // namespace protobufkdb
} // namespace kx
