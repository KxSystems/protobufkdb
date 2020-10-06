// test.t
// Test both compliled schema and dynamically imported schema

-1 "\n+----------|| Load protobufkdb library ||----------+\n";

\l q/protobufkdb.q
\l tests/test_helper_function.q

// Move to protobuf namespace
\d .protobufkdb

-1 "\n+----------|| Test import of dynamic schema files ||----------+\n";

addProtoImportPath["proto"];
importProtoFile["tests_dynamic.proto"];
.test.ASSERT_ERROR[importProtoFile; enlist "not_exist.proto"; "Import error: File not found"]

-1 "\n+----------|| Test scalars with file ||----------+\n";

-1 "<--- Pass correct data --->";

scalars_expected:(1i;2i;3j;4j;5f;6e;1b;2i;`string);

saveMessage[`ScalarTest;`scalar_file;scalars_expected];
.test.ASSERT_TRUE[loadMessage; (`ScalarTest; `scalar_file); scalars_expected]

saveMessage[`ScalarTestDynamic;`scalar_file;scalars_expected];
.test.ASSERT_TRUE[loadMessage; (`ScalarTestDynamic; `scalar_file); scalars_expected]

-1 "<--- Pass enlist for scalar --->";

scalars_enlist:(1i;enlist 2i;3j;4j;5f;6e;1b;1i;`string);

.test.ASSERT_ERROR[saveMessage; (`ScalarTest; `scalar_file; scalars_enlist); "Invalid scalar type"]

.test.ASSERT_ERROR[saveMessage; (`ScalarTestDynamic; `scalar_file; scalars_enlist); "Invalid scalar type"]

-1 "<--- Pass different type scalar --->";

scalars_wrong_type:(1i;2i;3j;4f;5f;6e;1b;0i;`string);

.test.ASSERT_ERROR[saveMessage; (`ScalarTest; `scalar_file; scalars_wrong_type); "Invalid scalar type"]

.test.ASSERT_ERROR[saveMessage; (`ScalarTestDynamic; `scalar_file; scalars_wrong_type); "Invalid scalar type"]

-1 "<--- Pass insufficient data --->";

scalars_short:(2i;3j;4j;5f;6e;1b;0i;`string);

.test.ASSERT_ERROR[saveMessage; (`ScalarTest; `scalar_file; scalars_short); "Incorrect number of fields"]

.test.ASSERT_ERROR[saveMessage; (`ScalarTestDynamic; `scalar_file; scalars_short); "Incorrect number of fields"]

-1 "<--- Pass atom data --->";

scalar_atom:1i;

.test.ASSERT_ERROR[saveMessage; (`ScalarTest; `scalar_file; scalar_atom); "Invalid message type"]

.test.ASSERT_ERROR[saveMessage; (`ScalarTestDynamic; `scalar_file; scalar_atom); "Invalid message type"]

-1 "\n+----------|| Test scalars with array ||----------+\n";

-1 "<--- Pass correct data --->";

array:serializeArray[`ScalarTest; scalars_expected];

.test.ASSERT_TRUE[parseArray; (`ScalarTest; array); scalars_expected]

.test.ASSERT_TRUE[parseArray; (`ScalarTestDynamic; array); scalars_expected]

-1 "<--- Pass enlist --->";

.test.ASSERT_ERROR[serializeArray; (`ScalarTest; scalars_enlist); "Invalid scalar type"]

.test.ASSERT_ERROR[serializeArray; (`ScalarTestDynamic; scalars_enlist); "Invalid scalar type"]

-1 "<--- Pass wrong type data --->";

.test.ASSERT_ERROR[serializeArray; (`ScalarTest; scalars_wrong_type); "Invalid scalar type"]

.test.ASSERT_ERROR[serializeArray; (`ScalarTestDynamic; scalars_wrong_type); "Invalid scalar type"]

-1 "<--- Pass insufficient data --->";

.test.ASSERT_ERROR[serializeArray; (`ScalarTest; scalars_short); "Incorrect number of fields"]

