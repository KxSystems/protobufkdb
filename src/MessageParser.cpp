#include <istream>
#include <ostream>
#include <fstream>
#include <memory>

#include "MessageParser.h"
#include "MessageFactory.h"
#include "MessageFormat.h"
#include "TypeCheck.h"


// Singleton instance
MessageParser* MessageParser::instance = nullptr;

const MessageParser* MessageParser::Instance()
{
  if (instance == nullptr)
    instance = new MessageParser();

  return instance;
}

K MessageParser::SerializeArray(const std::string& message_type, K k_msg) const
{
  // Create the intermediate message in a unique_ptr so we don't have to worry
  // about explicitly freeing it if there is an error
  std::unique_ptr<gpb::Message> msg(MessageFactory::Instance()->CreateMessage(message_type));
  if (!msg)
    return krr((S)"Invalid message type");

  static char error_msg[1024];
  try {
    MessageFormat::Instance()->SetMessage(msg.get(), k_msg);
    *error_msg = '\0';
  } catch (TypeCheck& e) {
    strncpy(error_msg, e.what(), sizeof(error_msg));
    return krr(error_msg);
  }

  std::string serialized;
  if (!msg->SerializeToString(&serialized))
    return krr((S)"Failed to serialize message");

  return kpn((S)serialized.c_str(), serialized.length());
}

K MessageParser::SerializeArrayArena(const std::string& message_type, K k_msg) const
{
  gpb::Arena arena;

  // There is no need to explicitly free msg since it is allocated on the above
  // arena.  It will be cleaned up when the arena falls out of scope at the end
  // of the function.
  gpb::Message* msg = MessageFactory::Instance()->CreateMessage(message_type, &arena);
  if (msg == NULL)
    return krr((S)"Invalid message type");

  static char error_msg[1024];
  try {
    MessageFormat::Instance()->SetMessage(msg, k_msg);
    *error_msg = '\0';
  } catch (TypeCheck& e) {
    strncpy(error_msg, e.what(), sizeof(error_msg));
    return krr(error_msg);
  }

  std::string serialized;
  if (!msg->SerializeToString(&serialized))
    return krr((S)"Failed to serialize message");

  return kpn((S)serialized.c_str(), serialized.length());
}

K MessageParser::ParseArray(const std::string& message_type, K char_array) const
{
  // Create the intermediate message in a unique_ptr so we don't have to worry
  // about explicitly freeing it if there is an error
  std::unique_ptr<gpb::Message> msg(MessageFactory::Instance()->CreateMessage(message_type));
  if (!msg)
    return krr((S)"Invalid message type");

  if (!msg->ParseFromArray(kC(char_array), char_array->n))
    return krr((S)"Failed to parse serialized message");

  return MessageFormat::Instance()->GetMessage(*msg);
}

K MessageParser::ParseArrayArena(const std::string& message_type, K char_array) const
{
  gpb::Arena arena;

  // There is no need to explicitly free msg since it is allocated on the above
  // arena.  It will be cleaned up when the arena falls out of scope at the end
  // of the function.
  gpb::Message* msg = MessageFactory::Instance()->CreateMessage(message_type, &arena);
  if (msg == NULL)
    return krr((S)"Invalid message type");

  if (!msg->ParseFromArray(kC(char_array), char_array->n))
    return krr((S)"Failed to parse serialized message");

  return MessageFormat::Instance()->GetMessage(*msg);
}

K MessageParser::SaveMessage(const std::string& message_type, const std::string& filename, K k_msg) const
{
  // Create the intermediate message in a unique_ptr so we don't have to worry
  // about explicitly freeing it if there is an error
  std::unique_ptr<gpb::Message> msg(MessageFactory::Instance()->CreateMessage(message_type));
  if (!msg)
    return krr((S)"Invalid message type");

  std::ofstream file_out;
  file_out.open(filename, std::ios_base::out | std::ios_base::binary);
  if (!file_out.is_open())
    return krr((S)"Cannot open file");

  static char error_msg[1024];
  try {
    MessageFormat::Instance()->SetMessage(msg.get(), k_msg);
    *error_msg = '\0';
  } catch (TypeCheck& e) {
    strncpy(error_msg, e.what(), sizeof(error_msg));
    return krr(error_msg);
  }

  if (!msg->SerializeToOstream(&file_out))
    return krr((S)"Failed to serialize message");

  return (K)0;
}

K MessageParser::LoadMessage(const std::string& message_type, const std::string& filename) const
{
  // Create the intermediate message in a unique_ptr so we don't have to worry
  // about explicitly freeing it if there is an error
  std::unique_ptr<gpb::Message> msg(MessageFactory::Instance()->CreateMessage(message_type));
  if (!msg)
    return krr((S)"Invalid message type");

  std::ifstream file_in;
  file_in.open(filename, std::ios_base::in | std::ios_base::binary);
  if (!file_in.is_open())
    return krr((S)"Cannot open file");

  if (!msg->ParseFromIstream(&file_in))
    return krr((S)"Failed to parse serialized message");

  return MessageFormat::Instance()->GetMessage(*msg);
}
