#include "RepeatedValues.h"
#include "TypeCheck.h"
#include "KdbTypes.h"


// Singleton instance
RepeatedValues* RepeatedValues::instance = nullptr;

const RepeatedValues* RepeatedValues::Instance()
{
  if (instance == nullptr)
    instance = new RepeatedValues();
  return instance;
}

RepeatedValues::RepeatedValues()
{
  // Create arrays of getter/setter functions, indexed by enum values of gpb::FieldDescriptor::CppType
  //
  // Note:
  //   fns[0] is unused since enum values start from 1
  //   fns[CPPTYPE_MESSAGE] is not required since message is handled separately
  get_repeated_fns[gpb::FieldDescriptor::CPPTYPE_INT32] = &GetRepeatedInt32;
  get_repeated_fns[gpb::FieldDescriptor::CPPTYPE_INT64] = &GetRepeatedInt64;
  get_repeated_fns[gpb::FieldDescriptor::CPPTYPE_UINT32] = &GetRepeatedUInt32;
  get_repeated_fns[gpb::FieldDescriptor::CPPTYPE_UINT64] = &GetRepeatedUInt64;
  get_repeated_fns[gpb::FieldDescriptor::CPPTYPE_DOUBLE] = &GetRepeatedDouble;
  get_repeated_fns[gpb::FieldDescriptor::CPPTYPE_FLOAT] = &GetRepeatedFloat;
  get_repeated_fns[gpb::FieldDescriptor::CPPTYPE_BOOL] = &GetRepeatedBool;
  get_repeated_fns[gpb::FieldDescriptor::CPPTYPE_ENUM] = &GetRepeatedEnum;
  get_repeated_fns[gpb::FieldDescriptor::CPPTYPE_STRING] = &GetRepeatedString;

  set_repeated_fns[gpb::FieldDescriptor::CPPTYPE_INT32] = &SetRepeatedInt32;
  set_repeated_fns[gpb::FieldDescriptor::CPPTYPE_INT64] = &SetRepeatedInt64;
  set_repeated_fns[gpb::FieldDescriptor::CPPTYPE_UINT32] = &SetRepeatedUInt32;
  set_repeated_fns[gpb::FieldDescriptor::CPPTYPE_UINT64] = &SetRepeatedUInt64;
  set_repeated_fns[gpb::FieldDescriptor::CPPTYPE_DOUBLE] = &SetRepeatedDouble;
  set_repeated_fns[gpb::FieldDescriptor::CPPTYPE_FLOAT] = &SetRepeatedFloat;
  set_repeated_fns[gpb::FieldDescriptor::CPPTYPE_BOOL] = &SetRepeatedBool;
  set_repeated_fns[gpb::FieldDescriptor::CPPTYPE_ENUM] = &SetRepeatedEnum;
  set_repeated_fns[gpb::FieldDescriptor::CPPTYPE_STRING] = &SetRepeatedString;
}


// Get repeated functions
K RepeatedValues::GetRepeated(const gpb::Message& msg, const gpb::Reflection* refl, const gpb::FieldDescriptor* field) const
{
  // Repeated -> simple list
  //
  // Determine the list type from the KdbFieldSpecifier (if present) or cpp_type
  const auto cpp_type = field->cpp_type();
  assert(cpp_type >= 0 && cpp_type < gpb::FieldDescriptor::CPPTYPE_MESSAGE);
  const auto k_type = KdbTypes::Instance()->GetKdbType(field);

  // Create the simple list using this type and of length equal to the number of
  // repeated items
  K out_list = ktn(k_type, refl->FieldSize(msg, field));
  get_repeated_fns[cpp_type](msg, refl, field, out_list);
  return out_list;
}

void RepeatedValues::GetRepeatedInt32(REPEATED_VALUES_GET_ARGS)
{
  for (auto i = 0; i < refl->FieldSize(msg, field); ++i)
    kI(out_list)[i] = refl->GetRepeatedInt32(msg, field, i);
}

void RepeatedValues::GetRepeatedInt64(REPEATED_VALUES_GET_ARGS)
{
  for (auto i = 0; i < refl->FieldSize(msg, field); ++i)
    kJ(out_list)[i] = refl->GetRepeatedInt64(msg, field, i);
}

void RepeatedValues::GetRepeatedUInt32(REPEATED_VALUES_GET_ARGS)
{
  for (auto i = 0; i < refl->FieldSize(msg, field); ++i)
    kI(out_list)[i] = refl->GetRepeatedUInt32(msg, field, i);
}

void RepeatedValues::GetRepeatedUInt64(REPEATED_VALUES_GET_ARGS)
{
  for (auto i = 0; i < refl->FieldSize(msg, field); ++i)
    kJ(out_list)[i] = refl->GetRepeatedUInt64(msg, field, i);
}

