#include <iostream>
#include <string>
#include <memory>

#include <google/protobuf/stubs/common.h>
#include <google/protobuf/message.h>
#include <google/protobuf/descriptor.h>
#include <google/protobuf/arena.h>

#include "ProtobufKdb.h"
#include "MessageParser.h"
#include "MessageFactory.h"

// Due to its excessive and non-specific use of #define, 'k.h' must be included
// after all the protobuf headers to avoid conflicts.  Otherwise protobuf
// declarations like:
//
// template<typename R> 
// class ResultCallback
//
// will fail to compile due:
//
// #define R return
//
// in 'k.h'.
#include <k.h>


inline bool IsKdbString(K str)
{
  return str != NULL && (str->t == -KS || str->t == KC);
}

inline const std::string GetKdbString(K str)
{
  return str->t == -KS ? str->s : std::string((S)kG(str), str->n);
}

K Init(K unused)
{
  GOOGLE_PROTOBUF_VERIFY_VERSION;

  return (K)0;
}

K Version(K unused)
{
  return ki(GOOGLE_PROTOBUF_VERSION);
}

K VersionStr(K unused)
{
  const std::string version = "libprotobuf v" + gpb::internal::VersionString(GOOGLE_PROTOBUF_VERSION);
  return kpn((S)version.c_str(), version.length());
}

K SerializeArray(K message_type, K msg_in)
{
  if (!IsKdbString(message_type))
    return krr((S)"Specify message type");

  return MessageParser::Instance()->SerializeArray(GetKdbString(message_type), msg_in);
}

K SerializeArrayArena(K message_type, K msg_in)
{
  if (!IsKdbString(message_type))
    return krr((S)"Specify message type");

  return MessageParser::Instance()->SerializeArrayArena(GetKdbString(message_type), msg_in);
}

K ParseArray(K message_type, K char_array)
{
  if (!IsKdbString(message_type))
    return krr((S)"Specify message type");

  return MessageParser::Instance()->ParseArray(GetKdbString(message_type), char_array);
}

K ParseArrayArena(K message_type, K char_array)
{
  if (!IsKdbString(message_type))
    return krr((S)"Specify message type");

  return MessageParser::Instance()->ParseArrayArena(GetKdbString(message_type), char_array);
}

K SaveMessage(K message_type, K filename, K msg_in)
{
  if (!IsKdbString(message_type))
    return krr((S)"Specify message type");
  if (!IsKdbString(filename))
    return krr((S)"Specify filename");

  return MessageParser::Instance()->SaveMessage(GetKdbString(message_type), GetKdbString(filename), msg_in);
}

K LoadMessage(K message_type, K filename)
{
  if (!IsKdbString(message_type))
    return krr((S)"Specify message type");
  if (!IsKdbString(filename))
    return krr((S)"Specify filename");

  return MessageParser::Instance()->LoadMessage(GetKdbString(message_type), GetKdbString(filename));
}

K GetMessageSchema(K message_type)
{
  if (!IsKdbString(message_type))
    return krr((S)"Specify message type");

  // Create the intermediate message in a unique_ptr so we don't have to worry
  // about explicitly freeing it if there is an error
  std::unique_ptr<gpb::Message> msg(MessageFactory::Instance()->CreateMessage(GetKdbString(message_type)));
  if (!msg)
    return krr((S)"Invalid message type");

  const auto& debug_str = msg->GetDescriptor()->DebugString();
  return kpn((S)debug_str.c_str(), debug_str.length());
}

K AddProtoImportPath(K import_path)
{
  if (!IsKdbString(import_path))
    return krr((S)"Specify import path");
  
  MessageFactory::Instance()->AddProtoImportPath(GetKdbString(import_path));

  return (K)0;
}

K ImportProtoFile(K filename)
{
  if (!IsKdbString(filename))
    return krr((S)"Specify filename");

  std::string error;
  if (!MessageFactory::Instance()->ImportProtoFile(GetKdbString(filename), error)) {
    static char error_msg[1024];
    strncpy(error_msg, error.c_str(), sizeof(error_msg));
    error_msg[sizeof(error_msg) - 1] = '\0';
    return krr(error_msg);
  }

  return (K)0;
}

K ListImportedMessageTypes(K unused)
{
  std::vector<std::string> output;
  MessageFactory::Instance()->ListImportedMessageTypes(&output);

  const size_t num_messages = output.size();
  K message_list = ktn(KS, num_messages);
  for (size_t i = 0; i < num_messages; ++i)
    kS(message_list)[i] = ss((S)output[i].c_str());

  return message_list;
}

int main(int argc, char* argv[])
{
  Init((K)0);

  // khp needs to link with: legacy_stdio_definitions.lib;c_static.lib;ws2_32.lib;Iphlpapi.lib
  // khp((S)"", -1);

  // Delete all global objects allocated by libprotobuf.
  gpb::ShutdownProtobufLibrary();

  return 0;
}

