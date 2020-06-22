#ifndef __MESSAGE_FACTORY_H__
#define __MESSAGE_FACTORY_H__

#include <google/protobuf/message.h>
#include <google/protobuf/arena.h>

namespace gpb = ::google::protobuf;


class MessageFactory
{
private:
  static class MessageFactory* instance;

private:
  MessageFactory() {}

public:
  /**
   * @brief Returns the singleton instance.
   *
   * @return MessageFactory object
  */
  static const MessageFactory* Instance();

  /**
   * @brief Creates a protobuf message using the message_type lookup mapping
   * defined by the factory
   *
   * @param message_type  String representation of a message type.  Must be the
   * same as the message name in its .proto definition.
   * @param arena         Optional google arena in which to create the message
   * @return              New protobuf message        
  */
  gpb::Message* CreateMessage(const char* message_type, gpb::Arena* arena = NULL) const;
};

#endif // __MESSAGE_FACTORY_H__
