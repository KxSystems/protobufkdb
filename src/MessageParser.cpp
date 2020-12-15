#include <istream>
#include <ostream>
#include <fstream>
#include <memory>
#include <exception>

#include "MessageParser.h"
#include "MessageFactory.h"
#include "MessageFormat.h"
#include "TypeCheck.h"


namespace kx {
namespace protobufkdb {

// Wrappers for exception handling (both TypeCheck and those coming from
// libprotobuf), converting exception strings to krr error message
#define KDB_EXCEPTION_TRY       \
  static char error_msg[1024];  \
  try {
#define KDB_EXCEPTION_CATCH                           \
    *error_msg = '\0';                                \
  } catch (std::exception& e) {                       \
    strncpy(error_msg, e.what(), sizeof(error_msg));  \
    error_msg[sizeof(error_msg) - 1] = '\0';          \
    return krr(error_msg);                            \
  }

// Singleton instance
MessageParser* MessageParser::instance = nullptr;

const MessageParser* MessageParser::Instance()
{
  if (instance == nullptr)
    instance = new MessageParser();

  return instance;
}

K MessageParser::SerializeArray(const std::string& message_type, K k_msg, bool use_field_names) const
{
  // Create the intermediate message in a unique_ptr so we don't have to worry
  // about explicitly freeing it if there is an error
  std::unique_ptr<gpb::Message> msg(MessageFactory::Instance()->CreateMessage(message_type));
  if (!msg)
    return krr((S)"Invalid message type");

  std::string serialized;
  KDB_EXCEPTION_TRY;

  MessageFormat::Instance()->SetMessage(msg.get(), k_msg, use_field_names);

  if (!msg->SerializeToString(&serialized))
    return krr((S)"Failed to serialize message");

  KDB_EXCEPTION_CATCH;

  return kpn((S)serialized.c_str(), serialized.length());
}

K MessageParser::SerializeArrayArena(const std::string& message_type, K k_msg, bool use_field_names) const
{
  gpb::Arena arena;

  // There is no need to explicitly free msg since it is allocated on the above
  // arena.  It will be cleaned up when the arena falls out of scope at the end
  // of the function.
  gpb::Message* msg = MessageFactory::Instance()->CreateMessage(message_type, &arena);
  if (msg == NULL)
    return krr((S)"Invalid message type");

  std::string serialized;
  KDB_EXCEPTION_TRY;
  
  MessageFormat::Instance()->SetMessage(msg, k_msg, use_field_names);

  if (!msg->SerializeToString(&serialized))
    return krr((S)"Failed to serialize message");

  KDB_EXCEPTION_CATCH;

  return kpn((S)serialized.c_str(), serialized.length());
}

K MessageParser::ParseArray(const std::string& message_type, K char_array, bool use_field_names) const
{
  // Create the intermediate message in a unique_ptr so we don't have to worry
  // about explicitly freeing it if there is an error
  std::unique_ptr<gpb::Message> msg(MessageFactory::Instance()->CreateMessage(message_type));
  if (!msg)
    return krr((S)"Invalid message type");

  K result;
  KDB_EXCEPTION_TRY;

  if (!msg->ParseFromArray(kC(char_array), char_array->n))
    return krr((S)"Failed to parse serialized message");

  result = MessageFormat::Instance()->GetMessage(*msg, use_field_names);

  KDB_EXCEPTION_CATCH;

  return result;
}

K MessageParser::ParseArrayArena(const std::string& message_type, K char_array, bool use_field_names) const
{
  gpb::Arena arena;

  // There is no need to explicitly free msg since it is allocated on the above
  // arena.  It will be cleaned up when the arena falls out of scope at the end
  // of the function.
  gpb::Message* msg = MessageFactory::Instance()->CreateMessage(message_type, &arena);
  if (msg == NULL)
    return krr((S)"Invalid message type");

  K result;
  KDB_EXCEPTION_TRY;

  if (!msg->ParseFromArray(kC(char_array), char_array->n))
    return krr((S)"Failed to parse serialized message");

  result = MessageFormat::Instance()->GetMessage(*msg, use_field_names);

  KDB_EXCEPTION_CATCH;

  return result;
}

K MessageParser::ParseArrayDebug(const std::string& message_type, K char_array) const
{
  // Create the intermediate message in a unique_ptr so we don't have to worry
  // about explicitly freeing it if there is an error
  std::unique_ptr<gpb::Message> msg(MessageFactory::Instance()->CreateMessage(message_type));
  if (!msg)
    return krr((S)"Invalid message type");

  KDB_EXCEPTION_TRY;

  if (!msg->ParseFromArray(kC(char_array), char_array->n))
    return krr((S)"Failed to parse serialized message");

  KDB_EXCEPTION_CATCH;

  return kp((S)msg->DebugString().c_str());
}

K MessageParser::SaveMessage(const std::string& message_type, const std::string& filename, K k_msg, bool use_field_names) const
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

  KDB_EXCEPTION_TRY;

  MessageFormat::Instance()->SetMessage(msg.get(), k_msg, use_field_names);

  if (!msg->SerializeToOstream(&file_out))
    return krr((S)"Failed to serialize message");

  KDB_EXCEPTION_CATCH;

  return (K)0;
}

K MessageParser::LoadMessage(const std::string& message_type, const std::string& filename, bool use_field_names) const
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

  K result;
  KDB_EXCEPTION_TRY;

  if (!msg->ParseFromIstream(&file_in))
    return krr((S)"Failed to parse serialized message");

  result = MessageFormat::Instance()->GetMessage(*msg, use_field_names);

  KDB_EXCEPTION_CATCH;

  return result;
}

K MessageParser::LoadMessageDebug(const std::string& message_type, const std::string& filename) const
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

  KDB_EXCEPTION_TRY;

  if (!msg->ParseFromIstream(&file_in))
    return krr((S)"Failed to parse serialized message");

  KDB_EXCEPTION_CATCH;

  return kp((S)msg->DebugString().c_str());
}

} // namespace protobufkdb
} // namespace kx
