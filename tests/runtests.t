// runtests.t

\l q/protobufkdb.q
\l tests/test_helper_function.q

\d .protobufkdb

-1! "Test scalars with file";

// Pass correct data
scalars_expected:(1i;2i;3j;4j;5f;6e;1b;2i;`string);
saveMessage[`ScalarTest;`scalar_file;scalars_expected];
.test.ASSERT_TRUE[loadMessage; (`ScalarTest; `scalar_file); scalars_expected]

// Pass enlist for scalar
scalars_enlist:(1i;enlist 2i;3j;4j;5f;6e;1b;1i;`string);
.test.ASSERT_ERROR[saveMessage; (`ScalarTest; `scalar_file; scalars_enlist)]

// Pass different type scalar
scalars_wrong_type:(1i;2i;3j;4f;5f;6e;1b;0i;`string);
.test.ASSERT_ERROR[saveMessage; (`ScalarTest; `scalar_file; scalars_wrong_type)]

// Pass insufficient data
scalars_short:(2i;3j;4j;5f;6e;1b;0i;`string);
.test.ASSERT_ERROR[saveMessage; (`ScalarTest; `scalar_file; scalars_short)]

// Pass atom data
scalar_atom:1i;
.test.ASSERT_ERROR[saveMessage; (`ScalarTest; `scalar_file; scalar_atom)]

-1 "Test scalars with array";

// Pass correct data
array:serializeArray[`ScalarTest; scalars_expected];
.test.ASSERT_TRUE[parseArray; (`ScalarTest; array); scalars_expected]

// Pass enlist
scalars_enlist:(1i;2i;3j;enlist 4j;5f;6e;1b;1i;`string);
.test.ASSERT_ERROR[serializeArray; (`ScalarTest; scalars_enlist)]

// Pass wrong type data
scalars_wrong_type:(1i;2i;3j;4j;5f;6f;1b;0i;`string);
.test.ASSERT_ERROR[serializeArray; (`ScalarTest; scalars_wrong_type)]

// Pass insufficient data
scalars_short:(1i;2i;3j;4j;5f;6e;1b;`string);
.test.ASSERT_ERROR[serializeArray; (`ScalarTest; scalars_short)]

