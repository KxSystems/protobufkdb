#ifndef __TYPE_CHECK_H__
#define __TYPE_CHECK_H__

#include <exception>
#include <sstream>
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

inline void Stream(std::ostringstream&)
{};

template <typename HEAD, typename ...TAIL>
void Stream(std::ostringstream& oss, const HEAD& head, const TAIL&... tail)
{
  oss << head;
  Stream(oss, tail...);
}

template <typename ...PARTS>
std::string Format(const PARTS&... parts)
{
  std::ostringstream oss;
  Stream(oss, parts...);
  return oss.str();
}

// Hierachy of TypeCheck exceptions with each derived type being using for a
// specific check when converting from a kdb object to a protobuf message while
// only requiring a single catch specification for the parent type.
class TypeCheck : public std::invalid_argument
{
public:
  TypeCheck(const std::string& message) : std::invalid_argument(message)
  {};
};

class TypeCheckMessage : public TypeCheck
{
public:
  template <typename STRINGTYPE>
  TypeCheckMessage(const STRINGTYPE& name, int expected, int received) :
    TypeCheck(Format("Invalid message type, descriptor: '", name, "', expected: ", expected, ", received: ", received))
  {};
};

class TypeCheckRepeatedMessage : public TypeCheck
{
public:
  template <typename STRINGTYPE>
  TypeCheckRepeatedMessage(const STRINGTYPE& name, int expected, int received) :
    TypeCheck(Format("Invalid repeated message type, field: '", name, "', expected: ", expected, ", received: ", received))
  {};
};

class TypeCheckScalar : public TypeCheck
{
public:
  template <typename STRINGTYPE>
  TypeCheckScalar(const STRINGTYPE& name, int expected, int received) :
    TypeCheck(Format("Invalid scalar type, field: '", name, "', expected: ", expected, ", received: ", received))
  {};
};

class TypeCheckRepeated : public TypeCheck
{
public:
  template <typename STRINGTYPE>
  TypeCheckRepeated(const STRINGTYPE& name, int expected, int received) :
    TypeCheck(Format("Invalid repeated type, field: '", name, "', expected: ", expected, ", received: ", received))
  {};
};

class TypeCheckRepeatedString : public TypeCheck
{
public:
  template <typename STRINGTYPE>
  TypeCheckRepeatedString(const STRINGTYPE& name, int expected, int received) :
    TypeCheck(Format("Invalid repeated string type, field: '", name, "', expected: ", expected, ", received: ", received))
  {};
};

class TypeCheckMap : public TypeCheck
{
public:
  template <typename STRINGTYPE>
  TypeCheckMap(const STRINGTYPE& name, int received) :
    TypeCheck(Format("Invalid map type, field: '", name, "', expected: 99, received: ", received))
  {};
};

class TypeCheckMapElement : public TypeCheck
{
public:
  template <typename STRINGTYPE>
  TypeCheckMapElement(const STRINGTYPE& name, int expected, int received) :
    TypeCheck(Format("Invalid map element type, field: '", name, "', expected: ", expected, ", received: ", received))
  {};
};

class TypeCheckMapStringElement : public TypeCheck
{
public:
  template <typename STRINGTYPE>
  TypeCheckMapStringElement(const STRINGTYPE& name, int expected, int received) :
    TypeCheck(Format("Invalid map string element type, field: '", name, "', expected: ", expected, ", received: ", received))
  {};
};

class TypeCheckFieldNum : public TypeCheck
{
public:
  template <typename STRINGTYPE>
  TypeCheckFieldNum(const STRINGTYPE& name, int expected, int received) :
    TypeCheck(Format("Incorrect number of fields, message: '", name, "', expected: ", expected, ", received: ", received))
  {};
};

class TypeCheckCompatible : public TypeCheck
{
public:
  template <typename STRINGTYPE, typename CPPTYPE>
  TypeCheckCompatible(const STRINGTYPE& name, const CPPTYPE& cpp_type, int compatible, int requested) :
    TypeCheck(Format("Incompatible kdb type mapping, field: '", name, "', cpp type: ", cpp_type,
                     ", compatible: ", compatible, ", requested: ", requested))
  {};
};

class TypeCheckFieldNames : public TypeCheck
{
public:
  template <typename STRINGTYPE>
  TypeCheckFieldNames(const STRINGTYPE& name, int expected, int received) :
    TypeCheck(Format("Invalid message field names, descriptor: '", name, "', expected: ", expected, ", received: ", received))
  {};
};

class TypeCheckFieldValues : public TypeCheck
{
public:
  template <typename STRINGTYPE>
  TypeCheckFieldValues(const STRINGTYPE& name, int expected, int received) :
    TypeCheck(Format("Invalid message field values, descriptor: '", name, "', expected: ", expected, ", received: ", received))
  {};
};

class TypeCheckUnknownField : public TypeCheck
{
public:
  template <typename STRINGTYPE, typename FIELDTYPE>
  TypeCheckUnknownField(const STRINGTYPE& name, const FIELDTYPE& field) :
    TypeCheck(Format("Unknown message field name, descriptor: '", name, "', field: '", field, "'"))
  {};
};

class TypeCheckGuid : public TypeCheck
{
public:
  template <typename STRINGTYPE>
  TypeCheckGuid(const STRINGTYPE& name, int expected, int received) :
    TypeCheck(Format("Invalid GUID encoded string length, field: '", name, "', expected: ", expected, ", received: ", received))
  {};
};

} // namespace protobufkdb
} // namepsace kx

#endif // __TYPE_CHECK_H__
