#include "KdbTypes.h"
#include "TypeCheck.h"


// Singleton instance
KdbTypes* KdbTypes::instance = nullptr;

const KdbTypes* KdbTypes::Instance()
{
  if (instance == nullptr)
    instance = new KdbTypes();

  return instance;
}

inline const KdbTypes::KType KdbTypes::Cpp2KdbType(const gpb::FieldDescriptor::CppType type) const
{
  assert(type > 0 && type <= gpb::FieldDescriptor::MAX_CPPTYPE);
  return cpp_ktype[type];
}

inline const KdbTypes::KType KdbTypes::Specifier2KdbType(const KdbTypeSpecifier type) const
{
  assert(type > KdbTypeSpecifier::DEFAULT && type < KdbTypeSpecifier::KDBTYPE_LEN);
  return specifier_ktype[type];
}

inline const KdbTypes::KType KdbTypes::CompatibleKdbType(const KdbTypeSpecifier type) const
{
  assert(type > KdbTypeSpecifier::DEFAULT && type < KdbTypeSpecifier::KDBTYPE_LEN);
  return compatible_ktype[type];
}

const KdbTypes::KType KdbTypes::GetKdbType(const gpb::FieldDescriptor* field) const
{
  // Check if the KdbTypeSpecifier field options extension is present on this
  // field and if so determine the correct kdb type from it.
  if (field->options().HasExtension(kdb_type)) {
    KdbTypeSpecifier mapping = field->options().GetExtension(kdb_type);
    if (mapping != KdbTypeSpecifier::DEFAULT) {
      const auto base = Cpp2KdbType(field->cpp_type());
      const auto requested = CompatibleKdbType(mapping);
      TYPE_CHECK_COMPATIBLE(base != requested, field->full_name(), field->cpp_type_name(), base, requested);

      return Specifier2KdbType(mapping);
    }
  }

  // No field option so determine the kdb type from the field's cpp type
  return Cpp2KdbType(field->cpp_type());
}

const KdbTypes::KType KdbTypes::GetMapKeyKdbType(const gpb::FieldDescriptor* map_field, const gpb::FieldDescriptor* key_field) const
{
  // Check if the MapKdbTypeSpecifier field options extension is present on the
  // parent map field and if so determine the correct kdb type to use from
  // MapKdbTypeSpecifier->key_type.
  if (map_field->options().HasExtension(map_kdb_type)) {
    MapKdbTypeSpecifier mapping = map_field->options().GetExtension(map_kdb_type);
    KdbTypeSpecifier key_type = mapping.key_type();
    if (key_type != KdbTypeSpecifier::DEFAULT) {
      const auto base = Cpp2KdbType(key_field->cpp_type());
      const auto requested = CompatibleKdbType(key_type);
      TYPE_CHECK_COMPATIBLE(base != requested, key_field->full_name(), key_field->cpp_type_name(), base, requested);

      return Specifier2KdbType(key_type);
    }
  }

  // No field option so determine the kdb type from the map-key field's cpp type
  return Cpp2KdbType(key_field->cpp_type());
}

const KdbTypes::KType KdbTypes::GetMapValueKdbType(const gpb::FieldDescriptor* map_field, const gpb::FieldDescriptor* value_field) const
{
  // Check if the MapKdbTypeSpecifier field options extension is present on the
  // parent map field and if so determine the correct kdb type to use from
  // MapKdbTypeSpecifier->value_type.
  if (map_field->options().HasExtension(map_kdb_type)) {
    MapKdbTypeSpecifier mapping = map_field->options().GetExtension(map_kdb_type);
    KdbTypeSpecifier value_type = mapping.value_type();
    if (value_type != KdbTypeSpecifier::DEFAULT) {
      const auto base = Cpp2KdbType(value_field->cpp_type());
      const auto requested = CompatibleKdbType(value_type);
      TYPE_CHECK_COMPATIBLE(base != requested, value_field->full_name(), value_field->cpp_type_name(), base, requested);

      return Specifier2KdbType(value_type);
    }
  }

  // No field option so determine the kdb type from the map-value field's cpp type
  return Cpp2KdbType(value_field->cpp_type());
}

bool KdbTypes::IsKdbTypeGuid(const gpb::FieldDescriptor* field) const
{
  return field->options().HasExtension(kdb_type) &&
    field->options().GetExtension(kdb_type) == KdbTypeSpecifier::GUID;
}

const std::string KdbTypes::GuidToString(const U* guid) const
{
  // ASCII offset for alpha hex chars
  static const char char_a_base = 'a' - 10;
  std::string result;
  for (size_t i = 0; i < sizeof(U); ++i) {
    auto higher = guid->g[i] / 16;
    result += higher + (higher > 9 ? char_a_base : '0');
    auto lower = guid->g[i] % 16;
    result += lower + (lower > 9 ? char_a_base : '0');
  }
  return result;
}

const U KdbTypes::GuidFromString(const std::string& guid) const
{
  // ASCII offsets for alpha hex chars
  static const char char_a_base = 'a' - 10;
  static const char char_A_base = 'A' - 10;
  U result;
  for (size_t i = 0; i < sizeof(U); ++i) {
    auto higher = guid[i * 2];
    higher -= (higher >= 'a' ? char_a_base : (higher >= 'A' ? char_A_base : '0'));
    auto lower = guid[i * 2 + 1];
    lower -= (lower >= 'a' ? char_a_base : (lower >= 'A' ? char_A_base : '0'));
    result.g[i] = (higher << 4) | lower;
  }
  return result;
}