void RepeatedValues::GetRepeatedDouble(REPEATED_VALUES_GET_ARGS)
{
  for (auto i = 0; i < refl->FieldSize(msg, field); ++i)
    kF(out_list)[i] = refl->GetRepeatedDouble(msg, field, i);
}

void RepeatedValues::GetRepeatedFloat(REPEATED_VALUES_GET_ARGS)
{
  for (auto i = 0; i < refl->FieldSize(msg, field); ++i)
    kE(out_list)[i] = refl->GetRepeatedFloat(msg, field, i);
}

void RepeatedValues::GetRepeatedBool(REPEATED_VALUES_GET_ARGS)
{
  for (auto i = 0; i < refl->FieldSize(msg, field); ++i)
    kG(out_list)[i] = refl->GetRepeatedBool(msg, field, i);
}

void RepeatedValues::GetRepeatedEnum(REPEATED_VALUES_GET_ARGS)
{
  for (auto i = 0; i < refl->FieldSize(msg, field); ++i)
    kI(out_list)[i] = refl->GetRepeatedEnumValue(msg, field, i);
}

void RepeatedValues::GetRepeatedString(REPEATED_VALUES_GET_ARGS)
{
  if (KdbTypes::Instance()->IsKdbTypeGuid(field)) {
    for (auto i = 0; i < refl->FieldSize(msg, field); ++i)
      kU(out_list)[i] = KdbTypes::Instance()->GuidFromString(refl->GetRepeatedString(msg, field, i));
  } else {
    for (auto i = 0; i < refl->FieldSize(msg, field); ++i)
      kS(out_list)[i] = ss((S)refl->GetRepeatedString(msg, field, i).c_str());
  }
}


// Set repeated functions
void RepeatedValues::SetRepeated(gpb::Message* msg, const gpb::Reflection* refl, const gpb::FieldDescriptor* field, K k_repeated) const
{
  // Simple list -> repeated
  //
  // Determine the correct list type from the KdbFieldSpecifier (if present) or
  // cpp_type
  const auto cpp_type = field->cpp_type();
  assert(cpp_type >= 0 && cpp_type < gpb::FieldDescriptor::CPPTYPE_MESSAGE);
  const auto k_type = KdbTypes::Instance()->GetKdbType(field);

  // Check the list has the same type as we expected
  TYPE_CHECK_REPEATED(k_type != k_repeated->t, field->full_name(), k_type, k_repeated->t);
  set_repeated_fns[cpp_type](msg, refl, field, k_repeated);
}

void RepeatedValues::SetRepeatedInt32(REPEATED_VALUES_SET_ARGS)
{
  for (auto i = 0; i < in_list->n; ++i)
    refl->AddInt32(msg, field, kI(in_list)[i]);
}

void RepeatedValues::SetRepeatedInt64(REPEATED_VALUES_SET_ARGS)
{
  for (auto i = 0; i < in_list->n; ++i)
    refl->AddInt64(msg, field, kJ(in_list)[i]);
}

void RepeatedValues::SetRepeatedUInt32(REPEATED_VALUES_SET_ARGS)
{
  for (auto i = 0; i < in_list->n; ++i)
    refl->AddUInt32(msg, field, kI(in_list)[i]);
}

void RepeatedValues::SetRepeatedUInt64(REPEATED_VALUES_SET_ARGS)
{
  for (auto i = 0; i < in_list->n; ++i)
    refl->AddUInt64(msg, field, kJ(in_list)[i]);
}

void RepeatedValues::SetRepeatedDouble(REPEATED_VALUES_SET_ARGS)
{
  for (auto i = 0; i < in_list->n; ++i)
    refl->AddDouble(msg, field, kF(in_list)[i]);
}

void RepeatedValues::SetRepeatedFloat(REPEATED_VALUES_SET_ARGS)
{
  for (auto i = 0; i < in_list->n; ++i)
    refl->AddFloat(msg, field, kE(in_list)[i]);
}

void RepeatedValues::SetRepeatedBool(REPEATED_VALUES_SET_ARGS)
{
  for (auto i = 0; i < in_list->n; ++i)
    refl->AddBool(msg, field, kG(in_list)[i]);
}

void RepeatedValues::SetRepeatedEnum(REPEATED_VALUES_SET_ARGS)
{
  for (auto i = 0; i < in_list->n; ++i)
    refl->AddEnumValue(msg, field, kI(in_list)[i]);
}

void RepeatedValues::SetRepeatedString(REPEATED_VALUES_SET_ARGS)
{
  if (KdbTypes::Instance()->IsKdbTypeGuid(field)) {
    for (auto i = 0; i < in_list->n; ++i)
      refl->AddString(msg, field, KdbTypes::Instance()->GuidToString(&kU(in_list)[i]));
  } else {
    for (auto i = 0; i < in_list->n; ++i)
      refl->AddString(msg, field, kS(in_list)[i]);
  }

}