.test.ASSERT_ERROR[serializeArray; (`ScalarTestDynamic; scalars_short); "Incorrect number of fields"]


-1 "<--- Pass atom data --->";

.test.ASSERT_ERROR[serializeArray; (`ScalarTest; scalar_atom); "Invalid message type"]

.test.ASSERT_ERROR[serializeArray; (`ScalarTestDynamic; scalar_atom); "Invalid message type"]

-1 "\n+----------|| Test repeated with file ||----------+\n";

-1 "<--- Pass correct data --->";

repeated_expected:scalars_expected ,' scalars_expected;

saveMessage[`RepeatedTest; `repeated_file; repeated_expected];
.test.ASSERT_TRUE[loadMessage; (`RepeatedTest; `repeated_file); repeated_expected]

saveMessage[`RepeatedTestDynamic; `repeated_file; repeated_expected];
.test.ASSERT_TRUE[loadMessage; (`RepeatedTestDynamic; `repeated_file); repeated_expected]

-1 "<--- Pass scalar data --->";

.test.ASSERT_ERROR[saveMessage; (`RepeatedTest; `repeated_file; scalars_expected); "Invalid repeated type"]

.test.ASSERT_ERROR[saveMessage; (`RepeatedTestDynamic; `repeated_file; scalars_expected); "Invalid repeated type"]

-1 "<--- Pass wrong type data --->";

repeated_wrong_type:scalars_wrong_type ,' scalars_wrong_type;

.test.ASSERT_ERROR[saveMessage; (`RepeatedTest; `repeated_file; repeated_wrong_type); "Invalid repeated type"]

.test.ASSERT_ERROR[saveMessage; (`RepeatedTestDynamic; `repeated_file; repeated_wrong_type); "Invalid repeated type"]

-1 "<--- Pass insufficient data --->";

repeated_short:(-1 _ scalars_expected), -1 _ scalars_expected;

.test.ASSERT_ERROR[saveMessage; (`RepeatedTest; `repeated_file; repeated_short); "Incorrect number of fields"]

.test.ASSERT_ERROR[saveMessage; (`RepeatedTestDynamic; `repeated_file; repeated_short); "Incorrect number of fields"]

-1 "<--- Pass simple list data --->";

repeated_simple:1 2 3i;

.test.ASSERT_ERROR[saveMessage; (`RepeatedTest; `repeated_file; repeated_simple); "Invalid message type"]

.test.ASSERT_ERROR[saveMessage; (`RepeatedTestDynamic; `repeated_file; repeated_simple); "Invalid message type"]

-1 "\n+----------|| Test repeated with array ||----------+\n";

-1 "<--- Pass correct data --->";

array:serializeArray[`RepeatedTest; repeated_expected];
.test.ASSERT_TRUE[parseArray; (`RepeatedTest; array); repeated_expected]

array:serializeArray[`RepeatedTestDynamic; repeated_expected];
.test.ASSERT_TRUE[parseArray; (`RepeatedTestDynamic; array); repeated_expected]

-1 "<--- Pass scalar data --->";

.test.ASSERT_ERROR[serializeArray; (`RepeatedTest; scalars_expected); "Invalid repeated type"]

.test.ASSERT_ERROR[serializeArray; (`RepeatedTestDynamic; scalars_expected); "Invalid repeated type"]

-1 "<--- Pass wrong type data --->";

.test.ASSERT_ERROR[serializeArray; (`RepeatedTest; repeated_wrong_type); "Invalid repeated type"]

.test.ASSERT_ERROR[serializeArray; (`RepeatedTestDynamic; repeated_wrong_type); "Invalid repeated type"]

-1 "<--- Pass insufficient data --->";

.test.ASSERT_ERROR[serializeArray; (`RepeatedTest; repeated_short); "Incorrect number of fields"]

.test.ASSERT_ERROR[serializeArray; (`RepeatedTestDynamic; repeated_short); "Incorrect number of fields"]

-1 "<--- Pass simple list data --->";

.test.ASSERT_ERROR[serializeArray; (`RepeatedTest; repeated_simple); "Invalid message type"]

.test.ASSERT_ERROR[serializeArray; (`RepeatedTestDynamic; repeated_simple); "Invalid message type"]

-1 "\n+----------|| Test submessage with file ||----------+\n";

-1 "<--- Pass correct data --->";

submessage_expected:(scalars_expected;enlist repeated_expected);

saveMessage[`SubMessageTest; `submessage_file; submessage_expected];
.test.ASSERT_TRUE[loadMessage; (`SubMessageTest; `submessage_file); submessage_expected]

saveMessage[`SubMessageTestDynamic; `submessage_file; submessage_expected];
.test.ASSERT_TRUE[loadMessage; (`SubMessageTestDynamic; `submessage_file); submessage_expected]

-1 "<--- Pass non-repeated submessage --->";

submessage_nonrepeated:(scalars_expected; repeated_expected);

.test.ASSERT_ERROR[saveMessage; (`SubMessageTest; `submessage_file; submessage_nonrepeated); "Invalid message type"]

.test.ASSERT_ERROR[saveMessage; (`SubMessageTestDynamic; `submessage_file; submessage_nonrepeated); "Invalid message type"]


-1 "<--- Pass insufficient message --->";

submessage_short:enlist scalars_expected;

.test.ASSERT_ERROR[saveMessage; (`SubMessageTest; `submessage_file; submessage_short); "Incorrect number of fields"]

.test.ASSERT_ERROR[saveMessage; (`SubMessageTestDynamic; `submessage_file; submessage_short); "Incorrect number of fields"]


-1 "\n+----------|| Test submessage with array ||----------+\n";

-1 "<--- Pass correct data --->";

array:serializeArray[`SubMessageTest; submessage_expected];
.test.ASSERT_TRUE[parseArray; (`SubMessageTest; array); submessage_expected]

array:serializeArray[`SubMessageTestDynamic; submessage_expected];
.test.ASSERT_TRUE[parseArray; (`SubMessageTestDynamic; array); submessage_expected]


-1 "<--- Pass non-repeated submessage --->";

.test.ASSERT_ERROR[serializeArray; (`SubMessageTest; submessage_nonrepeated); "Invalid message type"]

.test.ASSERT_ERROR[serializeArray; (`SubMessageTestDynamic; submessage_nonrepeated); "Invalid message type"]


-1 "<--- Pass insufficient message --->";

submessage_short:enlist 2#enlist repeated_expected;

.test.ASSERT_ERROR[serializeArray; (`SubMessageTest; submessage_short); "Incorrect number of fields"]

.test.ASSERT_ERROR[serializeArray; (`SubMessageTestDynamic; submessage_short); "Incorrect number of fields"]

-1 "\n+----------|| Test map with file ||----------+\n";

// Protobuf maps are unordered and unsorted so use single item lists for each dictionary 
// element to perform a simple equality check.
map:((enlist 1i)!(enlist 2j);(enlist 3i)!(enlist 4j);(enlist 5j)!(enlist 6f);(enlist 7j)!(enlist 8e);(enlist 0b)!(enlist 1i);(enlist `one)!(enlist scalars_expected);(enlist `three)!(enlist submessage_expected));

saveMessage[`MapTest; `map_file; map];
.test.ASSERT_TRUE[loadMessage; (`MapTest; `map_file); map]

saveMessage[`MapTestDynamic;`map_file;map]
.test.ASSERT_TRUE[loadMessage; (`MapTestDynamic; `map_file); map]

-1 "<--- Pass wrong type key --->";

map_wrong_key:((enlist 1i)!(enlist 2j);(enlist 0b)!(enlist 4j);(enlist 5j)!(enlist 6f);(enlist 7i)!(enlist 8e);(enlist 0b)!(enlist 1i);(enlist `one)!(enlist scalars_expected);(enlist `three)!(enlist submessage_expected));

.test.ASSERT_ERROR[saveMessage; (`MapTest;  `map_file; map_wrong_key); "Invalid map element type"]

.test.ASSERT_ERROR[saveMessage; (`MapTestDynamic;  `map_file; map_wrong_key); "Invalid map element type"]

-1 "<--- Pass wrong type value --->";

map_wrong_value:((enlist 1i)!(enlist 2j);(enlist 3i)!(enlist 4j);(enlist 5j)!(enlist 6f);(enlist 7j)!(enlist 8e);(enlist 0b)!(enlist 1i);(enlist `one)!(enlist repeated_expected);(enlist `three)!(enlist submessage_expected));

.test.ASSERT_ERROR[saveMessage; (`MapTest;  `map_file; map_wrong_value); "Invalid scalar type"]

.test.ASSERT_ERROR[saveMessage; (`MapTestDynamic;  `map_file; map_wrong_value); "Invalid scalar type"]

-1 "\n+----------|| Test map with array ||----------+\n";

-1 "<--- Pass correct data --->";

array:serializeArray[`MapTest; map];
.test.ASSERT_TRUE[parseArray; (`MapTest; array); map]

array:serializeArray[`MapTestDynamic; map];
.test.ASSERT_TRUE[parseArray; (`MapTestDynamic; array); map]


-1 "<--- Pass wrong type key --->";

.test.ASSERT_ERROR[serializeArray; (`MapTest; map_wrong_key); "Invalid map element type"]

.test.ASSERT_ERROR[serializeArray; (`MapTestDynamic; map_wrong_key); "Invalid map element type"]


-1 "<--- Pass wrong value type --->";

.test.ASSERT_ERROR[serializeArray; (`MapTest;  map_wrong_value); "Invalid scalar type"]

.test.ASSERT_ERROR[serializeArray; (`MapTestDynamic;  map_wrong_value); "Invalid scalar type"]

-1 "\n+----------|| Test scalar specifiers with file ||----------+\n";

-1 "<--- Pass correct data --->";

scalar_specifiers:(2020.01.01D12:34:56.123456789; 2020.01m; 2020.01.01; 2020.01.01T12:34:56.123; 12:34:56.123456789; 12:34; 12:34:56; 12:34:56.123; (1?0Ng)0);

saveMessage[`ScalarSpecifiersTest; `scalar_specifiers_file; scalar_specifiers];
.test.ASSERT_TRUE[loadMessage; (`ScalarSpecifiersTest; `scalar_specifiers_file); scalar_specifiers]

saveMessage[`ScalarSpecifiersTestDynamic; `scalar_specifiers_file; scalar_specifiers];
.test.ASSERT_TRUE[loadMessage; (`ScalarSpecifiersTestDynamic; `scalar_specifiers_file); scalar_specifiers]

-1 "<--- Pass wrong type (compatible in q context but not in protobuf) --->";

scalar_specifiers_compatible:(631197296123456789; 240i; 73051; 7305.524; 45296123456789; 754; 45296; 45296123i; (1?0Ng)0);

.test.ASSERT_ERROR[saveMessage; (`ScalarSpecifiersTest; `scalar_specifiers_file; scalar_specifiers_compatible); "Invalid scalar type"]

.test.ASSERT_ERROR[saveMessage; (`ScalarSpecifiersTestDynamic; `scalar_specifiers_file; scalar_specifiers_compatible); "Invalid scalar type"]

-1 "\n+----------|| Test scalar specifiers with array ||----------+\n";

-1 "<--- Pass correct data --->";

array:serializeArray[`ScalarSpecifiersTest;scalar_specifiers];
.test.ASSERT_TRUE[parseArray; (`ScalarSpecifiersTest; array); scalar_specifiers]

array:serializeArray[`ScalarSpecifiersTestDynamic;scalar_specifiers];
.test.ASSERT_TRUE[parseArray; (`ScalarSpecifiersTestDynamic; array); scalar_specifiers]


-1 "<--- Pass wrong type (compatible in q context but not in protobuf) --->";

.test.ASSERT_ERROR[saveMessage; (`ScalarSpecifiersTest; `scalar_specifiers_file; scalar_specifiers_compatible); "Invalid scalar type"]

.test.ASSERT_ERROR[saveMessage; (`ScalarSpecifiersTestDynamic; `scalar_specifiers_file; scalar_specifiers_compatible); "Invalid scalar type"]


-1 "\n+----------|| Test repeated specifiers with file ||----------+\n";

-1 "<--- Pass correct data --->";

repeated_specifiers:scalar_specifiers,'scalar_specifiers;

saveMessage[`RepeatedSpecifiersTest;`repeated_specifiers_file;repeated_specifiers];
.test.ASSERT_TRUE[loadMessage; (`RepeatedSpecifiersTest; `repeated_specifiers_file); repeated_specifiers]

saveMessage[`RepeatedSpecifiersTestDynamic;`repeated_specifiers_file;repeated_specifiers];
.test.ASSERT_TRUE[loadMessage; (`RepeatedSpecifiersTestDynamic; `repeated_specifiers_file); repeated_specifiers]


-1 "<--- Pass wrong type and correct type (compatible in q context but not in protobuf) --->";

repeated_specifiers_mixture:scalar_specifiers ,' scalar_specifiers_compatible;

.test.ASSERT_ERROR[saveMessage; (`RepeatedSpecifiersTest; `repeated_specifiers_file; repeated_specifiers_mixture); "Invalid repeated type"]

.test.ASSERT_ERROR[saveMessage; (`RepeatedSpecifiersTestDynamic; `repeated_specifiers_file; repeated_specifiers_mixture); "Invalid repeated type"]


-1 "\n+----------|| Test repeated specifiers with array ||----------+\n";

-1 "<--- Pass correct data --->";

array:serializeArray[`RepeatedSpecifiersTest;repeated_specifiers];
.test.ASSERT_TRUE[parseArray; (`RepeatedSpecifiersTest; array); repeated_specifiers]

array:serializeArray[`RepeatedSpecifiersTestDynamic; repeated_specifiers];
.test.ASSERT_TRUE[parseArray; (`RepeatedSpecifiersTestDynamic; array); repeated_specifiers]

-1 "<--- Pass wrong type and speciiers --->";

.test.ASSERT_ERROR[serializeArray; (`RepeatedSpecifiersTest; repeated_specifiers_mixture); "Invalid repeated type"]

.test.ASSERT_ERROR[serializeArray; (`RepeatedSpecifiersTestDynamic; repeated_specifiers_mixture); "Invalid repeated type"]

-1 "\n+----------|| Test map specifiers with file ||----------+\n";

-1 "<--- Pass correct data --->";

map_specifiers:((enlist 2020.01.01D12:34:56.123456789)!(enlist 2020.01m);(enlist 2020.01.01)!(enlist 2020.01.01T12:34:56.123);(enlist 12:34:56.123456789)!(enlist 12:34);(enlist 12:34:56)!(enlist 12:34:56.123);(1?0Ng)!(1?0Ng));

saveMessage[`MapSpecifiersTest;`map_specifiers_file;map_specifiers];
.test.ASSERT_TRUE[loadMessage; (`MapSpecifiersTest; `map_specifiers_file); map_specifiers]

saveMessage[`MapSpecifiersTestDynamic;`map_specifiers_file;map_specifiers];
.test.ASSERT_TRUE[loadMessage; (`MapSpecifiersTestDynamic; `map_specifiers_file); map_specifiers]

-1 "<--- Pass wrong type (compatible in q context but not in protobuf) --->";

map_specifiers_compatible:((enlist 631197296123456789)!(enlist 240i);(enlist 7305i)!(enlist 7305.524);(enlist 45296123456789)!(enlist 754);(enlist 45296)!(enlist 45296123i);(1?0Ng)!(1?0Ng));

.test.ASSERT_ERROR[saveMessage; (`MapSpecifiersTest; `map_specifiers_file; map_specifiers_compatible); "Invalid map element type"]

.test.ASSERT_ERROR[saveMessage; (`MapSpecifiersTestDynamic; `map_specifiers_file; map_specifiers_compatible); "Invalid map element type"]


-1 "\n+----------|| Test map specifiers with array ||----------+\n";

-1 "<--- Pass correct data --->";

array:serializeArray[`MapSpecifiersTest; map_specifiers];
.test.ASSERT_TRUE[parseArray; (`MapSpecifiersTest; array); map_specifiers]

array:serializeArray[`MapSpecifiersTestDynamic;map_specifiers];
.test.ASSERT_TRUE[parseArray; (`MapSpecifiersTestDynamic; array); map_specifiers]

-1 "<--- Pass wrong type (compatible in q context but not in protobuf) --->";

.test.ASSERT_ERROR[serializeArray; (`MapSpecifiersTest; map_specifiers_compatible); "Invalid map element type"]

.test.ASSERT_ERROR[serializeArray; (`MapSpecifiersTestDynamic; map_specifiers_compatible); "Invalid map element type"]


-1 "\n+----------|| Test oneof permutations ||----------+\n";

-1 "<--- Pass correct data --->";

oneof1:(1.1f;();();`str);
oneof2:(();12:34:56;();`str);
oneof3:(();();(1j; 2.1 2.2f);`str);
oneofnone:(();();();`str);

.test.ASSERT_TRUE[parseArray; (`OneofTest; serializeArray[`OneofTest;oneof1]); oneof1]
.test.ASSERT_TRUE[parseArray; (`OneofTest; serializeArray[`OneofTest;oneof2]); oneof2]
.test.ASSERT_TRUE[parseArray; (`OneofTest; serializeArray[`OneofTest;oneof3]); oneof3]
.test.ASSERT_TRUE[parseArray; (`OneofTest; serializeArray[`OneofTest;oneofnone]); oneofnone]

.test.ASSERT_TRUE[parseArray; (`OneofTestDynamic; serializeArray[`OneofTest;oneof1]); oneof1]
.test.ASSERT_TRUE[parseArray; (`OneofTestDynamic; serializeArray[`OneofTest;oneof2]); oneof2]
.test.ASSERT_TRUE[parseArray; (`OneofTestDynamic; serializeArray[`OneofTest;oneof3]); oneof3]
.test.ASSERT_TRUE[parseArray; (`OneofTestDynamic; serializeArray[`OneofTest;oneofnone]); oneofnone]

-1 "<--- Pass wrong type data --->";

oneofwrong:(42i; (); (); `str);
.test.ASSERT_ERROR[serializeArray; (`OneofTest; oneofwrong); "Invalid scalar type"]

oneofwrong:((); 123456; (); `str);
.test.ASSERT_ERROR[serializeArray; (`OneofTestDynamic; oneofwrong); "Invalid scalar type"]

-1 "<--- Pass multiple populated data --->";

// If mulitple oneofs are set, only the last is populated
oneofall:(1.1f;12:34:56;(1j; 2.1 2.2f);`str);

.test.ASSERT_TRUE[parseArray; (`OneofTest; serializeArray[`OneofTest; oneofall]); oneof3]

.test.ASSERT_TRUE[parseArray; (`OneofTest; serializeArray[`OneofTestDynamic; oneofall]); oneof3]

-1 "\n+----------|| Finished testing ||----------+\n";
