#include "MessageFactory.h"


// Singleton instance
MessageFactory* MessageFactory::instance = nullptr;

const MessageFactory* MessageFactory::Instance()
{
  if (instance == nullptr)
    instance = new MessageFactory();

  return instance;
}

gpb::Message* MessageFactory::CreateMessage(const char* message_type, gpb::Arena* arena) const
{
  auto iter = message_lookup.find(message_type);
  if (iter == message_lookup.end())
    return NULL;
  return iter->second->New(arena);
}

