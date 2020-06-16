#ifndef __MESSAGE_FACTORY_H__
#define __MESSAGE_FACTORY_H__

// The protoc generated header file for each '.proto' schema must be included
// from 'ProtoHeaders.h'
#include "ProtoHeaders.h"

#include <google/protobuf/message.h>
#include <google/protobuf/arena.h>
#include <map>
#include <string>

namespace gpb = ::google::protobuf;


// ### MESSAGE TYPE LOOKUP NAMES ###
//
// The MessageTypes namespace contains a lookup string which is used by the
// factory to create a protobuf message of that type.  
//
// In order to use the INSERT_MESSAGE_TYPE() macro below each string declaration
// must use the same name as the typename of the message class to which it
// refers.  It is also suggested that the string value be the same as its
// correponding classname.
namespace MessageTypes
{
  // For example 'tests.proto' generates the message classes ScalarTest,
  // RepeatedTest, SubMessageTest, MapTest, ScalarSpecifiersTest,
  // RepeatedSpecifiersTest, MapSpecifiersTest, OneofTest and therefore 
  // requires:
  const std::string ScalarTest = "ScalarTest";
  const std::string RepeatedTest = "RepeatedTest";
  const std::string SubMessageTest = "SubMessageTest";
  const std::string MapTest = "MapTest";
  const std::string ScalarSpecifiersTest = "ScalarSpecifiersTest";
  const std::string RepeatedSpecifiersTest = "RepeatedSpecifiersTest";
  const std::string MapSpecifiersTest = "MapSpecifiersTest";
  const std::string OneofTest = "OneofTest";

  const std::string ScalarExample = "ScalarExample";
  const std::string RepeatedExample = "RepeatedExample";
  const std::string SubMessageExample = "SubMessageExample";
  const std::string MapExample = "MapExample";
  const std::string SpecifierExample = "SpecifierExample";
  const std::string OneofExample = "OneofExample";
}


// Helper macro to populate the lookup map
//
// @param type        The typename of the message class, must be the same as the
// corresponding string declaration in the MessageTypes namespace
//
// @param static_var  Static variable to create for the message
#define INSERT_MESSAGE_TYPE(type, static_var)                 \
  static type static_var;                                     \
  message_lookup.insert({ MessageTypes::type, &static_var });


class MessageFactory
{
private:
  static class MessageFactory* instance;
  
  std::map<std::string, gpb::Message*> message_lookup;

private:
  MessageFactory()
  {
    // ### POPULATE FACTORY LOOKUP MAP ###
    //
    // A static message must be defined and inserted into the lookup map for
    // each required message type.  There is no limitation on the name of the
    // static message declaration.
    //
    // Note: These static messages are only used as a template to create new
    // messages of the correct type - they are not returned directly by
    // CreateMessage()
    //
    // For example 'tests.proto' generates the message classes ScalarTest,
    // RepeatedTest, SubMessageTest, MapTest, ScalarSpecifiersTest,
    // RepeatedSpecifiersTest, MapSpecifiersTest, OneofTest and therefore 
    // requires:
    INSERT_MESSAGE_TYPE(ScalarTest, scalar_test);
    INSERT_MESSAGE_TYPE(RepeatedTest, repeated_test);
    INSERT_MESSAGE_TYPE(SubMessageTest, sub_test);
    INSERT_MESSAGE_TYPE(MapTest, map_test);
    INSERT_MESSAGE_TYPE(ScalarSpecifiersTest, scalar_specifiers_test);
    INSERT_MESSAGE_TYPE(RepeatedSpecifiersTest, repeated_specifiers_test);
    INSERT_MESSAGE_TYPE(MapSpecifiersTest, map_specifiers_test);
    INSERT_MESSAGE_TYPE(OneofTest, oneof_test);

    INSERT_MESSAGE_TYPE(ScalarExample, scalar_example);
    INSERT_MESSAGE_TYPE(RepeatedExample, repeated_example);
    INSERT_MESSAGE_TYPE(SubMessageExample, sub_example);
    INSERT_MESSAGE_TYPE(MapExample, map_example);
    INSERT_MESSAGE_TYPE(SpecifierExample, specifier_example);
    INSERT_MESSAGE_TYPE(OneofExample, oneof_example);
  }

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
   * @param message_type  String representation of a message type.  Should be
   * specified in the MessageTypes namespace.
   * @param arena         Optional google arena in which to create the message
   * @return              New protobuf message        
  */
  gpb::Message* CreateMessage(const char* message_type, gpb::Arena* arena = NULL) const;
};

#endif // __MESSAGE_FACTORY_H__
