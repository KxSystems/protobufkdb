#ifndef __SCALAR_VALUES_H__
#define __SCALAR_VALUES_H__

#include <google/protobuf/message.h>

// Due to its excessive and non-specific use of #define, 'k.h' must be included
// after all the protobuf headers to avoid conflicts.
#include <k.h>


namespace kx {
namespace protobufkdb {
namespace gpb = ::google::protobuf;

// Each of the sets of of getter and setter functions shared the same argument
// lists so place the arg-lists in macros for consistency and to avoid repetition
#define SCALAR_VALUES_GET_ARGS \
  const gpb::Message& msg, const gpb::Reflection* refl, const gpb::FieldDescriptor* field
#define SCALAR_VALUES_SET_ARGS \
  gpb::Message* msg, const gpb::Reflection* refl, const gpb::FieldDescriptor* field, K k_scalar


class ScalarValues
{
  typedef K(*Scalar2KdbFn)(SCALAR_VALUES_GET_ARGS);
  typedef void(*Kdb2ScalarFn)(SCALAR_VALUES_SET_ARGS);

private:
  static class ScalarValues* instance;

  Scalar2KdbFn get_scalar_fns[gpb::FieldDescriptor::MAX_CPPTYPE];
  Kdb2ScalarFn set_scalar_fns[gpb::FieldDescriptor::MAX_CPPTYPE];

private:
  ScalarValues();

  static K GetInt32(SCALAR_VALUES_GET_ARGS);
  static K GetInt64(SCALAR_VALUES_GET_ARGS);
  static K GetUInt32(SCALAR_VALUES_GET_ARGS);
  static K GetUInt64(SCALAR_VALUES_GET_ARGS);
  static K GetDouble(SCALAR_VALUES_GET_ARGS);
  static K GetFloat(SCALAR_VALUES_GET_ARGS);
  static K GetBool(SCALAR_VALUES_GET_ARGS);
  static K GetEnum(SCALAR_VALUES_GET_ARGS);
  static K GetString(SCALAR_VALUES_GET_ARGS);

  static void SetInt32(SCALAR_VALUES_SET_ARGS);
  static void SetInt64(SCALAR_VALUES_SET_ARGS);
  static void SetUInt32(SCALAR_VALUES_SET_ARGS);
  static void SetUInt64(SCALAR_VALUES_SET_ARGS);
  static void SetDouble(SCALAR_VALUES_SET_ARGS);
  static void SetFloat(SCALAR_VALUES_SET_ARGS);
  static void SetBool(SCALAR_VALUES_SET_ARGS);
  static void SetEnum(SCALAR_VALUES_SET_ARGS);
  static void SetString(SCALAR_VALUES_SET_ARGS);

public:
  /**
   * @brief Returns the singleton instance.
   *
   * @return ScalarValues object
  */
  static const ScalarValues* Instance();

  /**
   * @brief Converts a scalar message field to a kdb atom.
   *
   * The kdb atom type is determined as follows:
   *  Scalar Cpp Type | Kdb Type
   *  int32, uint32     -KI
   *  int64, uint64     -KJ
   *  double            -KF
   *  float             -KE
   *  bool              -KB
   *  enum              -KI
   *  string             KC
   *  bytes              KG
   *
   * Note that a sub-message field is handled by
   * MessageFormat::GetMessageField().
   *
   * @param msg   Protobuf message containing the field
   * @param refl  Reflection interface to the message
   * @param field FieldDescriptor of the scalar field to be processed
   * @return      Kdb object containing the atom
  */
  K GetScalar(const gpb::Message& msg, const gpb::Reflection* refl, const gpb::FieldDescriptor* field) const;

  /**
   * @brief Populates a scalar message field from a kdb atom.
   *
   * The kdb atom type must correspond with the mapping specified for
   * GetScalar() otherwise a TypeCheck exception will be thrown.
   *
   * @param msg       Protobuf message containing the field
   * @param refl      Reflection interface to the message
   * @param field     FieldDescriptor of the scalar field to be populated
   * @param k_scalar  Kdb atom from which the scalar value is set
  */
  void SetScalar(gpb::Message* msg, const gpb::Reflection* refl, const gpb::FieldDescriptor* field, K k_scalar) const;
};

} // namespace protobufkdb
} // namespace kx


#endif // __SCALAR_VALUES_H__
