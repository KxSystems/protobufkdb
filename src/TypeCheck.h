#ifndef __TYPE_CHECK_H__
#define __TYPE_CHECK_H__

#include <exception>
#include <string>


namespace kx {
namespace protobufkdb {

// Set of macros to assist with performing the type checks such the arguments
// required to generate the exception message are not evaluated unless the
// condition is met
#define TYPE_CHECK_MESSAGE(condition, name, expected, received) \
  if (condition) throw TypeCheckMessage(name, expected, received);
#define TYPE_CHECK_REPEATED_MESSAGE(condition, name, expected, received)  \
  if (condition) throw TypeCheckRepeatedMessage(name, expected, received);
#define TYPE_CHECK_SCALAR(condition, name, expected, received) \
  if (condition) throw TypeCheckScalar(name, expected, received);
#define TYPE_CHECK_REPEATED(condition, name, expected, received) \
  if (condition) throw TypeCheckRepeated(name, expected, received);
#define TYPE_CHECK_REPEATED_STRING(condition, name, expected, received) \
  if (condition) throw TypeCheckRepeatedString(name, expected, received);
#define TYPE_CHECK_MAP(condition, name, received) \
  if (condition) throw TypeCheckMap(name, received);
#define TYPE_CHECK_MAP_ELEMENT(condition, name, expected, received) \
  if (condition) throw TypeCheckMapElement(name, expected, received);
#define TYPE_CHECK_MAP_STRING_ELEMENT(condition, name, expected, received) \
  if (condition) throw TypeCheckMapStringElement(name, expected, received);
#define TYPE_CHECK_FIELD_NUM(condition, name, expected, received) \
  if (condition) throw TypeCheckFieldNum(name, expected, received);
#define TYPE_CHECK_COMPATIBLE(condition, name, cpp_type, compatible, requested) \
  if (condition) throw TypeCheckCompatible(name, cpp_type, compatible, requested);
#define TYPE_CHECK_FIELD_NAMES(condition, name, expected, received) \
  if (condition) throw TypeCheckFieldNames(name, expected, received);
#define TYPE_CHECK_FIELD_VALUES(condition, name, expected, received) \
  if (condition) throw TypeCheckFieldValues(name, expected, received);
#define TYPE_CHECK_UNKNOWN_FIELD(condition, name, field) \
  if (condition) throw TypeCheckUnknownField(name, field);
#define TYPE_CHECK_GUID(condition, name, expected, received) \
  if (condition) throw TypeCheckGuid(name, expected, received);

// Hierachy of TypeCheck exceptions with each derived type being using for a
// specific check when converting from a kdb object to a protobuf message while
// only requiring a single catch specification for the parent type.
class TypeCheck : public std::invalid_argument
{
public:
  TypeCheck(std::string message) : std::invalid_argument(message.c_str())
  {};
};

class TypeCheckMessage : public TypeCheck
{
public:
  TypeCheckMessage(const std::string& name, int expected, int received) :
    TypeCheck("Invalid message type, descriptor: '" + name + "', expected: "
      + std::to_string(expected) + ", received: " + std::to_string(received))
  {};
};

class TypeCheckRepeatedMessage : public TypeCheck
{
public:
  TypeCheckRepeatedMessage(const std::string& name, int expected, int received) :
    TypeCheck("Invalid repeated message type, field: '" + name + "', expected: "
      + std::to_string(expected) + ", received: " + std::to_string(received))
  {};
};

class TypeCheckScalar : public TypeCheck
{
public:
  TypeCheckScalar(const std::string& name, int expected, int received) :
    TypeCheck("Invalid scalar type, field: '" + name + "', expected: "
      + std::to_string(expected) + ", received: " + std::to_string(received))
  {};
};

class TypeCheckRepeated : public TypeCheck
{
public:
  TypeCheckRepeated(const std::string& name, int expected, int received) :
    TypeCheck("Invalid repeated type, field: '" + name + "', expected: "
      + std::to_string(expected) + ", received: " + std::to_string(received))
  {};
};

class TypeCheckRepeatedString : public TypeCheck
{
public:
  TypeCheckRepeatedString(const std::string& name, int expected, int received) :
    TypeCheck("Invalid repeated string type, field: '" + name + "', expected: "
      + std::to_string(expected) + ", received: " + std::to_string(received))
  {};
};

class TypeCheckMap : public TypeCheck
{
public:
  TypeCheckMap(const std::string& name, int received) :
    TypeCheck("Invalid map type, field: '" + name + "', expected: 99, received: "
      + std::to_string(received))
  {};
};

class TypeCheckMapElement : public TypeCheck
{
public:
  TypeCheckMapElement(const std::string& name, int expected, int received) :
    TypeCheck("Invalid map element type, field: '" + name + "', expected: "
      + std::to_string(expected) + ", received: " + std::to_string(received))
  {};
};

class TypeCheckMapStringElement : public TypeCheck
{
public:
  TypeCheckMapStringElement(const std::string& name, int expected, int received) :
    TypeCheck("Invalid map string element type, field: '" + name + "', expected: "
      + std::to_string(expected) + ", received: " + std::to_string(received))
  {};
};

class TypeCheckFieldNum : public TypeCheck
{
public:
  TypeCheckFieldNum(const std::string& name, int expected, int received) :
    TypeCheck("Incorrect number of fields, message: '" + name + "', expected: "
      + std::to_string(expected) + ", received: " + std::to_string(received))
  {};
};

class TypeCheckCompatible : public TypeCheck
{
public:
  TypeCheckCompatible(const std::string& name, const char* cpp_type, int compatible, int requested) :
    TypeCheck("Incompatible kdb type mapping, field: '" + name + "', cpp type: " + cpp_type
      + ", compatible: " + std::to_string(compatible) + ", requested: " + std::to_string(requested))
  {};
};

class TypeCheckFieldNames : public TypeCheck
{
public:
  TypeCheckFieldNames(const std::string& name, int expected, int received) :
    TypeCheck("Invalid message field names, descriptor: '" + name + "', expected: "
      + std::to_string(expected) + ", received: " + std::to_string(received))
  {};
};

class TypeCheckFieldValues : public TypeCheck
{
public:
  TypeCheckFieldValues(const std::string& name, int expected, int received) :
    TypeCheck("Invalid message field values, descriptor: '" + name + "', expected: "
      + std::to_string(expected) + ", received: " + std::to_string(received))
  {};
};

class TypeCheckUnknownField : public TypeCheck
{
public:
  TypeCheckUnknownField(const std::string& name, const std::string& field) :
    TypeCheck("Unknown message field name, descriptor: '" + name + "', field: '" + field + "'")
  {};
};

class TypeCheckGuid : public TypeCheck
{
public:
  TypeCheckGuid(const std::string& name, int expected, int received) :
    TypeCheck("Invalid GUID encoded string length, field: '" + name + "', expected: "
      + std::to_string(expected) + ", received: " + std::to_string(received))
  {};
};

} // namespace protobufkdb
} // namepsace kx

#endif // __TYPE_CHECK_H__
