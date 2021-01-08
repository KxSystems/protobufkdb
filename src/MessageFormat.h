#ifndef __MESSAGE_FORMAT_H__
#define __MESSAGE_FORMAT_H__

#include <google/protobuf/message.h>
#include <google/protobuf/descriptor.h>

// Due to its excessive and non-specific use of #define, 'k.h' must be included
// after all the protobuf headers to avoid conflicts.
#include <k.h>


namespace kx {
namespace protobufkdb {
namespace gpb = ::google::protobuf;

class MessageFormat
{
private:
  static class MessageFormat* instance;

private:
  MessageFormat()
  {}

  // Worker functions for SetMessage()
  void SetMessageByIndicies(gpb::Message* msg, K k_msg, bool use_field_names) const;
  void SetMessageByFieldNames(gpb::Message* msg, K k_msg, bool use_field_names) const;

  // Get and set message fields
  K GetMessageField(const gpb::Message& msg, const gpb::FieldDescriptor* fd, bool use_field_names) const;
  void SetMessageField(gpb::Message* msg, const gpb::FieldDescriptor* fd, K k_fd, bool use_field_names) const;

public:
  /**
   * @brief Returns the singleton instance.
   *
   * @return MessageFormat object
  */
  static const MessageFormat* Instance();

  /**
   * @brief Converts a protobuf message to kdb.
   *
   * By default, a protobuf message is represented in kdb as a mixed list, with
   * one list item for each field of the message.  To create a consistent
   * mapping between the proto schema and kdb structure, the fields are iterated
   * in the order they are declared in the message definition.
   *
   * When use_field_names is set a message is represented as a dictionary from
   * field name symbols to the mixed list of field values.
   *
   * @param msg             Protobuf message to be converted
   * @param use_field_names Flag indicating whether a message is represented as
   * a mixed list of field values or a dictionary from field name symbols to the
   * field values
   * @return                Kdb mixed list of length equal to the number of
   * message fields
   */
  K GetMessage(const gpb::Message& msg, bool use_field_names) const;

  /**
   * @brief Populates the protobuf message from a kdb structure.
   *
   * By default, iterates through the kdb mixed list, populating each field in
   * the protobuf message from the corresponding list item.  The schema must
   * correspond to that used by GetMessage(), in particular:
   *  - The length of the list must be equal or greater than the number of
   *    message fields (general nulls can be used at the end of the list to
   *    prevent q simplifying the mixed list)
   *  - The list items must appear in the order they are declared in the message
   *    definition
   *
   * General nulls within the mixed list can be used in two ways:
   *  1. Specifying :: for a field value prevents that field from being
   *     explicitly set.  This is equivalent to it being set to the field type's
   *     default value (0 for ints/floats, "" for string).
   *  2. Any additional general nulls at the end of the mixed list (greater than
   *     the number of fields in the message) are ignored.  This can be used to
   *     prevent q from changing the mixed list to a simpler type (for example
   *     where the message only contains scalar fields of the same type which q
   *     would other convert to a simple list).
   *
   * When use_field_names is set a message is represented as a dictionary from
   * field name symbols to the mixed list of field values.  In this case the
   * fields are looked up by name so the mixed list of field values do not have
   * be ordered as they are declared in the message definition.  Similar to the
   * above, if a field value is specified as :: then that field name/value pair
   * will be ignored.
   *
   * @param msg             Protobuf message to be populated
   * @param k_msg           Kdb mixed list from which to populate the fields
   * @param use_field_names Flag indicating whether a message is represented as
   * a mixed list of field values or a dictionary from field name symbols to the
   * field values
   */
  void SetMessage(gpb::Message* msg, K k_msg, bool use_field_names) const;
};

} // namespace protobufkdb
} // namespace kx


#endif // __MESSAGE_FORMAT_H__