// Pass atom data
.test.ASSERT_ERROR[serializeArray; (`ScalarTest; scalar_atom)]

-1! "Test repeated with file";

// Pass correct data
repeated_expected:scalars_expected ,' scalars_expected;
saveMessage[`RepeatedTest; `repeated_file; repeated_expected];
.test.ASSERT_TRUE[loadMessage; (`RepeatedTest; `repeated_file); repeated_expected]

// Pass scalar data
.test.ASSERT_ERROR[saveMessage; (`RepeatedTest; `repeated_file; scalars_expected)]

// Pass wrong type data
repeated_wrong_type:scalars_wrong_type ,' scalars_wrong_type;
.test.ASSERT_ERROR[saveMessage; (`RepeatedTest; `repeated_file; repeated_wrong_type)]

// Pass insufficient data
repeated_short:(-1 _ scalars_expected), -1 _ scalars_expected;
.test.ASSERT_ERROR[saveMessage; (`RepeatedTest; `repeated_file; repeated_short)]

// Pass simple list data
repeated_simple:1 2 3i;
.test.ASSERT_ERROR[saveMessage; (`RepeatedTest; `repeated_file; repeated_simple)]

-1 "Test repeated with array";

// Pass correct data
array:serializeArray[`RepeatedTest; repeated_expected];
.test.ASSERT_TRUE[parseArray; (`RepeatedTest; array); repeated_expected]

// Pass scalar data
.test.ASSERT_ERROR[parseArray; (`RepeatedTest; scalars_expected)]

// Pass wrong type data
.test.ASSERT_ERROR[serializeArray; (`RepeatedTest; repeated_wrong_type)]

// Pass insufficient data
.test.ASSERT_ERROR[serializeArray; (`RepeatedTest; repeated_short)]

// Pass simple list data
.test.ASSERT_ERROR[serializeArray; (`RepeatedTest; repeated_simple)]

-1 "Test submessage with file";

// Pass correct data
submessage_expected:(scalars_expected;enlist repeated_expected);
saveMessage[`SubMessageTest; `submessage_file; submessage_expected];
.test.ASSERT_TRUE[loadMessage; (`SubMessageTest; `submessage_file); submessage_expected]

// Pass non-repeated submessage
submessage_nonrepeated:(scalars_expected; repeated_expected);
.test.ASSERT_ERROR[saveMessage; (`SubMessageTest; `submessage_file; submessage_nonrepeated)]

// Pass insufficient message
submessage_short:enlist scalars_expected;
.test.ASSERT_ERROR[saveMessage; (`SubMessageTest; `submessage_file; submessage_short)]

-1 "Test submessage with array";

// Pass correct data
array:serializeArray[`SubMessageTest; submessage_expected];
.test.ASSERT_TRUE[parseArray; (`SubMessageTest; array); submessage_expected]

// Pass non-repeated submessage
.test.ASSERT_ERROR[serializeArray; (`SubMessageTest; submessage_nonrepeated)]

// Pass insufficient message
submessage_short:2#enlist repeated_expected;
.test.ASSERT_ERROR[serializeArray; (`SubMessageTest; submessage_short)]

-1 "Test map with file";

// Protobuf maps are unordered and unsorted so use single item lists for each dictionary 
// element to perform a simple equality check.
map:((enlist 1i)!(enlist 2j);(enlist 3i)!(enlist 4j);(enlist 5j)!(enlist 6f);(enlist 7j)!(enlist 8e);(enlist 0b)!(enlist 1i);(enlist `one)!(enlist scalars_expected);(enlist `three)!(enlist submessage_expected));
//map:(1 2i!3 4j;5 6i!7 8j;1 2j!3 4f;5 6j!7 8e;01b!2 1i;(`one,`two)!(scalars;scalars);(`three,`four)!(submessage;submessage))
saveMessage[`MapTest; `map_file; map];
.test.ASSERT_TRUE[loadMessage; (`MapTest; `map_file); map]

// Pass wrong type key
map_wrong_key:((enlist 1i)!(enlist 2j);(enlist 0b)!(enlist 4j);(enlist 5j)!(enlist 6f);(enlist 7i)!(enlist 8e);(enlist 0b)!(enlist 1i);(enlist `one)!(enlist scalars_expected);(enlist `three)!(enlist submessage_expected));
.test.ASSERT_ERROR[saveMessage; (`MapTest;  `map_file; map_wrong_key)]

// Pass wrong value type
map_wrong_value:((enlist 1i)!(enlist 2j);(enlist 3i)!(enlist 4j);(enlist 5j)!(enlist 6f);(enlist 7j)!(enlist 8e);(enlist 0b)!(enlist 1i);(enlist `one)!(enlist repeated_expected);(enlist `three)!(enlist submessage_expected));
.test.ASSERT_ERROR[saveMessage; (`MapTest;  `map_file; map_wrong_value)]

-1 "Test map with array";

// Pass correct data
array:serializeArray[`MapTest; map];
.test.ASSERT_TRUE[parseArray; (`MapTest; array); map]

// Pass wrong type key
map_wrong_key:((enlist 1j)!(enlist 2j);(enlist 3i)!(enlist 4j);(enlist 5j)!(enlist 6f);(enlist 7j)!(enlist 8e);(enlist 0h)!(enlist 1i);(enlist `one)!(enlist scalars_expected);(enlist `three)!(enlist submessage_expected))
.test.ASSERT_ERROR[serializeArray; (`MapTest; map_wrong_key)]

// Pass wrong value type
map_wrong_value:((enlist 1i)!(enlist 2j);(enlist 3i)!(enlist 4j);(enlist 5j)!(enlist 6f);(enlist 7j)!(enlist 8f);(enlist 0b)!(enlist 1i);(enlist `one)!(enlist repeated_expected);(enlist `three)!(enlist submessage_expected))
.test.ASSERT_ERROR[serializeArray; (`MapTest;  map_wrong_value)]

-1 "Test scalar specifiers with file";

// Pass correct data
scalar_specifiers:(2020.01.01D12:34:56.123456789; 2020.01m; 2020.01.01; 2020.01.01T12:34:56.123; 12:34:56.123456789; 12:34; 12:34:56; 12:34:56.123; (1?0Ng)0);
saveMessage[`ScalarSpecifiersTest; `scalar_specifiers_file; scalar_specifiers];
.test.ASSERT_TRUE[loadMessage; (`ScalarSpecifiersTest; `scalar_specifiers_file); scalar_specifiers]

// Pass wrong type (compatible in q context but not in protobuf)
scalar_specifiers_compatible:(631197296123456789; 240i; 73051; 7305.524; 45296123456789; 754; 45296; 45296123i; (1?0Ng)0);
.test.ASSERT_ERROR[saveMessage; (`ScalarSpecifiersTest; `scalar_specifiers_file; scalar_specifiers_compatible)]

-1 "Test scalar specifiers with array";

//Pass correct data
array:serializeArray[`ScalarSpecifiersTest;scalar_specifiers];
.test.ASSERT_TRUE[parseArray; (`ScalarSpecifiersTest; array); scalar_specifiers]

// Pass wrong type (compatible in q context but not in protobuf)
.test.ASSERT_ERROR[saveMessage; (`ScalarSpecifiersTest; `scalar_specifiers_file; scalar_specifiers_compatible)]

-1 "Test repeated specifiers with file";

// Pass correct data
repeated_specifiers:scalar_specifiers,'scalar_specifiers;
saveMessage[`RepeatedSpecifiersTest;`repeated_specifiers_file;repeated_specifiers];
.test.ASSERT_TRUE[loadMessage; (`RepeatedSpecifiersTest; `repeated_specifiers_file); repeated_specifiers]

// Pass wrong type and correct type (compatible in q context but not in protobuf)
repeated_specifiers_mixture:scalar_specifiers ,' scalar_specifiers_compatible;
.test.ASSERT_ERROR[saveMessage; (`RepeatedSpecifiersTest; `repeated_specifiers_file; repeated_specifiers_mixture)]

-1 "Test repeated specifiers with array";

// Pass correct data
array:serializeArray[`RepeatedSpecifiersTest;repeated_specifiers];
.test.ASSERT_TRUE[parseArray; (`RepeatedSpecifiersTest; array); repeated_specifiers]

// Pass wrong type and speciiers
.test.ASSERT_ERROR[serializeArray; (`RepeatedSpecifiersTest; repeated_specifiers_mixture)]

-1 "Test map specifiers with file";

// Pass correct data
map_specifiers:((enlist 2020.01.01D12:34:56.123456789)!(enlist 2020.01m);(enlist 2020.01.01)!(enlist 2020.01.01T12:34:56.123);(enlist 12:34:56.123456789)!(enlist 12:34);(enlist 12:34:56)!(enlist 12:34:56.123);(1?0Ng)!(1?0Ng));
saveMessage[`MapSpecifiersTest;`map_specifiers_file;map_specifiers];
.test.ASSERT_TRUE[loadMessage; (`MapSpecifiersTest; `map_specifiers_file); map_specifiers]

// Pass wrong type (compatible in q context but not in protobuf)
map_specifiers_compatible:((enlist 631197296123456789)!(enlist 240i);(enlist 7305i)!(enlist 7305.524);(enlist 45296123456789)!(enlist 754);(enlist 45296)!(enlist 45296123i);(1?0Ng)!(1?0Ng));
.test.ASSERT_ERROR[saveMessage; (`MapSpecifiersTest; `map_specifiers_file; map_specifiers_compatible)]

-1 "Test map specifiers with array";

// Pass correct data
array:serializeArray[`MapSpecifiersTest; map_specifiers];
.test.ASSERT_TRUE[parseArray; (`MapSpecifiersTest; array); map_specifiers]

// Pass wrong type (compatible in q context but not in protobuf)
.test.ASSERT_ERROR[serializeArray; (`MapSpecifiersTest; map_specifiers_compatible)]

-1! "Test oneof permutations";

oneof1:(1.1f;();();`str);
oneof2:(();12:34:56;();`str);
oneof3:(();();(1j; 2.1 2.2f);`str);
oneofnone:(();();();`str);
oneofwrong:(42i; (); (); `str);

.test.ASSERT_TRUE[parseArray; (`OneofTest; serializeArray[`OneofTest;oneof1]); oneof1]
.test.ASSERT_TRUE[parseArray; (`OneofTest; serializeArray[`OneofTest;oneof2]); oneof2]
.test.ASSERT_TRUE[parseArray; (`OneofTest; serializeArray[`OneofTest;oneof3]); oneof3]
.test.ASSERT_TRUE[parseArray; (`OneofTest; serializeArray[`OneofTest;oneofnone]); oneofnone]
.test.ASSERT_ERROR[serializeArray; (`OneofTest; oneofwrong)]

// If mulitple oneofs are set, only the last is populated
oneofall:(1.1f;12:34:56;(1j; 2.1 2.2f);`str);
.test.ASSERT_TRUE[parseArray; (`OneofTest; serializeArray[`OneofTest; oneofall]); oneof3]