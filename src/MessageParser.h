#ifndef __MESSAGE_PARSER_H__
#define __MESSAGE_PARSER_H__

#include <google/protobuf/message.h>
#include <google/protobuf/descriptor.h>
#include <google/protobuf/arena.h>

// Due to its excessive and non-specific use of #define, 'k.h' must be included
// after all the protobuf headers to avoid conflicts.
#include <k.h>

namespace gpb = ::google::protobuf;


class MessageParser
{
private:
  static class MessageParser* instance;

private:
  MessageParser() {};

public:
  /**
   * @brief Returns the singleton instance.
   *
   * @return MessageParser object
  */
  static const MessageParser* Instance();

  /**
   * @brief Converts the kdb object to a protobuf message then serializes that
   * into a char array.
   *
   * @param message_type  Name of the message type.  Must be present in the
   * MessageFactory since it needs to create a protobuf message object of the
   * correct type using MessageFactory::CreateMessage().
   * @param k_msg         Kdb object to be converted.  Its reference count
   * will be automatically decremented when control passes back to q.
   * @return              Kdb char array containing the serialized message
  */
  K SerializeArray(const char* message_type, K k_msg) const;

  /**
   * @brief Converts the kdb object to a protobuf message then serializes that
   * into a char array.  Uses a google arena to create the intermediate message.
   *
   * @param message_type  Name of the message type.  Must be present in the
   * MessageFactory since it needs to create a protobuf message object of the
   * correct type using MessageFactory::CreateMessage().
   * @param k_msg         Kdb object to be converted.  Its reference count will
   * be automatically decremented when control passes back to q.
   * @return              Kdb char array containing the serialized message
  */
  K SerializeArrayArena(const char* message_type, K k_msg) const;

  /**
   * @brief Parses the proto-serialized char array into a protobuf message then
   * converts that into the corresponding kdb object.
   *
   * @param message_type  Name of the message type.  Must be present in the
   * MessageFactory since it needs to create a protobuf message object of the
   * correct type using MessageFactory::CreateMessage().
   * @param char_array    Kdb char array containing the serialized protobuf
   * message.  Its reference count will be automatically decremented when
   * control passes back to q.
   * @return              Kdb object corresponding to the protobuf message
  */
  K ParseArray(const char* message_type, K char_array) const;

  /**
   * @brief Parses the proto-serialized char array into a protobuf message then
   * converts that into the corresponding kdb object.  Uses a google arena to
   * create the intermediate message.
   *
   * @param message_type  Name of the message type.  Must be present in the
   * MessageFactory since it needs to create a protobuf message object of the
   * correct type using MessageFactory::CreateMessage().
   * @param char_array    Kdb char array containing the serialized protobuf
   * message.  Its reference count will be automatically decremented when
   * control passes back to q.
   * @return              Kdb object corresponding to the protobuf message
  */
  K ParseArrayArena(const char* message_type, K char_array) const;

  /**
   * @brief Converts the kdb object to a protobuf message, serializes that
   * then writes the result to the specified file.
   *
   * @param message_type  Name of the message type.  Must be present in the
   * MessageFactory since it needs to create a protobuf message object of the
   * correct type using MessageFactory::CreateMessage().
   * @param filename      Name of the file to write to.
   * @param k_msg         Kdb object to be converted.  Its reference count
   * will be automatically decremented when control passes back to q.
   * @return              NULL
  */
  K SaveMessage(const char* message_type, const char* filename, K k_msg) const;

  /**
   * @brief Parses the proto-serialized stream from the file specified to a
   * protobuf message then converts that into the corresponding kdb object.
   *
   * @param message_type  Name of the message type.  Must be present in the
   * MessageFactory since it needs to create a protobuf message object of the
   * correct type using MessageFactory::CreateMessage().
   * @param filename      Name of the file to read from.
   * @return              Kdb object corresponding to the protobuf message
  */
  K LoadMessage(const char* message_type, const char* filename) const;
};

#endif // __MESSAGE_PARSER_H__
