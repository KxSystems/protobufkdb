#include <google/protobuf/descriptor.h>
#include "MessageFactory.h"


// Singleton instance
MessageFactory* MessageFactory::instance = nullptr;

const MessageFactory* MessageFactory::Instance()
{
  if (instance == nullptr)
    instance = new MessageFactory();

  return instance;
}

gpb::Message* MessageFactory::CreateMessage(const std::string& message_type, gpb::Arena* arena) const
{
  auto msg_desc = gpb::DescriptorPool::generated_pool()->FindMessageTypeByName(message_type);
  if (msg_desc == nullptr)
    return NULL;
  else
    return gpb::MessageFactory::generated_factory()->GetPrototype(msg_desc)->New(arena);
}
