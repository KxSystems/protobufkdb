#ifndef __KDB_TYPES_H__
#define __KDB_TYPES_H__

#include <google/protobuf/message.h>
#include "kdb_type_specifier.pb.h"

// Due to its excessive and non-specific use of #define, 'k.h' must be included
// after all the protobuf headers to avoid conflicts.
#include <k.h>


namespace kx {
namespace protobufkdb {
namespace gpb = ::google::protobuf;

class KdbTypes
{
public:
  // Typename of k->t
  typedef decltype(k0::t) KType;

private:
  static class KdbTypes* instance;

  // Maps the protobuf cpp type to the corresponding kdb type
  const KType cpp_ktype[gpb::FieldDescriptor::MAX_CPPTYPE + 1] =
    { 0, KI, KJ, KI, KJ, KF, KE, KB, KI, KS, 0 };

  // Maps the KdbTypeSpecifier enum to the corresponding kdb type
  const KType specifier_ktype[KdbTypeSpecifier::KDBTYPE_LEN] =
    { 0, KP, KM, KD, KZ, KN, KU, KV, KT, UU };

  // Maps the KdbTypeSpecifier enum to a 'compatible' kdb type.  Used to
  // check the KdbTypeSpecifier is compatible with protobuf cpp type (mapped to
  // its kdb type).
  const KType compatible_ktype[KdbTypeSpecifier::KDBTYPE_LEN] =
    { 0, KJ, KI, KI, KF, KJ, KI, KI, KI, KS };

  // Mappings for string, bytes and string-map-key fields
  enum KdbStringEncodings
  {
    SYMBOL = -KS,
    BYTE_ARRAY = KG,
    CHAR_ARRAY = KC
  };
  const KdbStringEncodings string_kdb_type = KdbStringEncodings::CHAR_ARRAY;
  const KdbStringEncodings bytes_kdb_type = KdbStringEncodings::BYTE_ARRAY;
  const KdbStringEncodings string_map_key_kdb_type = KdbStringEncodings::SYMBOL;

private:
  KdbTypes()
  {};

  // Lookup functions into the above mapping arrays
  inline const KType Cpp2KdbType(const gpb::FieldDescriptor::CppType type) const;
  inline const KType Specifier2KdbType(const KdbTypeSpecifier type) const;
  inline const KType CompatibleKdbType(const KdbTypeSpecifier type) const;

  /**
   * @brief Returns the kdb type of the specified (non-map) field.
   *
   * If the field has a KdbTypeSpecifier option specified then that is mapped to
   * the corresponding kdb type, otherwise the kdb type corresponding to the
   * field's cpp type is returned.
   *
   * @param field FieldDescriptor of the field to be mapped
   * @return      Corresponding kdb type
  */
  const KType GetKdbType(const gpb::FieldDescriptor* field) const;

public:
  /**
   * @brief Returns the singleton instance.
   *
   * @return KdbTypes object
  */
  static const KdbTypes* Instance();

  /**
   * @brief Returns the kdb type of the specified scalar field.
   *
   * Similar to GetKdbType() but maps string and bytes proto fields according to
   * the configured setting.
   *
   * @param field FieldDescriptor of the field to be mapped
   * @return      Corresponding kdb type
  */
  const KType GetScalarKdbType(const gpb::FieldDescriptor* field) const;

  /**
   * @brief Returns the kdb type of the specified repeated field.
   *
   * Similar to GetKdbType() but maps string and bytes proto fields according to
   * the configured setting.
   *
   * @param field FieldDescriptor of the field to be mapped
   * @return      Corresponding kdb type
  */
  const KType GetRepeatedKdbType(const gpb::FieldDescriptor* field) const;

  /**
   * @brief Returns the kdb type of the specified map-key field
   *
   * Similar to GetKdbType() but checks KdbTypeSpecifier from the field option
   * MapKdbTypeSpecifier->key_type.  Also maps string proto fields according to
   * the configured setting.
   *
   * @param map_field FieldDescriptor of the parent map field
   * @param key_field FieldDescriptor of the map-key field
   * @return          Corresponding kdb type
  */
  const KType GetMapKeyKdbType(const gpb::FieldDescriptor* map_field, const gpb::FieldDescriptor* key_field) const;

  /**
   * @brief Returns the kdb type of the specified map-value field
   *
   * Similar to GetKdbType() but checks KdbTypeSpecifier from the field option
   * MapKdbTypeSpecifier->value_type.  Also maps string and bytes proto fields
   * according to the configured setting.
   *
   * @param map_field FieldDescriptor of the parent map field
   * @param key_field FieldDescriptor of the map-value field
   * @return          Corresponding kdb type
  */
  const KType GetMapValueKdbType(const gpb::FieldDescriptor* map_field, const gpb::FieldDescriptor* value_field) const;

  /**
   * @brief Returns whether KdbTypeSpecifier==GUID is specified for a non-map
   * field.
   *
   * Unlike the temporal KdbTypeSpecifiers which map to a basic
   * integer/floating, GUID has to be processed as a special case for the string
   * cpp types.
   *
   * Note: Map key/value GUID specifiers are determined from the constituent
   * dictionary lists which are created in advance.
   *
   * @param field FieldDescriptor of the field to be checked
   * @return True if GUID
  */
  bool IsKdbTypeGuid(const gpb::FieldDescriptor* field) const;

  /**
   * @brief Converts a GUID kdb object to an ascii hexidecimal formatted string
   * of length 32 (no separators)
   *
   * Although the protobuf 'bytes' wire type allow raw binary data to be sent,
   * 'string' has to be utf-8 encoded.  Furthermore only 'string' is permitted
   * as a map-key which makes mandating the use of 'bytes' for GUIDs too
   * restrictive.
   *
   * @param guid  16 character binary GUID
   * @return      ASCII hexidecimal formatted string
  */
  const std::string GuidToString(const U* guid) const;

  /**
   * @brief Converts a ascii hexidecimal formatted string of a GUID kdb object.
   *
   * @param field FieldDescriptor of the string field
   * @param guid  32 character ascii string GUID
   * @return      16 character binary GUID
  */
  const U GuidFromString(const gpb::FieldDescriptor* field, const std::string& guid) const;

  /**
   * @brief Return the currently configured kdb type mapping (symbol, char
   * array, byte array) for proto string fields.
   *
   * @return -11|4|10
  */
  KType GetStringKdbType(void) const;

  /**
   * @brief Return the currently configured kdb type mapping (symbol, char
   * array, byte array) for proto bytes fields.
   *
   * @return -11|4|10
  */
  KType GetBytesKdbType(void) const;

  /**
   * @brief Return the currently configured kdb type mapping (symbol, char
   * array, byte array) for proto string map key fields.
   *
   * @return -11|4|10
  */
  KType GetStringMapKeyKdbType(void) const;
};

} // namespace protobufkdb
} // namespace kx


#endif // __KDB_TYPES_H__
