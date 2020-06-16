#ifndef __MESSAGE_FORMAT_H__
#define __MESSAGE_FORMAT_H__

#include <google/protobuf/message.h>
#include <google/protobuf/descriptor.h>

// Due to its excessive and non-specific use of #define, 'k.h' must be included
// after all the protobuf headers to avoid conflicts.
#include <k.h>

namespace gpb = ::google::protobuf;


class MessageFormat
{
private:
  static class MessageFormat* instance;

private:
  MessageFormat() {}

  K GetMessageField(const gpb::Message& msg, const gpb::FieldDescriptor* fd) const;
  void SetMessageField(gpb::Message* msg, const gpb::FieldDescriptor* fd, K k_fd) const;

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
   * A protobuf message is represented in kdb as a mixed list, with one list
   * item for each field of the message.  To create a consistent mapping between
   * the proto schema and kdb structure, the fields are iterated in the order
   * they are declared in the message definition.
   *
   * @param msg Protobuf message to be converted
   * @return    Kdb mixed list of length equal to the number of message fields
   */
  K GetMessage(const gpb::Message& msg) const;

  /**
   * @brief Populates the protobuf message from a kdb structure.
   *
   * Iterates through the kdb mixed list, populating each field in the protobuf
   * message from the corresponding list item.  The schema must correspond to
   * that used by GetMessage(), in particular the length of the list must be
   * equal to the number of message fields and the list items must appear in the
   * order they are declared in the message definition, otherwise a TypeCheck
   * exception will be thrown.
   *
   * @param msg   Protobuf message to be populated
   * @param k_msg Kdb mixed list from which to populate the fields
   */
  void SetMessage(gpb::Message* msg, K k_msg) const;
};

#endif // __MESSAGE_FORMAT_H__
