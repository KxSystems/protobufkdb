#ifndef __REPEATED_VALUES_H__
#define __REPEATED_VALUES_H__

#include <google/protobuf/message.h>

// Due to its excessive and non-specific use of #define, 'k.h' must be included
// after all the protobuf headers to avoid conflicts.
#include <k.h>


namespace kx {
namespace protobufkdb {
namespace gpb = ::google::protobuf;

// Each of the sets of of getter and setter functions shared the same argument
// lists so place the arg-lists in macros for consistency and to avoid repetition
#define REPEATED_VALUES_GET_ARGS \
  const gpb::Message& msg, const gpb::Reflection* refl, const gpb::FieldDescriptor* field, K out_list
#define REPEATED_VALUES_SET_ARGS \
  gpb::Message* msg, const gpb::Reflection* refl, const gpb::FieldDescriptor* field, K in_list


class RepeatedValues
{
  typedef void(*Repeated2KdbFn)(REPEATED_VALUES_GET_ARGS);
  typedef void(*Kdb2RepeatedFn)(REPEATED_VALUES_SET_ARGS);

private:
  static class RepeatedValues* instance;

  Repeated2KdbFn get_repeated_fns[gpb::FieldDescriptor::MAX_CPPTYPE];
  Kdb2RepeatedFn set_repeated_fns[gpb::FieldDescriptor::MAX_CPPTYPE];

private:
  RepeatedValues();

  static void GetRepeatedInt32(REPEATED_VALUES_GET_ARGS);
  static void GetRepeatedInt64(REPEATED_VALUES_GET_ARGS);
  static void GetRepeatedUInt32(REPEATED_VALUES_GET_ARGS);
  static void GetRepeatedUInt64(REPEATED_VALUES_GET_ARGS);
  static void GetRepeatedDouble(REPEATED_VALUES_GET_ARGS);
  static void GetRepeatedFloat(REPEATED_VALUES_GET_ARGS);
  static void GetRepeatedBool(REPEATED_VALUES_GET_ARGS);
  static void GetRepeatedEnum(REPEATED_VALUES_GET_ARGS);
  static void GetRepeatedString(REPEATED_VALUES_GET_ARGS);

  static void SetRepeatedInt32(REPEATED_VALUES_SET_ARGS);
  static void SetRepeatedInt64(REPEATED_VALUES_SET_ARGS);
  static void SetRepeatedUInt32(REPEATED_VALUES_SET_ARGS);
  static void SetRepeatedUInt64(REPEATED_VALUES_SET_ARGS);
  static void SetRepeatedDouble(REPEATED_VALUES_SET_ARGS);
  static void SetRepeatedFloat(REPEATED_VALUES_SET_ARGS);
  static void SetRepeatedBool(REPEATED_VALUES_SET_ARGS);
  static void SetRepeatedEnum(REPEATED_VALUES_SET_ARGS);
  static void SetRepeatedString(REPEATED_VALUES_SET_ARGS);

public:
  /**
   * @brief Returns the singleton instance.
   *
   * @return RepeatedValues object
  */
  static const RepeatedValues* Instance();

  /**
   * @brief Converts a repeated message field to a kdb simple list.
   *
   * The kdb list type is determined as follows:
   *  Repeated Cpp Type | Kdb Type
   *  int32, uint32       KI
   *  int64, uint64       KJ
   *  double              KF
   *  float               KE
   *  bool                KB
   *  enum                KI
   *  string              0 (of KC)
   *  bytes               0 (of KG)
   *
   * Note that a repeated sub-message field is handled by
   * MessageFormat::GetMessageField().
   *
   * @param msg   Protobuf message containing the field
   * @param refl  Reflection interface to the message
   * @param field FieldDescriptor of the repeated field to be processed
   * @return      Kdb simple list object
  */
  K GetRepeated(const gpb::Message& msg, const gpb::Reflection* refl, const gpb::FieldDescriptor* field) const;

  /**
   * @brief Populates a repeated message field from a kdb simple list.
   *
   * The kdb list type must correspond with the mapping specified for
   * GetRepeated() otherwise a TypeCheck exception will be thrown.
   *
   * @param msg         Protobuf message containing the field
   * @param refl        Reflection interface to the message
   * @param field       FieldDescriptor of the repeated field to be populated
   * @param k_repeated  Kdb simple list from which the repeated values are set
  */
  void SetRepeated(gpb::Message* msg, const gpb::Reflection* refl, const gpb::FieldDescriptor* field, K k_repeated) const;
};

} // namespace protobufkdb
} // namespace kx


#endif // __REPEATED_VALUES_H__
