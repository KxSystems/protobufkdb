#include "ScalarValues.h"
#include "TypeCheck.h"
#include "KdbTypes.h"


namespace kx {
namespace protobufkdb {

// Singleton instance
ScalarValues* ScalarValues::instance = nullptr;

const ScalarValues* ScalarValues::Instance()
{
  if (instance == nullptr)
    instance = new ScalarValues();

  return instance;
}

ScalarValues::ScalarValues()
{
  // Create arrays of getter/setter functions, indexed by enum values of gpb::FieldDescriptor::CppType
  //
  // Note:
  //   fns[0] is unused since enum values start from 1
  //   fns[CPPTYPE_MESSAGE] is not required since message is handled separately
  get_scalar_fns[gpb::FieldDescriptor::CPPTYPE_INT32] = &GetInt32;
  get_scalar_fns[gpb::FieldDescriptor::CPPTYPE_INT64] = &GetInt64;
  get_scalar_fns[gpb::FieldDescriptor::CPPTYPE_UINT32] = &GetUInt32;
  get_scalar_fns[gpb::FieldDescriptor::CPPTYPE_UINT64] = &GetUInt64;
  get_scalar_fns[gpb::FieldDescriptor::CPPTYPE_DOUBLE] = &GetDouble;
  get_scalar_fns[gpb::FieldDescriptor::CPPTYPE_FLOAT] = &GetFloat;
  get_scalar_fns[gpb::FieldDescriptor::CPPTYPE_BOOL] = &GetBool;
  get_scalar_fns[gpb::FieldDescriptor::CPPTYPE_ENUM] = &GetEnum;
  get_scalar_fns[gpb::FieldDescriptor::CPPTYPE_STRING] = &GetString;

  set_scalar_fns[gpb::FieldDescriptor::CPPTYPE_INT32] = &SetInt32;
  set_scalar_fns[gpb::FieldDescriptor::CPPTYPE_INT64] = &SetInt64;
  set_scalar_fns[gpb::FieldDescriptor::CPPTYPE_UINT32] = &SetUInt32;
  set_scalar_fns[gpb::FieldDescriptor::CPPTYPE_UINT64] = &SetUInt64;
  set_scalar_fns[gpb::FieldDescriptor::CPPTYPE_DOUBLE] = &SetDouble;
  set_scalar_fns[gpb::FieldDescriptor::CPPTYPE_FLOAT] = &SetFloat;
  set_scalar_fns[gpb::FieldDescriptor::CPPTYPE_BOOL] = &SetBool;
  set_scalar_fns[gpb::FieldDescriptor::CPPTYPE_ENUM] = &SetEnum;
  set_scalar_fns[gpb::FieldDescriptor::CPPTYPE_STRING] = &SetString;
}


// Get scalar functions
K ScalarValues::GetScalar(const gpb::Message& msg, const gpb::Reflection* refl, const gpb::FieldDescriptor* field) const
{
  // Scalar -> atom
  const auto cpp_type = field->cpp_type();
  assert(cpp_type >= 0 && cpp_type < gpb::FieldDescriptor::CPPTYPE_MESSAGE);
  K result = get_scalar_fns[cpp_type](msg, refl, field);

  // Update the atom type if the field has a KdbTypeSpecifier and it is
  // compatible
  result->t = KdbTypes::Instance()->GetScalarKdbType(field);
  return result;
}

K ScalarValues::GetInt32(SCALAR_VALUES_GET_ARGS)
{
  return ki(refl->GetInt32(msg, field));
}

K ScalarValues::GetInt64(SCALAR_VALUES_GET_ARGS)
{
  return kj(refl->GetInt64(msg, field));
}

K ScalarValues::GetUInt32(SCALAR_VALUES_GET_ARGS)
{
  return ki(refl->GetUInt32(msg, field));
}

K ScalarValues::GetUInt64(SCALAR_VALUES_GET_ARGS)
{
  return kj(refl->GetUInt64(msg, field));
}

K ScalarValues::GetDouble(SCALAR_VALUES_GET_ARGS)
{
  return kf(refl->GetDouble(msg, field));
}

K ScalarValues::GetFloat(SCALAR_VALUES_GET_ARGS)
{
  return ke(refl->GetFloat(msg, field));
}

K ScalarValues::GetBool(SCALAR_VALUES_GET_ARGS)
{
  return kb(refl->GetBool(msg, field));
}

K ScalarValues::GetEnum(SCALAR_VALUES_GET_ARGS)
{
  return ki(refl->GetEnumValue(msg, field));
}

K ScalarValues::GetString(SCALAR_VALUES_GET_ARGS)
{
  if (KdbTypes::Instance()->IsKdbTypeGuid(field))
    return ku(KdbTypes::Instance()->GuidFromString(field, refl->GetString(msg, field)));

  // Get the string or bytes field mapping: -KS|KC|KG
  KdbTypes::KType k_type = -KS;
  if (field->type() == gpb::FieldDescriptor::TYPE_STRING)
    k_type = KdbTypes::Instance()->GetStringKdbType();
  else if (field->type() == gpb::FieldDescriptor::TYPE_BYTES)
    k_type = KdbTypes::Instance()->GetBytesKdbType();

  if (k_type == -KS) {
    // Create symbol atom
    return ks((S)refl->GetString(msg, field).c_str());
  }

  // Create char list
  K result = kpn((S)refl->GetString(msg, field).c_str(), refl->GetString(msg, field).length());

  // Update list kdb type in case mapping to KG (kpn creates a KC list)
  result->t = k_type;

  return result;
}


// Set scalar functions
void ScalarValues::SetScalar(gpb::Message* msg, const gpb::Reflection* refl, const gpb::FieldDescriptor* field, K k_scalar) const
{
  // Atom -> scalar
  //
  // Determine the correct type from the KdbFieldSpecifier (if present) or
  // cpp_type
  const auto cpp_type = field->cpp_type();
  assert(cpp_type >= 0 && cpp_type < gpb::FieldDescriptor::CPPTYPE_MESSAGE);
  const auto k_type = KdbTypes::Instance()->GetScalarKdbType(field);

  // Check the atom has the same type as we expected.  For string or bytes proto
  // fields (other than GUID encoded into string), allow -KS|KC|KG to be used
  // interchangeably.
  if (k_type == -UU || cpp_type != gpb::FieldDescriptor::CPPTYPE_STRING ||
      (k_scalar->t != -KS && k_scalar->t != KC && k_scalar->t != KG))
    TYPE_CHECK_SCALAR(k_type != k_scalar->t, field->full_name(), k_type, k_scalar->t);

  return set_scalar_fns[cpp_type](msg, refl, field, k_scalar);
}

void ScalarValues::SetInt32(SCALAR_VALUES_SET_ARGS)
{
  refl->SetInt32(msg, field, k_scalar->i);
}

void ScalarValues::SetInt64(SCALAR_VALUES_SET_ARGS)
{
  refl->SetInt64(msg, field, k_scalar->j);
}

void ScalarValues::SetUInt32(SCALAR_VALUES_SET_ARGS)
{
  refl->SetUInt32(msg, field, k_scalar->i);
}

void ScalarValues::SetUInt64(SCALAR_VALUES_SET_ARGS)
{
  refl->SetUInt64(msg, field, k_scalar->j);
}

inline void ScalarValues::SetDouble(SCALAR_VALUES_SET_ARGS)
{
  refl->SetDouble(msg, field, k_scalar->f);
}

void ScalarValues::SetFloat(SCALAR_VALUES_SET_ARGS)
{
  refl->SetFloat(msg, field, k_scalar->e);
}

void ScalarValues::SetBool(SCALAR_VALUES_SET_ARGS)
{
  refl->SetBool(msg, field, k_scalar->g);
}

void ScalarValues::SetEnum(SCALAR_VALUES_SET_ARGS)
{
  refl->SetEnumValue(msg, field, k_scalar->i);
}

void ScalarValues::SetString(SCALAR_VALUES_SET_ARGS)
{
  if (KdbTypes::Instance()->IsKdbTypeGuid(field))
    refl->SetString(msg, field, KdbTypes::Instance()->GuidToString((U*)kG(k_scalar)));
  else {
    if (k_scalar->t == -KS) {
      // Deference k_scalar as symbol
      refl->SetString(msg, field, k_scalar->s);
    } else {
      // Deference k_scalar as char list
      refl->SetString(msg, field, std::string((S)kG(k_scalar), k_scalar->n));
    }
  }
}

} // namespace protobufkdb
} // namespace kx
