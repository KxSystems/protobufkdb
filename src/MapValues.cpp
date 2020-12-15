#include "MapValues.h"
#include "MessageFormat.h"
#include "TypeCheck.h"
#include "KdbTypes.h"


namespace kx {
namespace protobufkdb {

// Singleton instance
MapValues* MapValues::instance = nullptr;

const MapValues* MapValues::Instance()
{
  if (instance == nullptr)
    instance = new MapValues();

  return instance;
}

MapValues::MapValues()
{
  // Create arrays of getter/setter functions, indexed by enum values of
  // FieldDescriptor::CppType
  //
  // Note: fns[0] is unused since enum values start from 1
  get_map_element_fns[gpb::FieldDescriptor::CPPTYPE_INT32] = &GetInt32;
  get_map_element_fns[gpb::FieldDescriptor::CPPTYPE_INT64] = &GetInt64;
  get_map_element_fns[gpb::FieldDescriptor::CPPTYPE_UINT32] = &GetUInt32;
  get_map_element_fns[gpb::FieldDescriptor::CPPTYPE_UINT64] = &GetUInt64;
  get_map_element_fns[gpb::FieldDescriptor::CPPTYPE_DOUBLE] = &GetDouble;
  get_map_element_fns[gpb::FieldDescriptor::CPPTYPE_FLOAT] = &GetFloat;
  get_map_element_fns[gpb::FieldDescriptor::CPPTYPE_BOOL] = &GetBool;
  get_map_element_fns[gpb::FieldDescriptor::CPPTYPE_ENUM] = &GetEnum;
  get_map_element_fns[gpb::FieldDescriptor::CPPTYPE_STRING] = &GetString;
  get_map_element_fns[gpb::FieldDescriptor::CPPTYPE_MESSAGE] = &GetMessage;

  set_map_element_fns[gpb::FieldDescriptor::CPPTYPE_INT32] = &SetInt32;
  set_map_element_fns[gpb::FieldDescriptor::CPPTYPE_INT64] = &SetInt64;
  set_map_element_fns[gpb::FieldDescriptor::CPPTYPE_UINT32] = &SetUInt32;
  set_map_element_fns[gpb::FieldDescriptor::CPPTYPE_UINT64] = &SetUInt64;
  set_map_element_fns[gpb::FieldDescriptor::CPPTYPE_DOUBLE] = &SetDouble;
  set_map_element_fns[gpb::FieldDescriptor::CPPTYPE_FLOAT] = &SetFloat;
  set_map_element_fns[gpb::FieldDescriptor::CPPTYPE_BOOL] = &SetBool;
  set_map_element_fns[gpb::FieldDescriptor::CPPTYPE_ENUM] = &SetEnum;
  set_map_element_fns[gpb::FieldDescriptor::CPPTYPE_STRING] = &SetString;
  set_map_element_fns[gpb::FieldDescriptor::CPPTYPE_MESSAGE] = &SetMessage;
}

// A protobuf map:
//
//   map <KeyType, ValueType> map_field = 1;
//
// is internally represented in the following (wire compatible) format:
//
//  message MapFieldEntry {
//    KeyType key = 1;
//    ValueType value = 2;
//  }
//  repeated MapFieldEntry map_field_internal = 2;
//
// Unfortunately this makes converting between a proto map and kdb dictionary a
// real pain for various reasons:
// 1.  Unlike the other proto field types where you can build a single kdb
//     structure from each field (with iteration for repeated and recursion for
//     messages), maps requires building up two kdb lists with which to create
//     the dictionary.
// 2.  The data comes out of the map in the wrong order - breadth first in
//     key-value pairs.  The is no way to inspect just the map-key or map-value
//     vectors iteratively, similar to that for repeated fields.
// 3.  You cannot determine the key-type and value-type from the parent map
//     field.  This requires looking at the structure of the map's sub-message 
//     in advance.
K MapValues::GetMap(const gpb::Message& msg, const gpb::Reflection* refl, const gpb::FieldDescriptor* field, bool use_field_names) const
{
  // Map -> dictionary
  //
  // Inspect the sub-message so we can determine the correct types for the
  // key-list and value-list to be used by the dictionary.  Note that
  // message_type() returns the sub-message structure regardless of whether
  // there are any elements in the map.
  const auto map_desc = field->message_type();
  assert(map_desc->field_count() == 2);
  const auto keys_field = map_desc->field(0);
  const auto values_field = map_desc->field(1);
  const auto key_ktype = KdbTypes::Instance()->GetMapKeyKdbType(field, keys_field);
  const auto value_ktype = KdbTypes::Instance()->GetMapValueKdbType(field, values_field);

  // Create the key and values lists using the correct types and the map size
  const auto size = refl->FieldSize(msg, field);
  auto keys_list = ktn(key_ktype, size);
  auto values_list = ktn(value_ktype, size);

  // Iterate through all the sub-messages representing each key-value pair,
  // adding them to the dictionary key-list and value-list as we go 
  for (int i = 0; i < size; ++i) {
    const auto& map_msg = refl->GetRepeatedMessage(msg, field, i);
    const auto map_msg_refl = map_msg.GetReflection();
    const auto map_desc = map_msg.GetDescriptor();
    const auto key_element = map_desc->field(0);
    const auto value_element = map_desc->field(1);
    GetElement(map_msg, map_msg_refl, key_element, keys_list, i, true, use_field_names);
    GetElement(map_msg, map_msg_refl, value_element, values_list, i, false, use_field_names);
  }

  if (use_field_names && values_field->cpp_type() == gpb::FieldDescriptor::CPPTYPE_MESSAGE) {
    // Parsing a sub-message map-value with field names will have created a
    // mixed list of dictionaries in 'values_list'.  In order to convert this to
    // a flip table, we first add a dummy :: value to the end of the mixed
    // list.
    K k_null = ka(101);
    k_null->g = 0;
    jk(&values_list, k_null);

    // Then strip the off trailing :: using the kdb parser.  This will copy the
    // the kdb structure, restructuring it as a flip table.  The old version is
    // r0-ed by kdb and the result used to update 'values_list' with the new
    // version.
    values_list = k(0, (S)"{[x] -1 _ x}", values_list, (K)0);
  }

  // Create and return the dictionary
  return xD(keys_list, values_list);
}

// See GetMap() comments since they are similarly applicable
void MapValues::SetMap(gpb::Message* msg, const gpb::Reflection* refl, const gpb::FieldDescriptor* field, K k_dict, bool use_field_names) const
{
  // Dictionary -> map
  TYPE_CHECK_MAP(k_dict->t != 99, field->full_name(), k_dict->t);

  K keys_list = kK(k_dict)[0];
  K values_list = kK(k_dict)[1];

  const auto map_desc = field->message_type();
  assert(map_desc->field_count() == 2);
  const auto keys_field = map_desc->field(0);
  const auto values_field = map_desc->field(1);
  const auto key_ktype = KdbTypes::Instance()->GetMapKeyKdbType(field, keys_field);
  const auto value_ktype = KdbTypes::Instance()->GetMapValueKdbType(field, values_field);

  // Check the key list has the same type as we expected. For string or bytes
  // proto fields (other than GUID encoded into string), allow KS|0 to be used
  // interchangeably.
  if (key_ktype == UU || keys_field->cpp_type() != gpb::FieldDescriptor::CPPTYPE_STRING ||
    (keys_list->t != KS && keys_list->t != 0))
    TYPE_CHECK_MAP_ELEMENT(keys_list->t != key_ktype, keys_field->full_name(), key_ktype, keys_list->t);

  // Check the value list has the same type as we expected. For string or bytes
  // proto fields (other than GUID encoded into string), allow KS|0 to be used
  // interchangeably.
  if (value_ktype == UU || values_field->cpp_type() != gpb::FieldDescriptor::CPPTYPE_STRING ||
    (values_list->t != KS && values_list->t != 0)) {
    // Also, when using field names when map-value sub-messages, allow the kdb
    // data to be structured as a flip table
    if (!use_field_names || values_field->cpp_type() != gpb::FieldDescriptor::CPPTYPE_MESSAGE || values_list->t != 98)
      TYPE_CHECK_MAP_ELEMENT(values_list->t != value_ktype, values_field->full_name(), value_ktype, values_list->t);
  }
  
  if (!use_field_names || values_field->cpp_type() != gpb::FieldDescriptor::CPPTYPE_MESSAGE || values_list->t != 98) {
    // Simple case where values_list is not a flip table
    assert(keys_list->n == values_list->n);
    auto size = keys_list->n;

    for (int i = 0; i < size; ++i) {
      if (values_list->t != 0 || kK(values_list)[i]->t != 101) {
        auto map_msg = refl->AddMessage(msg, field);
        const auto map_msg_refl = map_msg->GetReflection();
        const auto map_desc = map_msg->GetDescriptor();
        const auto key_element = map_desc->field(0);
        const auto value_element = map_desc->field(1);
        SetElement(map_msg, map_msg_refl, key_element, keys_list, i, true, use_field_names);
        SetElement(map_msg, map_msg_refl, value_element, values_list, i, false, use_field_names);
      }
    }
  } else {
    // Map values are sub-messages with field names which has been structured as
    // a flip table.
    K flip_values = kK(values_list->k)[1];
    auto flip_length = kK(flip_values)[0]->n;
    for (auto i = 0; i < flip_length; ++i) {
      // Use the kdb parser to slice the flip table, giving us a dictionary for
      // each map-value submessage.
      K dict = k(0, (S)"{[x;y] x[y]}", r1(values_list), kj(i), (K)0);

      auto map_msg = refl->AddMessage(msg, field);
      const auto map_msg_refl = map_msg->GetReflection();
      const auto map_desc = map_msg->GetDescriptor();
      const auto key_element = map_desc->field(0);
      const auto value_element = map_desc->field(1);
      SetElement(map_msg, map_msg_refl, key_element, keys_list, i, true, use_field_names);
      MessageFormat::Instance()->SetMessage(map_msg_refl->MutableMessage(map_msg, value_element), dict, use_field_names);

      // Free the temporary slice
      r0(dict);
    }
  }
}


// Updates the already contructed key-list or value-list in place at the
// specified index
void MapValues::GetElement(MAP_VALUES_GET_ARGS) const
{
  const auto cpp_type = field->cpp_type();
  assert(cpp_type >= 0 && cpp_type <= gpb::FieldDescriptor::CPPTYPE_MESSAGE);
  get_map_element_fns[cpp_type](msg, refl, field, k_list, index, key_field, use_field_names);
}

// Get map element functions
void MapValues::GetInt32(MAP_VALUES_GET_ARGS)
{
  kI(k_list)[index] = refl->GetInt32(msg, field);
}

void MapValues::GetInt64(MAP_VALUES_GET_ARGS)
{
  kJ(k_list)[index] = refl->GetInt64(msg, field);
}

void MapValues::GetUInt32(MAP_VALUES_GET_ARGS)
{
  kI(k_list)[index] = refl->GetUInt32(msg, field);
}

void MapValues::GetUInt64(MAP_VALUES_GET_ARGS)
{
  kJ(k_list)[index] = refl->GetUInt64(msg, field);
}

void MapValues::GetDouble(MAP_VALUES_GET_ARGS)
{
  kF(k_list)[index] = refl->GetDouble(msg, field);
}

void MapValues::GetFloat(MAP_VALUES_GET_ARGS)
{
  kE(k_list)[index] = refl->GetFloat(msg, field);
}

void MapValues::GetBool(MAP_VALUES_GET_ARGS)
{
  kG(k_list)[index] = refl->GetBool(msg, field);
}

void MapValues::GetEnum(MAP_VALUES_GET_ARGS)
{
  kI(k_list)[index] = refl->GetEnumValue(msg, field);
}

void MapValues::GetString(MAP_VALUES_GET_ARGS)
{
  // MapKdbTypeSpecifier is only available on the parent map, not each map
  // element.  However it would already have been checked when creating the
  // key-list and value-list so check the list type instead.
  if (k_list->t == UU)
    kU(k_list)[index] = KdbTypes::Instance()->GuidFromString(field, refl->GetString(msg, field));
  else {
    // Get the string or bytes field mapping: -KS|KC|KG
    KdbTypes::KType k_type = -KS;
    if (key_field && field->type() == gpb::FieldDescriptor::TYPE_STRING)
      k_type = KdbTypes::Instance()->GetStringMapKeyKdbType();
    else if (field->type() == gpb::FieldDescriptor::TYPE_STRING)
      k_type = KdbTypes::Instance()->GetStringKdbType();
    else if (field->type() == gpb::FieldDescriptor::TYPE_BYTES)
      k_type = KdbTypes::Instance()->GetBytesKdbType();

    if (k_type == -KS) {
      // Populate symbol list
      kS(k_list)[index] = ss((S)refl->GetString(msg, field).c_str());
    } else {
      // Populate mixed list of strings
      K k_str = kpn((S)refl->GetString(msg, field).c_str(), refl->GetString(msg, field).length());

      // Update char list kdb type in case mapping to KG (kpn creates a KC list)
      k_str->t = k_type;
      kK(k_list)[index] = k_str;
    }
  }
}

void MapValues::GetMessage(MAP_VALUES_GET_ARGS)
{
  // Recurse into the sub-message through the MessageFormat public API.
  kK(k_list)[index] = MessageFormat::Instance()->GetMessage(refl->GetMessage(msg, field), use_field_names);
}


// Pulls the data from the key-list or value-list at the specified index and
// inserts it into the map
void MapValues::SetElement(MAP_VALUES_SET_ARGS) const
{
  const auto cpp_type = field->cpp_type();
  assert(cpp_type >= 0 && cpp_type <= gpb::FieldDescriptor::CPPTYPE_MESSAGE);
  // Don't need an element type check since that it done for the parent list
  set_map_element_fns[cpp_type](msg, refl, field, k_list, index, key_field, use_field_names);
}

// Set map element functions
void MapValues::SetInt32(MAP_VALUES_SET_ARGS)
{
  refl->SetInt32(msg, field, kI(k_list)[index]);
}

void MapValues::SetInt64(MAP_VALUES_SET_ARGS)
{
  refl->SetInt64(msg, field, kJ(k_list)[index]);
}

void MapValues::SetUInt32(MAP_VALUES_SET_ARGS)
{
  refl->SetUInt32(msg, field, kI(k_list)[index]);
}

void MapValues::SetUInt64(MAP_VALUES_SET_ARGS)
{
  refl->SetUInt64(msg, field, kJ(k_list)[index]);
}

void MapValues::SetDouble(MAP_VALUES_SET_ARGS)
{
  refl->SetDouble(msg, field, kF(k_list)[index]);
}

void MapValues::SetFloat(MAP_VALUES_SET_ARGS)
{
  refl->SetFloat(msg, field, kE(k_list)[index]);
}

void MapValues::SetBool(MAP_VALUES_SET_ARGS)
{
  refl->SetBool(msg, field, kG(k_list)[index]);
}

void MapValues::SetEnum(MAP_VALUES_SET_ARGS)
{
  refl->SetEnumValue(msg, field, kI(k_list)[index]);
}

void MapValues::SetString(MAP_VALUES_SET_ARGS)
{
  // MapKdbTypeSpecifier is only available on the parent map, not each map
  // element.  However it would already have been checked when creating the
  // key-list and value-list so check the list type instead.
  if (k_list->t == UU)
    refl->SetString(msg, field, KdbTypes::Instance()->GuidToString(&kU(k_list)[index]));
  else {
    if (k_list->t == KS) {
      // Deference k_list as symbol list
      refl->SetString(msg, field, kS(k_list)[index]);
    } else {
      // Deference k_list as mixed list of strings
      auto k_str = kK(k_list)[index];

      // Check each mixed list item is the correct string type, allowing
      // -KS|KC|KG to be used interchangeably
      if (k_str->t != -KS && k_str->t != KC && k_str->t != KG) {
        // Get the correct string or bytes field mapping for the TypeCheck error
        KdbTypes::KType k_type = -KS;
        if (key_field && field->type() == gpb::FieldDescriptor::TYPE_STRING)
          k_type = KdbTypes::Instance()->GetStringMapKeyKdbType();
        else if (field->type() == gpb::FieldDescriptor::TYPE_STRING)
          k_type = KdbTypes::Instance()->GetStringKdbType();
        else if (field->type() == gpb::FieldDescriptor::TYPE_BYTES)
          k_type = KdbTypes::Instance()->GetBytesKdbType();

        TYPE_CHECK_MAP_STRING_ELEMENT(k_type != k_str->t, field->full_name(), k_type, k_str->t);
      }

      if (k_str->t == -KS)
        refl->SetString(msg, field, k_str->s);
      else
        refl->SetString(msg, field, std::string((S)kG(k_str), k_str->n));
    }
  }
}

void MapValues::SetMessage(MAP_VALUES_SET_ARGS)
{
  // Recurse into the sub-message through the MessageFormat public API.
  MessageFormat::Instance()->SetMessage(refl->MutableMessage(msg, field), kK(k_list)[index], use_field_names);
}

} // namespace protobufkdb
} // namespace kx
