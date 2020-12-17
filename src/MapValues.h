#ifndef __MAP_VALUES_H__
#define __MAP_VALUES_H__

#include <google/protobuf/message.h>

// Due to its excessive and non-specific use of #define, 'k.h' must be included
// after all the protobuf headers to avoid conflicts.
#include <k.h>


namespace kx {
namespace protobufkdb {
namespace gpb = ::google::protobuf;

// Each of the sets of of getter and setter functions shared the same argument
// lists so place the arg-lists in macros for consistency and to avoid repetition
#define MAP_VALUES_GET_ARGS \
  const gpb::Message& msg, const gpb::Reflection* refl, const gpb::FieldDescriptor* field, K k_list, int index, bool key_field, bool use_field_names
#define MAP_VALUES_SET_ARGS \
  gpb::Message* msg, const gpb::Reflection* refl, const gpb::FieldDescriptor* field, K k_list, int index, bool key_field, bool use_field_names


class MapValues
{
  typedef void(*MapElement2KdbFn)(MAP_VALUES_GET_ARGS);
  typedef void(*Kdb2MapElementFn)(MAP_VALUES_SET_ARGS);

private:
  static class MapValues* instance;

  MapElement2KdbFn get_map_element_fns[gpb::FieldDescriptor::MAX_CPPTYPE + 1];
  Kdb2MapElementFn set_map_element_fns[gpb::FieldDescriptor::MAX_CPPTYPE + 1];

private:
  MapValues();

  inline void GetElement(MAP_VALUES_GET_ARGS) const;
  inline void SetElement(MAP_VALUES_SET_ARGS) const;

  static void GetInt32(MAP_VALUES_GET_ARGS);
  static void GetInt64(MAP_VALUES_GET_ARGS);
  static void GetUInt32(MAP_VALUES_GET_ARGS);
  static void GetUInt64(MAP_VALUES_GET_ARGS);
  static void GetDouble(MAP_VALUES_GET_ARGS);
  static void GetFloat(MAP_VALUES_GET_ARGS);
  static void GetBool(MAP_VALUES_GET_ARGS);
  static void GetEnum(MAP_VALUES_GET_ARGS);
  static void GetString(MAP_VALUES_GET_ARGS);
  static void GetMessage(MAP_VALUES_GET_ARGS);

  static void SetInt32(MAP_VALUES_SET_ARGS);
  static void SetInt64(MAP_VALUES_SET_ARGS);
  static void SetUInt32(MAP_VALUES_SET_ARGS);
  static void SetUInt64(MAP_VALUES_SET_ARGS);
  static void SetDouble(MAP_VALUES_SET_ARGS);
  static void SetFloat(MAP_VALUES_SET_ARGS);
  static void SetBool(MAP_VALUES_SET_ARGS);
  static void SetEnum(MAP_VALUES_SET_ARGS);
  static void SetString(MAP_VALUES_SET_ARGS);
  static void SetMessage(MAP_VALUES_SET_ARGS);

public:
  /**
   * @brief Returns the singleton instance.
   *
   * @return RepeatedValues object
  */
  static const MapValues* Instance();

  /**
   * @brief Converts a map message field to a kdb dictionary.  The dictionary
   * is comprised of two lists, the first dependent on the map key type and
   * the second on the map value type.
   *
   * Protobuf map keys can only be an integer type or string and therefore
   * produce a simple key list of type:
   *  MapKey Cpp Type | Kdb Type
   *  int32, uint32     KI
   *  int64, uint64     KJ
   *  bool              KB
   *  string            KS
   *
   * Protobuf map values can be any scalar type or a message and therefore
   * produce a value list of type:
   *  MapValue Cpp Type | Kdb Type
   *  int32, uint32       KI
   *  int64, uint64       KJ
   *  double              KF
   *  float               KE
   *  bool                KB
   *  enum                KI
   *  string              0 (of KC)
   *  bytes               0 (of KG)
   *  message             0 (mixed list of mixed lists)
   *
   * Note that the protobuf wire format and map iteration ordering of map items
   * is undefined, so you cannot rely on a particular dictionary ordering.
   *
   * @param msg             Protobuf message containing the field
   * @param refl            Reflection interface to the message
   * @param field           FieldDescriptor of the map field to be processed
   * @param use_field_names Flag indicating whether a message is represented as
   * a mixed list of field values or a dictionary from field name symbols to the
   * field values
   * @return Kdb dictionary object
  */
  K GetMap(const gpb::Message& msg, const gpb::Reflection* refl, const gpb::FieldDescriptor* field, bool use_field_names) const;

  /**
   * @brief Populates a map message field from a kdb dictionary.
   *
   * The kdb list type must correspond with the mapping specified for GetMap()
   * otherwise a TypeCheck exception will be thrown.
   *
   * @param msg             Protobuf message containing the field
   * @param refl            Reflection interface to the message
   * @param field           FieldDescriptor of the map field to be populated
   * @param k_dict          Kdb dictionary from which the map keys/values are
   * set
   * @param use_field_names Flag indicating whether a message is represented as
   * a mixed list of field values or a dictionary from field name symbols to the
   * field values
  */
  void SetMap(gpb::Message* msg, const gpb::Reflection* refl, const gpb::FieldDescriptor* field, K k_dict, bool use_field_names) const;
};

} // namespace protobufkdb
} // namespace kx


#endif // __MAP_VALUES_H__
