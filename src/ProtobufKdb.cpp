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
#include "KdbTypes.h"
#include "MessageFormat.h"

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
  return str->t == -KS || str->t == KC || str->t == KG;
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
  const std::string version = "libprotobuf v" + google::protobuf::internal::VersionString(GOOGLE_PROTOBUF_VERSION);
  return kpn((S)version.c_str(), version.length());
}

K SerializeArray(K message_type, K msg_in, K use_field_names)
{
  if (!IsKdbString(message_type))
    return krr((S)"message_type not -11|4|10h");
  if (use_field_names->t != -KB)
    return krr((S)"use_field_names not -1h");

  return kx::protobufkdb::MessageParser::Instance()->SerializeArray(GetKdbString(message_type), msg_in, use_field_names->g);
}

K SerializeArrayArena(K message_type, K msg_in, K use_field_names)
{
  if (!IsKdbString(message_type))
    return krr((S)"message_type not -11|4|10h");
  if (use_field_names->t != -KB)
    return krr((S)"use_field_names not -1h");

  return kx::protobufkdb::MessageParser::Instance()->SerializeArrayArena(GetKdbString(message_type), msg_in, use_field_names->g);
}

K ParseArray(K message_type, K char_array, K use_field_names)
{
  if (!IsKdbString(message_type))
    return krr((S)"message_type not -11|4|10h");
  if (char_array->t != KG && char_array->t != KC)
    return krr((S)"char_array not 4|10h");
  if (use_field_names->t != -KB)
    return krr((S)"use_field_names not -1h");

  return kx::protobufkdb::MessageParser::Instance()->ParseArray(GetKdbString(message_type), char_array, use_field_names->g);
}

K ParseArrayArena(K message_type, K char_array, K use_field_names)
{
  if (!IsKdbString(message_type))
    return krr((S)"message_type not -11|4|10h");
  if (char_array->t != KG && char_array->t != KC)
    return krr((S)"char_array not 4|10h");
  if (use_field_names->t != -KB)
    return krr((S)"use_field_names not -1h");

  return kx::protobufkdb::MessageParser::Instance()->ParseArrayArena(GetKdbString(message_type), char_array, use_field_names->g);
}

K ParseArrayDebug(K message_type, K char_array)
{
  if (!IsKdbString(message_type))
    return krr((S)"message_type not -11|4|10h");
  if (char_array->t != KG && char_array->t != KC)
    return krr((S)"char_array not 4|10h");

  return kx::protobufkdb::MessageParser::Instance()->ParseArrayDebug(GetKdbString(message_type), char_array);
}

K SaveMessage(K message_type, K filename, K msg_in, K use_field_names)
{
  if (!IsKdbString(message_type))
    return krr((S)"message_type not -11|4|10h");
  if (!IsKdbString(filename))
    return krr((S)"filename not -11|4|10h");
  if (use_field_names->t != -KB)
    return krr((S)"use_field_names not -1h");

  return kx::protobufkdb::MessageParser::Instance()->SaveMessage(GetKdbString(message_type), GetKdbString(filename), msg_in, use_field_names->g);
}

K LoadMessage(K message_type, K filename, K use_field_names)
{
  if (!IsKdbString(message_type))
    return krr((S)"message_type not -11|4|10h");
  if (!IsKdbString(filename))
    return krr((S)"filename not -11|4|10h");
  if (use_field_names->t != -KB)
    return krr((S)"use_field_names not -1h");

  return kx::protobufkdb::MessageParser::Instance()->LoadMessage(GetKdbString(message_type), GetKdbString(filename), use_field_names->g);
}

K LoadMessageDebug(K message_type, K filename)
{
  if (!IsKdbString(message_type))
    return krr((S)"message_type not -11|4|10h");
  if (!IsKdbString(filename))
    return krr((S)"filename not -11|4|10h");

  return kx::protobufkdb::MessageParser::Instance()->LoadMessageDebug(GetKdbString(message_type), GetKdbString(filename));
}

K GetMessageSchema(K message_type)
{
  if (!IsKdbString(message_type))
    return krr((S)"message_type not -11|4|10h");

  // Create the intermediate message in a unique_ptr so we don't have to worry
  // about explicitly freeing it if there is an error
  std::unique_ptr<google::protobuf::Message> msg(kx::protobufkdb::MessageFactory::Instance()->CreateMessage(GetKdbString(message_type)));
  if (!msg)
    return krr((S)"Unknown message type");

  const auto& debug_str = msg->GetDescriptor()->DebugString();
  return kpn((S)debug_str.c_str(), debug_str.length());
}

K GetMessageFields(K message_type)
{
  if (!IsKdbString(message_type))
    return krr((S)"message_type not -11|4|10h");

  // Create the intermediate message in a unique_ptr so we don't have to worry
  // about explicitly freeing it if there is an error
  std::unique_ptr<google::protobuf::Message> msg(kx::protobufkdb::MessageFactory::Instance()->CreateMessage(GetKdbString(message_type)));
  if (!msg)
    return krr((S)"Unknown message type");

  const auto desc = msg->GetDescriptor();
  K fields = ktn(KS, desc->field_count());
  for (int i = 0; i < desc->field_count(); ++i)
    kS(fields)[i] = ss((S)desc->field(i)->name().c_str());

  return fields;
}

K AddProtoImportPath(K import_path)
{
  if (!IsKdbString(import_path))
    return krr((S)"import_path not -11|4|10h");
  
  kx::protobufkdb::MessageFactory::Instance()->AddProtoImportPath(GetKdbString(import_path));

  return (K)0;
}

K ImportProtoFile(K filename)
{
  if (!IsKdbString(filename))
    return krr((S)"filename not -11|4|10h");

  std::string error;
  if (!kx::protobufkdb::MessageFactory::Instance()->ImportProtoFile(GetKdbString(filename), error)) {
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
  kx::protobufkdb::MessageFactory::Instance()->ListImportedMessageTypes(&output);

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
  google::protobuf::ShutdownProtobufLibrary();

  return 0;
}

