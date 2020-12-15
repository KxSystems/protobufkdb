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
.test.ASSERT_ERROR[importProtoFile; enlist "not_exist.proto"; "Error: not_exist.proto:-1:0: File not found."]

-1 "\n+----------|| Test scalars with file ||----------+\n";

-1 "<--- Pass correct data --->";

scalars_expected:(1i;2i;3j;4j;5f;6e;1b;2i;"string");

saveMessageFromList[`ScalarTest;`scalar_file;scalars_expected];
.test.ASSERT_TRUE[loadMessageToList; (`ScalarTest; `scalar_file); scalars_expected]

saveMessageFromList[`ScalarTestDynamic;`scalar_file;scalars_expected];
.test.ASSERT_TRUE[loadMessageToList; (`ScalarTestDynamic; `scalar_file); scalars_expected]

-1 "<--- Pass enlist for scalar --->";

scalars_enlist:(1i;enlist 2i;3j;4j;5f;6e;1b;1i;"string");

.test.ASSERT_ERROR[saveMessageFromList; (`ScalarTest; `scalar_file; scalars_enlist); "Invalid scalar type"]

.test.ASSERT_ERROR[saveMessageFromList; (`ScalarTestDynamic; `scalar_file; scalars_enlist); "Invalid scalar type"]

-1 "<--- Pass different type scalar --->";

scalars_wrong_type:(1i;2i;3j;4f;5f;6e;1b;0i;"string");

.test.ASSERT_ERROR[saveMessageFromList; (`ScalarTest; `scalar_file; scalars_wrong_type); "Invalid scalar type"]

.test.ASSERT_ERROR[saveMessageFromList; (`ScalarTestDynamic; `scalar_file; scalars_wrong_type); "Invalid scalar type"]

-1 "<--- Pass insufficient data --->";

scalars_short:(2i;3j;4j;5f;6e;1b;0i;"string");

.test.ASSERT_ERROR[saveMessageFromList; (`ScalarTest; `scalar_file; scalars_short); "Incorrect number of fields"]

.test.ASSERT_ERROR[saveMessageFromList; (`ScalarTestDynamic; `scalar_file; scalars_short); "Incorrect number of fields"]

-1 "<--- Pass atom data --->";

scalar_atom:1i;

.test.ASSERT_ERROR[saveMessageFromList; (`ScalarTest; `scalar_file; scalar_atom); "Invalid message type"]

.test.ASSERT_ERROR[saveMessageFromList; (`ScalarTestDynamic; `scalar_file; scalar_atom); "Invalid message type"]


-1 "\n+----------|| Test scalars with file and field name dictionary ||----------+\n";

-1 "<--- Pass correct data --->";

scalar_fields:getMessageFields[`ScalarTest];
scalars_expected_dict:scalar_fields!scalars_expected;

saveMessageFromDict[`ScalarTest;`scalar_file;scalars_expected_dict];
.test.ASSERT_TRUE[loadMessageToDict; (`ScalarTest; `scalar_file); scalars_expected_dict]

saveMessageFromDict[`ScalarTestDynamic;`scalar_file;scalars_expected_dict];
.test.ASSERT_TRUE[loadMessageToDict; (`ScalarTestDynamic; `scalar_file); scalars_expected_dict]

-1 "<--- Pass enlist for scalar --->";

scalars_enlist_dict:scalar_fields!scalars_enlist;

.test.ASSERT_ERROR[saveMessageFromDict; (`ScalarTest; `scalar_file; scalars_enlist_dict); "Invalid scalar type"]

.test.ASSERT_ERROR[saveMessageFromDict; (`ScalarTestDynamic; `scalar_file; scalars_enlist_dict); "Invalid scalar type"]

-1 "<--- Pass different type scalar --->";

scalars_wrong_type_dict:scalar_fields!scalars_wrong_type;

.test.ASSERT_ERROR[saveMessageFromDict; (`ScalarTest; `scalar_file; scalars_wrong_type_dict); "Invalid scalar type"]

.test.ASSERT_ERROR[saveMessageFromDict; (`ScalarTestDynamic; `scalar_file; scalars_wrong_type_dict); "Invalid scalar type"]

-1 "<--- Pass incorrect field names --->";

scalar_fields_bad:getMessageFields[`ScalarTest];
scalar_fields_bad[0]:`bad;
scalars_unknown_field_dict:scalar_fields_bad!scalars_expected;

.test.ASSERT_ERROR[saveMessageFromDict; (`ScalarTest; `scalar_file; scalars_unknown_field_dict); "Unknown message field name"]

.test.ASSERT_ERROR[saveMessageFromDict; (`ScalarTestDynamic; `scalar_file; scalars_unknown_field_dict); "Unknown message field name"]

-1 "<--- Pass atom data as dictionary --->";

.test.ASSERT_ERROR[saveMessageFromList; (`ScalarTest; `scalar_file; scalar_atom); "Invalid message type"]

.test.ASSERT_ERROR[saveMessageFromList; (`ScalarTestDynamic; `scalar_file; scalar_atom); "Invalid message type"]


-1 "\n+----------|| Test scalars with array ||----------+\n";

-1 "<--- Pass correct data --->";

array:serializeArrayFromList[`ScalarTest; scalars_expected];

.test.ASSERT_TRUE[parseArrayToList; (`ScalarTest; array); scalars_expected]

.test.ASSERT_TRUE[parseArrayToList; (`ScalarTestDynamic; array); scalars_expected]

-1 "<--- Pass enlist --->";

.test.ASSERT_ERROR[serializeArrayFromList; (`ScalarTest; scalars_enlist); "Invalid scalar type"]

.test.ASSERT_ERROR[serializeArrayFromList; (`ScalarTestDynamic; scalars_enlist); "Invalid scalar type"]

-1 "<--- Pass wrong type data --->";

.test.ASSERT_ERROR[serializeArrayFromList; (`ScalarTest; scalars_wrong_type); "Invalid scalar type"]

.test.ASSERT_ERROR[serializeArrayFromList; (`ScalarTestDynamic; scalars_wrong_type); "Invalid scalar type"]

-1 "<--- Pass insufficient data --->";

.test.ASSERT_ERROR[serializeArrayFromList; (`ScalarTest; scalars_short); "Incorrect number of fields"]

.test.ASSERT_ERROR[serializeArrayFromList; (`ScalarTestDynamic; scalars_short); "Incorrect number of fields"]


-1 "<--- Pass atom data --->";

.test.ASSERT_ERROR[serializeArrayFromList; (`ScalarTest; scalar_atom); "Invalid message type"]

.test.ASSERT_ERROR[serializeArrayFromList; (`ScalarTestDynamic; scalar_atom); "Invalid message type"]


-1 "\n+----------|| Test scalars with array and field name dictionary ||----------+\n";

-1 "<--- Pass correct data --->";

array:serializeArrayFromDict[`ScalarTest; scalars_expected_dict];

.test.ASSERT_TRUE[parseArrayToDict; (`ScalarTest; array); scalars_expected_dict]

.test.ASSERT_TRUE[parseArrayToDict; (`ScalarTestDynamic; array); scalars_expected_dict]

-1 "<--- Pass enlist --->";

.test.ASSERT_ERROR[serializeArrayFromDict; (`ScalarTest; scalars_enlist_dict); "Invalid scalar type"]

.test.ASSERT_ERROR[serializeArrayFromDict; (`ScalarTestDynamic; scalars_enlist_dict); "Invalid scalar type"]

-1 "<--- Pass wrong type data --->";

.test.ASSERT_ERROR[serializeArrayFromDict; (`ScalarTest; scalars_wrong_type_dict); "Invalid scalar type"]

.test.ASSERT_ERROR[serializeArrayFromDict; (`ScalarTestDynamic; scalars_wrong_type_dict); "Invalid scalar type"]

-1 "<--- Pass incorrect field names --->";

.test.ASSERT_ERROR[serializeArrayFromDict; (`ScalarTest; scalars_unknown_field_dict); "Unknown message field name"]

.test.ASSERT_ERROR[serializeArrayFromDict; (`ScalarTestDynamic; scalars_unknown_field_dict); "Unknown message field name"]

-1 "<--- Pass atom data as dictionary --->";

.test.ASSERT_ERROR[serializeArrayFromDict; (`ScalarTest; scalar_atom); "Invalid message type"]

.test.ASSERT_ERROR[serializeArrayFromDict; (`ScalarTestDynamic; scalar_atom); "Invalid message type"]


-1 "\n+----------|| Test repeated with file ||----------+\n";

-1 "<--- Pass correct data --->";

repeated_from_scalars:{@[x;where 10h=type each x;enlist]}
repeated_scalars:repeated_from_scalars scalars_expected;
repeated_expected:repeated_scalars,'repeated_scalars;

saveMessageFromList[`RepeatedTest; `repeated_file; repeated_expected];
.test.ASSERT_TRUE[loadMessageToList; (`RepeatedTest; `repeated_file); repeated_expected]

saveMessageFromList[`RepeatedTestDynamic; `repeated_file; repeated_expected];
.test.ASSERT_TRUE[loadMessageToList; (`RepeatedTestDynamic; `repeated_file); repeated_expected]

-1 "<--- Pass scalar data --->";

.test.ASSERT_ERROR[saveMessageFromList; (`RepeatedTest; `repeated_file; scalars_expected); "Invalid repeated type"]

.test.ASSERT_ERROR[saveMessageFromList; (`RepeatedTestDynamic; `repeated_file; scalars_expected); "Invalid repeated type"]

-1 "<--- Pass wrong type data --->";

repeated_wrong_type:scalars_wrong_type ,' scalars_wrong_type;

.test.ASSERT_ERROR[saveMessageFromList; (`RepeatedTest; `repeated_file; repeated_wrong_type); "Invalid repeated type"]

.test.ASSERT_ERROR[saveMessageFromList; (`RepeatedTestDynamic; `repeated_file; repeated_wrong_type); "Invalid repeated type"]

-1 "<--- Pass insufficient data --->";

repeated_short:(-1 _ scalars_expected),' -1 _ scalars_expected;

.test.ASSERT_ERROR[saveMessageFromList; (`RepeatedTest; `repeated_file; repeated_short); "Incorrect number of fields"]

.test.ASSERT_ERROR[saveMessageFromList; (`RepeatedTestDynamic; `repeated_file; repeated_short); "Incorrect number of fields"]

-1 "<--- Pass simple list data --->";

repeated_simple:1 2 3i;

.test.ASSERT_ERROR[saveMessageFromList; (`RepeatedTest; `repeated_file; repeated_simple); "Invalid message type"]

.test.ASSERT_ERROR[saveMessageFromList; (`RepeatedTestDynamic; `repeated_file; repeated_simple); "Invalid message type"]


-1 "\n+----------|| Test repeated with file and field name dictionary ||----------+\n";

-1 "<--- Pass correct data --->";

repeated_fields:getMessageFields[`RepeatedTest];
repeated_expected_dict:repeated_fields!repeated_expected;

saveMessageFromDict[`RepeatedTest; `repeated_file; repeated_expected_dict];
.test.ASSERT_TRUE[loadMessageToDict; (`RepeatedTest; `repeated_file); repeated_expected_dict]

saveMessageFromDict[`RepeatedTestDynamic; `repeated_file; repeated_expected_dict];
.test.ASSERT_TRUE[loadMessageToDict; (`RepeatedTestDynamic; `repeated_file); repeated_expected_dict]

-1 "<--- Pass scalar data --->";

repeated_scalar_data_dict:repeated_fields!scalars_expected;

.test.ASSERT_ERROR[saveMessageFromDict; (`RepeatedTest; `repeated_file; repeated_scalar_data_dict); "Invalid repeated type"]

.test.ASSERT_ERROR[saveMessageFromDict; (`RepeatedTestDynamic; `repeated_file; repeated_scalar_data_dict); "Invalid repeated type"]

-1 "<--- Pass wrong type data --->";

repeated_wrong_type_dict:repeated_fields!repeated_wrong_type;

.test.ASSERT_ERROR[saveMessageFromDict; (`RepeatedTest; `repeated_file; repeated_wrong_type_dict); "Invalid repeated type"]

.test.ASSERT_ERROR[saveMessageFromDict; (`RepeatedTestDynamic; `repeated_file; repeated_wrong_type_dict); "Invalid repeated type"]

-1 "<--- Pass incorrect field names --->";

repeated_fields_bad:getMessageFields[`RepeatedTest];
repeated_fields_bad[0]:`bad;
repeated_unknown_field_dict:repeated_fields_bad!repeated_expected;

.test.ASSERT_ERROR[saveMessageFromDict; (`RepeatedTest; `repeated_file; repeated_unknown_field_dict); "Unknown message field name"]

.test.ASSERT_ERROR[saveMessageFromDict; (`RepeatedTestDynamic; `repeated_file; repeated_unknown_field_dict); "Unknown message field name"]

-1 "<--- Pass simple list data as dictionary --->";

.test.ASSERT_ERROR[saveMessageFromDict; (`RepeatedTest; `repeated_file; repeated_simple); "Invalid message type"]

.test.ASSERT_ERROR[saveMessageFromDict; (`RepeatedTestDynamic; `repeated_file; repeated_simple); "Invalid message type"]


-1 "\n+----------|| Test repeated with array ||----------+\n";

-1 "<--- Pass correct data --->";

array:serializeArrayFromList[`RepeatedTest; repeated_expected];
.test.ASSERT_TRUE[parseArrayToList; (`RepeatedTest; array); repeated_expected]

array:serializeArrayFromList[`RepeatedTestDynamic; repeated_expected];
.test.ASSERT_TRUE[parseArrayToList; (`RepeatedTestDynamic; array); repeated_expected]

-1 "<--- Pass scalar data --->";

.test.ASSERT_ERROR[serializeArrayFromList; (`RepeatedTest; scalars_expected); "Invalid repeated type"]

.test.ASSERT_ERROR[serializeArrayFromList; (`RepeatedTestDynamic; scalars_expected); "Invalid repeated type"]

-1 "<--- Pass wrong type data --->";

.test.ASSERT_ERROR[serializeArrayFromList; (`RepeatedTest; repeated_wrong_type); "Invalid repeated type"]

.test.ASSERT_ERROR[serializeArrayFromList; (`RepeatedTestDynamic; repeated_wrong_type); "Invalid repeated type"]

-1 "<--- Pass insufficient data --->";

.test.ASSERT_ERROR[serializeArrayFromList; (`RepeatedTest; repeated_short); "Incorrect number of fields"]

.test.ASSERT_ERROR[serializeArrayFromList; (`RepeatedTestDynamic; repeated_short); "Incorrect number of fields"]

-1 "<--- Pass simple list data --->";

.test.ASSERT_ERROR[serializeArrayFromList; (`RepeatedTest; repeated_simple); "Invalid message type"]

.test.ASSERT_ERROR[serializeArrayFromList; (`RepeatedTestDynamic; repeated_simple); "Invalid message type"]


-1 "\n+----------|| Test repeated with array and field name dictionary ||----------+\n";

-1 "<--- Pass correct data --->";

array:serializeArrayFromDict[`RepeatedTest; repeated_expected_dict];
.test.ASSERT_TRUE[parseArrayToDict; (`RepeatedTest; array); repeated_expected_dict]

array:serializeArrayFromDict[`RepeatedTestDynamic; repeated_expected_dict];
.test.ASSERT_TRUE[parseArrayToDict; (`RepeatedTestDynamic; array); repeated_expected_dict]

-1 "<--- Pass scalar data --->";

.test.ASSERT_ERROR[serializeArrayFromDict; (`RepeatedTest; repeated_scalar_data_dict); "Invalid repeated type"]

.test.ASSERT_ERROR[serializeArrayFromDict; (`RepeatedTestDynamic; repeated_scalar_data_dict); "Invalid repeated type"]

-1 "<--- Pass wrong type data --->";

.test.ASSERT_ERROR[serializeArrayFromDict; (`RepeatedTest; repeated_wrong_type_dict); "Invalid repeated type"]

.test.ASSERT_ERROR[serializeArrayFromDict; (`RepeatedTestDynamic; repeated_wrong_type_dict); "Invalid repeated type"]

-1 "<--- Pass incorrect field names --->";

.test.ASSERT_ERROR[serializeArrayFromDict; (`RepeatedTest; repeated_unknown_field_dict); "Unknown message field name"]

.test.ASSERT_ERROR[serializeArrayFromDict; (`RepeatedTestDynamic; repeated_unknown_field_dict); "Unknown message field name"]

-1 "<--- Pass simple list data as dictionary --->";

.test.ASSERT_ERROR[serializeArrayFromDict; (`RepeatedTest; repeated_simple); "Invalid message type"]

.test.ASSERT_ERROR[serializeArrayFromDict; (`RepeatedTestDynamic; repeated_simple); "Invalid message type"]


-1 "\n+----------|| Test submessage with file ||----------+\n";

-1 "<--- Pass correct data --->";

submessage_expected:(scalars_expected;enlist repeated_expected);

saveMessageFromList[`SubMessageTest; `submessage_file; submessage_expected];
.test.ASSERT_TRUE[loadMessageToList; (`SubMessageTest; `submessage_file); submessage_expected]

saveMessageFromList[`SubMessageTestDynamic; `submessage_file; submessage_expected];
.test.ASSERT_TRUE[loadMessageToList; (`SubMessageTestDynamic; `submessage_file); submessage_expected]

-1 "<--- Pass non-repeated submessage --->";

submessage_nonrepeated:(scalars_expected; repeated_expected);

.test.ASSERT_ERROR[saveMessageFromList; (`SubMessageTest; `submessage_file; submessage_nonrepeated); "Invalid message type"]

.test.ASSERT_ERROR[saveMessageFromList; (`SubMessageTestDynamic; `submessage_file; submessage_nonrepeated); "Invalid message type"]


-1 "<--- Pass insufficient message --->";

submessage_short:enlist scalars_expected;

.test.ASSERT_ERROR[saveMessageFromList; (`SubMessageTest; `submessage_file; submessage_short); "Incorrect number of fields"]

.test.ASSERT_ERROR[saveMessageFromList; (`SubMessageTestDynamic; `submessage_file; submessage_short); "Incorrect number of fields"]


-1 "\n+----------|| Test submessage with file and field name dictionary ||----------+\n";

-1 "<--- Pass correct data --->";

submessage_fields:getMessageFields[`SubMessageTest];
submessage_expected_dict:submessage_fields!(scalars_expected_dict;(enlist repeated_expected_dict));

saveMessageFromDict[`SubMessageTest; `submessage_file; submessage_expected_dict];
.test.ASSERT_TRUE[loadMessageToDict; (`SubMessageTest; `submessage_file); submessage_expected_dict]

saveMessageFromDict[`SubMessageTestDynamic; `submessage_file; submessage_expected_dict];
.test.ASSERT_TRUE[loadMessageToDict; (`SubMessageTestDynamic; `submessage_file); submessage_expected_dict]

-1 "<--- Pass non-repeated submessage --->";

submessage_nonrepeated_dict:submessage_fields!(scalars_expected_dict; repeated_expected_dict);

.test.ASSERT_ERROR[saveMessageFromDict; (`SubMessageTest; `submessage_file; submessage_nonrepeated_dict); "Invalid repeated message type"]

.test.ASSERT_ERROR[saveMessageFromDict; (`SubMessageTestDynamic; `submessage_file; submessage_nonrepeated_dict); "Invalid repeated message type"]

-1 "<--- Pass incorrect field names --->";

submessage_fields_bad:getMessageFields[`SubMessageTest];
submessage_fields_bad[0]:`bad;
submessage_unknown_field_dict:submessage_fields_bad!(scalars_expected_dict;(enlist repeated_expected_dict));

.test.ASSERT_ERROR[saveMessageFromDict; (`SubMessageTest; `submessage_file; submessage_unknown_field_dict); "Unknown message field name"]

.test.ASSERT_ERROR[saveMessageFromDict; (`SubMessageTestDynamic; `submessage_file; submessage_unknown_field_dict); "Unknown message field name"]


-1 "\n+----------|| Test submessage with array ||----------+\n";

-1 "<--- Pass correct data --->";

array:serializeArrayFromList[`SubMessageTest; submessage_expected];
.test.ASSERT_TRUE[parseArrayToList; (`SubMessageTest; array); submessage_expected]

array:serializeArrayFromList[`SubMessageTestDynamic; submessage_expected];
.test.ASSERT_TRUE[parseArrayToList; (`SubMessageTestDynamic; array); submessage_expected]

-1 "<--- Pass non-repeated submessage --->";

.test.ASSERT_ERROR[serializeArrayFromList; (`SubMessageTest; submessage_nonrepeated); "Invalid message type"]

.test.ASSERT_ERROR[serializeArrayFromList; (`SubMessageTestDynamic; submessage_nonrepeated); "Invalid message type"]

-1 "<--- Pass insufficient message --->";

submessage_short:enlist 2#enlist repeated_expected;

.test.ASSERT_ERROR[serializeArrayFromList; (`SubMessageTest; submessage_short); "Incorrect number of fields"]

.test.ASSERT_ERROR[serializeArrayFromList; (`SubMessageTestDynamic; submessage_short); "Incorrect number of fields"]


-1 "\n+----------|| Test submessage with array and field name dictionary ||----------+\n";

-1 "<--- Pass correct data --->";

array:serializeArrayFromDict[`SubMessageTest; submessage_expected_dict];
.test.ASSERT_TRUE[parseArrayToDict; (`SubMessageTest; array); submessage_expected_dict]

array:serializeArrayFromDict[`SubMessageTestDynamic; submessage_expected_dict];
.test.ASSERT_TRUE[parseArrayToDict; (`SubMessageTestDynamic; array); submessage_expected_dict]

-1 "<--- Pass non-repeated submessage --->";

.test.ASSERT_ERROR[serializeArrayFromDict; (`SubMessageTest; submessage_nonrepeated_dict); "Invalid repeated message type"]

.test.ASSERT_ERROR[serializeArrayFromDict; (`SubMessageTestDynamic; submessage_nonrepeated_dict); "Invalid repeated message type"]

-1 "<--- Pass incorrect field names --->";

.test.ASSERT_ERROR[serializeArrayFromDict; (`SubMessageTest; submessage_unknown_field_dict); "Unknown message field name"]

.test.ASSERT_ERROR[serializeArrayFromDict; (`SubMessageTestDynamic; submessage_unknown_field_dict); "Unknown message field name"]


-1 "\n+----------|| Test map with file ||----------+\n";

// Protobuf maps are unordered and unsorted so use single item lists for each dictionary 
// element to perform a simple equality check.
map:((enlist 1i)!(enlist 2j);(enlist 3i)!(enlist 4j);(enlist 5j)!(enlist 6f);(enlist 7j)!(enlist 8e);(enlist 0b)!(enlist 1i);(enlist `one)!(enlist scalars_expected);(enlist `three)!(enlist submessage_expected));

saveMessageFromList[`MapTest; `map_file; map];
.test.ASSERT_TRUE[loadMessageToList; (`MapTest; `map_file); map]

saveMessageFromList[`MapTestDynamic;`map_file;map]
.test.ASSERT_TRUE[loadMessageToList; (`MapTestDynamic; `map_file); map]

-1 "<--- Pass wrong type key --->";

map_wrong_key:((enlist 1i)!(enlist 2j);(enlist 0b)!(enlist 4j);(enlist 5j)!(enlist 6f);(enlist 7i)!(enlist 8e);(enlist 0b)!(enlist 1i);(enlist `one)!(enlist scalars_expected);(enlist `three)!(enlist submessage_expected));

.test.ASSERT_ERROR[saveMessageFromList; (`MapTest;  `map_file; map_wrong_key); "Invalid map element type"]

.test.ASSERT_ERROR[saveMessageFromList; (`MapTestDynamic;  `map_file; map_wrong_key); "Invalid map element type"]

-1 "<--- Pass wrong type value --->";

map_wrong_value:((enlist 1i)!(enlist 2j);(enlist 3i)!(enlist 4j);(enlist 5j)!(enlist 6f);(enlist 7j)!(enlist 8e);(enlist 0b)!(enlist 1i);(enlist `one)!(enlist repeated_expected);(enlist `three)!(enlist submessage_expected));

.test.ASSERT_ERROR[saveMessageFromList; (`MapTest;  `map_file; map_wrong_value); "Invalid scalar type"]

.test.ASSERT_ERROR[saveMessageFromList; (`MapTestDynamic;  `map_file; map_wrong_value); "Invalid scalar type"]


-1 "\n+----------|| Test map with file and field name dictionary ||----------+\n";

// Protobuf maps are unordered and unsorted so use single item lists for each dictionary 
// element to perform a simple equality check.
map_fields:getMessageFields[`MapTest];
map_dict:map_fields!((enlist 1i)!(enlist 2j);(enlist 3i)!(enlist 4j);(enlist 5j)!(enlist 6f);(enlist 7j)!(enlist 8e);(enlist 0b)!(enlist 1i);(enlist `one)!(enlist scalars_expected_dict);(enlist `three)!(enlist submessage_expected_dict));

saveMessageFromDict[`MapTest; `map_file; map_dict];
.test.ASSERT_TRUE[loadMessageToDict; (`MapTest; `map_file); map_dict]

saveMessageFromDict[`MapTestDynamic;`map_file;map_dict]
.test.ASSERT_TRUE[loadMessageToDict; (`MapTestDynamic; `map_file); map_dict]

-1 "<--- Pass wrong type key --->";

map_wrong_key_dict:map_fields!((enlist 1i)!(enlist 2j);(enlist 0b)!(enlist 4j);(enlist 5j)!(enlist 6f);(enlist 7j)!(enlist 8e);(enlist 0b)!(enlist 1i);(enlist `one)!(enlist scalars_expected_dict);(enlist `three)!(enlist submessage_expected_dict));

.test.ASSERT_ERROR[saveMessageFromDict; (`MapTest;  `map_file; map_wrong_key_dict); "Invalid map element type"]

.test.ASSERT_ERROR[saveMessageFromDict; (`MapTestDynamic;  `map_file; map_wrong_key_dict); "Invalid map element type"]

-1 "<--- Pass wrong type value --->";

map_wrong_value_dict:map_fields!((enlist 1i)!(enlist 2j);(enlist 3i)!(enlist 0b);(enlist 5j)!(enlist 6f);(enlist 7j)!(enlist 8e);(enlist 0b)!(enlist 1i);(enlist `one)!(enlist scalars_expected_dict);(enlist `three)!(enlist submessage_expected_dict));

.test.ASSERT_ERROR[saveMessageFromDict; (`MapTest;  `map_file; map_wrong_value_dict); "Invalid map element type"]

.test.ASSERT_ERROR[saveMessageFromDict; (`MapTestDynamic;  `map_file; map_wrong_value_dict); "Invalid map element type"]


-1 "\n+----------|| Test map with array ||----------+\n";

-1 "<--- Pass correct data --->";

array:serializeArrayFromList[`MapTest; map];
.test.ASSERT_TRUE[parseArrayToList; (`MapTest; array); map]

array:serializeArrayFromList[`MapTestDynamic; map];
.test.ASSERT_TRUE[parseArrayToList; (`MapTestDynamic; array); map]

-1 "<--- Pass wrong type key --->";

.test.ASSERT_ERROR[serializeArrayFromList; (`MapTest; map_wrong_key); "Invalid map element type"]

.test.ASSERT_ERROR[serializeArrayFromList; (`MapTestDynamic; map_wrong_key); "Invalid map element type"]

-1 "<--- Pass wrong value type --->";

.test.ASSERT_ERROR[serializeArrayFromList; (`MapTest;  map_wrong_value); "Invalid scalar type"]

.test.ASSERT_ERROR[serializeArrayFromList; (`MapTestDynamic;  map_wrong_value); "Invalid scalar type"]


-1 "\n+----------|| Test map with array and field name dictionary ||----------+\n";

-1 "<--- Pass correct data --->";

array:serializeArrayFromDict[`MapTest; map_dict];
.test.ASSERT_TRUE[parseArrayToDict; (`MapTest; array); map_dict]

array:serializeArrayFromDict[`MapTestDynamic; map_dict];
.test.ASSERT_TRUE[parseArrayToDict; (`MapTestDynamic; array); map_dict]

-1 "<--- Pass wrong type key --->";

.test.ASSERT_ERROR[serializeArrayFromDict; (`MapTest; map_wrong_key_dict); "Invalid map element type"]

.test.ASSERT_ERROR[serializeArrayFromDict; (`MapTestDynamic; map_wrong_key_dict); "Invalid map element type"]

-1 "<--- Pass wrong value type --->";

.test.ASSERT_ERROR[serializeArrayFromDict; (`MapTest;  map_wrong_value_dict); "Invalid map element type"]

.test.ASSERT_ERROR[serializeArrayFromDict; (`MapTestDynamic;  map_wrong_value_dict); "Invalid map element type"]


-1 "\n+----------|| Test scalar specifiers with file ||----------+\n";

-1 "<--- Pass correct data --->";

scalar_specifiers:(2020.01.01D12:34:56.123456789; 2020.01m; 2020.01.01; 2020.01.01T12:34:56.123; 12:34:56.123456789; 12:34; 12:34:56; 12:34:56.123; (1?0Ng)0);

saveMessageFromList[`ScalarSpecifiersTest; `scalar_specifiers_file; scalar_specifiers];
.test.ASSERT_TRUE[loadMessageToList; (`ScalarSpecifiersTest; `scalar_specifiers_file); scalar_specifiers]

saveMessageFromList[`ScalarSpecifiersTestDynamic; `scalar_specifiers_file; scalar_specifiers];
.test.ASSERT_TRUE[loadMessageToList; (`ScalarSpecifiersTestDynamic; `scalar_specifiers_file); scalar_specifiers]

-1 "<--- Pass wrong type (compatible in q context but not in protobuf) --->";

scalar_specifiers_compatible:(631197296123456789; 240i; 73051; 7305.524; 45296123456789; 754; 45296; 45296123i; (1?0Ng)0);

.test.ASSERT_ERROR[saveMessageFromList; (`ScalarSpecifiersTest; `scalar_specifiers_file; scalar_specifiers_compatible); "Invalid scalar type"]

.test.ASSERT_ERROR[saveMessageFromList; (`ScalarSpecifiersTestDynamic; `scalar_specifiers_file; scalar_specifiers_compatible); "Invalid scalar type"]


-1 "\n+----------|| Test scalar specifiers with file and field name dictionary ||----------+\n";

-1 "<--- Pass correct data --->";

scalar_specifiers_fields:getMessageFields[`ScalarSpecifiersTest];
scalar_specifiers_dict:scalar_specifiers_fields!scalar_specifiers;

saveMessageFromDict[`ScalarSpecifiersTest; `scalar_specifiers_file; scalar_specifiers_dict];
.test.ASSERT_TRUE[loadMessageToDict; (`ScalarSpecifiersTest; `scalar_specifiers_file); scalar_specifiers_dict]

saveMessageFromDict[`ScalarSpecifiersTestDynamic; `scalar_specifiers_file; scalar_specifiers_dict];
.test.ASSERT_TRUE[loadMessageToDict; (`ScalarSpecifiersTestDynamic; `scalar_specifiers_file); scalar_specifiers_dict]

-1 "<--- Pass wrong type (compatible in q context but not in protobuf) --->";

scalar_specifiers_compatible_dict:scalar_specifiers_fields!scalar_specifiers_compatible;

.test.ASSERT_ERROR[saveMessageFromDict; (`ScalarSpecifiersTest; `scalar_specifiers_file; scalar_specifiers_compatible_dict); "Invalid scalar type"]

.test.ASSERT_ERROR[saveMessageFromDict; (`ScalarSpecifiersTestDynamic; `scalar_specifiers_file; scalar_specifiers_compatible_dict); "Invalid scalar type"]


-1 "\n+----------|| Test scalar specifiers with array ||----------+\n";

-1 "<--- Pass correct data --->";

array:serializeArrayFromList[`ScalarSpecifiersTest;scalar_specifiers];
.test.ASSERT_TRUE[parseArrayToList; (`ScalarSpecifiersTest; array); scalar_specifiers]

array:serializeArrayFromList[`ScalarSpecifiersTestDynamic;scalar_specifiers];
.test.ASSERT_TRUE[parseArrayToList; (`ScalarSpecifiersTestDynamic; array); scalar_specifiers]

-1 "<--- Pass wrong type (compatible in q context but not in protobuf) --->";

.test.ASSERT_ERROR[saveMessageFromList; (`ScalarSpecifiersTest; `scalar_specifiers_file; scalar_specifiers_compatible); "Invalid scalar type"]

.test.ASSERT_ERROR[saveMessageFromList; (`ScalarSpecifiersTestDynamic; `scalar_specifiers_file; scalar_specifiers_compatible); "Invalid scalar type"]


-1 "\n+----------|| Test scalar specifiers with array and field name dictionary ||----------+\n";

-1 "<--- Pass correct data --->";

array:serializeArrayFromDict[`ScalarSpecifiersTest;scalar_specifiers_dict];
.test.ASSERT_TRUE[parseArrayToDict; (`ScalarSpecifiersTest; array); scalar_specifiers_dict]

array:serializeArrayFromDict[`ScalarSpecifiersTestDynamic;scalar_specifiers_dict];
.test.ASSERT_TRUE[parseArrayToDict; (`ScalarSpecifiersTestDynamic; array); scalar_specifiers_dict]

-1 "<--- Pass wrong type (compatible in q context but not in protobuf) --->";

.test.ASSERT_ERROR[saveMessageFromDict; (`ScalarSpecifiersTest; `scalar_specifiers_file; scalar_specifiers_compatible_dict); "Invalid scalar type"]

.test.ASSERT_ERROR[saveMessageFromDict; (`ScalarSpecifiersTestDynamic; `scalar_specifiers_file; scalar_specifiers_compatible_dict); "Invalid scalar type"]


-1 "\n+----------|| Test repeated specifiers with file ||----------+\n";

-1 "<--- Pass correct data --->";

repeated_specifiers:scalar_specifiers,'scalar_specifiers;

saveMessageFromList[`RepeatedSpecifiersTest;`repeated_specifiers_file;repeated_specifiers];
.test.ASSERT_TRUE[loadMessageToList; (`RepeatedSpecifiersTest; `repeated_specifiers_file); repeated_specifiers]

saveMessageFromList[`RepeatedSpecifiersTestDynamic;`repeated_specifiers_file;repeated_specifiers];
.test.ASSERT_TRUE[loadMessageToList; (`RepeatedSpecifiersTestDynamic; `repeated_specifiers_file); repeated_specifiers]


-1 "<--- Pass wrong type and correct type (compatible in q context but not in protobuf) --->";

repeated_specifiers_mixture:scalar_specifiers ,' scalar_specifiers_compatible;

.test.ASSERT_ERROR[saveMessageFromList; (`RepeatedSpecifiersTest; `repeated_specifiers_file; repeated_specifiers_mixture); "Invalid repeated type"]

.test.ASSERT_ERROR[saveMessageFromList; (`RepeatedSpecifiersTestDynamic; `repeated_specifiers_file; repeated_specifiers_mixture); "Invalid repeated type"]


-1 "\n+----------|| Test repeated specifiers with file and field name dictionary ||----------+\n";

-1 "<--- Pass correct data --->";

repeated_specifiers_fields:getMessageFields[`RepeatedSpecifiersTest];
repeated_specifiers_dict:repeated_specifiers_fields!(scalar_specifiers,'scalar_specifiers);

saveMessageFromDict[`RepeatedSpecifiersTest;`repeated_specifiers_file;repeated_specifiers_dict];
.test.ASSERT_TRUE[loadMessageToDict; (`RepeatedSpecifiersTest; `repeated_specifiers_file); repeated_specifiers_dict]

saveMessageFromDict[`RepeatedSpecifiersTestDynamic;`repeated_specifiers_file;repeated_specifiers_dict];
.test.ASSERT_TRUE[loadMessageToDict; (`RepeatedSpecifiersTestDynamic; `repeated_specifiers_file); repeated_specifiers_dict]

-1 "<--- Pass wrong type and correct type (compatible in q context but not in protobuf) --->";

repeated_specifiers_mixture_dict:repeated_specifiers_fields!repeated_specifiers_mixture;

.test.ASSERT_ERROR[saveMessageFromDict; (`RepeatedSpecifiersTest; `repeated_specifiers_file; repeated_specifiers_mixture_dict); "Invalid repeated type"]

.test.ASSERT_ERROR[saveMessageFromDict; (`RepeatedSpecifiersTestDynamic; `repeated_specifiers_file; repeated_specifiers_mixture_dict); "Invalid repeated type"]


-1 "\n+----------|| Test repeated specifiers with array ||----------+\n";

-1 "<--- Pass correct data --->";

array:serializeArrayFromList[`RepeatedSpecifiersTest;repeated_specifiers];
.test.ASSERT_TRUE[parseArrayToList; (`RepeatedSpecifiersTest; array); repeated_specifiers]

array:serializeArrayFromList[`RepeatedSpecifiersTestDynamic; repeated_specifiers];
.test.ASSERT_TRUE[parseArrayToList; (`RepeatedSpecifiersTestDynamic; array); repeated_specifiers]

-1 "<--- Pass wrong type and specifiers --->";

.test.ASSERT_ERROR[serializeArrayFromList; (`RepeatedSpecifiersTest; repeated_specifiers_mixture); "Invalid repeated type"]

.test.ASSERT_ERROR[serializeArrayFromList; (`RepeatedSpecifiersTestDynamic; repeated_specifiers_mixture); "Invalid repeated type"]


-1 "\n+----------|| Test repeated specifiers with array and field name dictionary ||----------+\n";

-1 "<--- Pass correct data --->";

array:serializeArrayFromDict[`RepeatedSpecifiersTest;repeated_specifiers_dict];
.test.ASSERT_TRUE[parseArrayToDict; (`RepeatedSpecifiersTest; array); repeated_specifiers_dict]

array:serializeArrayFromDict[`RepeatedSpecifiersTestDynamic; repeated_specifiers_dict];
.test.ASSERT_TRUE[parseArrayToDict; (`RepeatedSpecifiersTestDynamic; array); repeated_specifiers_dict]

-1 "<--- Pass wrong type and specifiers --->";

.test.ASSERT_ERROR[serializeArrayFromDict; (`RepeatedSpecifiersTest; repeated_specifiers_mixture_dict); "Invalid repeated type"]

.test.ASSERT_ERROR[serializeArrayFromDict; (`RepeatedSpecifiersTestDynamic; repeated_specifiers_mixture_dict); "Invalid repeated type"]


-1 "\n+----------|| Test map specifiers with file ||----------+\n";

-1 "<--- Pass correct data --->";

map_specifiers:((enlist 2020.01.01D12:34:56.123456789)!(enlist 2020.01m);(enlist 2020.01.01)!(enlist 2020.01.01T12:34:56.123);(enlist 12:34:56.123456789)!(enlist 12:34);(enlist 12:34:56)!(enlist 12:34:56.123);(1?0Ng)!(1?0Ng));

saveMessageFromList[`MapSpecifiersTest;`map_specifiers_file;map_specifiers];
.test.ASSERT_TRUE[loadMessageToList; (`MapSpecifiersTest; `map_specifiers_file); map_specifiers]

saveMessageFromList[`MapSpecifiersTestDynamic;`map_specifiers_file;map_specifiers];
.test.ASSERT_TRUE[loadMessageToList; (`MapSpecifiersTestDynamic; `map_specifiers_file); map_specifiers]

-1 "<--- Pass wrong type (compatible in q context but not in protobuf) --->";

map_specifiers_compatible:((enlist 631197296123456789)!(enlist 240i);(enlist 7305i)!(enlist 7305.524);(enlist 45296123456789)!(enlist 754);(enlist 45296)!(enlist 45296123i);(1?0Ng)!(1?0Ng));

.test.ASSERT_ERROR[saveMessageFromList; (`MapSpecifiersTest; `map_specifiers_file; map_specifiers_compatible); "Invalid map element type"]

.test.ASSERT_ERROR[saveMessageFromList; (`MapSpecifiersTestDynamic; `map_specifiers_file; map_specifiers_compatible); "Invalid map element type"]


-1 "\n+----------|| Test map specifiers with file and field name dictionary ||----------+\n";

-1 "<--- Pass correct data --->";

map_specifiers_fields:getMessageFields[`MapSpecifiersTest];
map_specifiers_dict:map_specifiers_fields!map_specifiers;

saveMessageFromDict[`MapSpecifiersTest;`map_specifiers_file;map_specifiers_dict];
.test.ASSERT_TRUE[loadMessageToDict; (`MapSpecifiersTest; `map_specifiers_file); map_specifiers_dict]

saveMessageFromDict[`MapSpecifiersTestDynamic;`map_specifiers_file;map_specifiers_dict];
.test.ASSERT_TRUE[loadMessageToDict; (`MapSpecifiersTestDynamic; `map_specifiers_file); map_specifiers_dict]

-1 "<--- Pass wrong type (compatible in q context but not in protobuf) --->";

map_specifiers_compatible_dict:map_specifiers_fields!map_specifiers_compatible;

.test.ASSERT_ERROR[saveMessageFromDict; (`MapSpecifiersTest; `map_specifiers_file; map_specifiers_compatible_dict); "Invalid map element type"]

.test.ASSERT_ERROR[saveMessageFromDict; (`MapSpecifiersTestDynamic; `map_specifiers_file; map_specifiers_compatible_dict); "Invalid map element type"]


-1 "\n+----------|| Test map specifiers with array ||----------+\n";

-1 "<--- Pass correct data --->";

array:serializeArrayFromList[`MapSpecifiersTest; map_specifiers];
.test.ASSERT_TRUE[parseArrayToList; (`MapSpecifiersTest; array); map_specifiers]

array:serializeArrayFromList[`MapSpecifiersTestDynamic;map_specifiers];
.test.ASSERT_TRUE[parseArrayToList; (`MapSpecifiersTestDynamic; array); map_specifiers]

-1 "<--- Pass wrong type (compatible in q context but not in protobuf) --->";

.test.ASSERT_ERROR[serializeArrayFromList; (`MapSpecifiersTest; map_specifiers_compatible); "Invalid map element type"]

.test.ASSERT_ERROR[serializeArrayFromList; (`MapSpecifiersTestDynamic; map_specifiers_compatible); "Invalid map element type"]


-1 "\n+----------|| Test map specifiers with array and field name dictionary ||----------+\n";

-1 "<--- Pass correct data --->";

array:serializeArrayFromDict[`MapSpecifiersTest; map_specifiers_dict];
.test.ASSERT_TRUE[parseArrayToDict; (`MapSpecifiersTest; array); map_specifiers_dict]

array:serializeArrayFromDict[`MapSpecifiersTestDynamic;map_specifiers_dict];
.test.ASSERT_TRUE[parseArrayToDict; (`MapSpecifiersTestDynamic; array); map_specifiers_dict]

-1 "<--- Pass wrong type (compatible in q context but not in protobuf) --->";

.test.ASSERT_ERROR[serializeArrayFromDict; (`MapSpecifiersTest; map_specifiers_compatible_dict); "Invalid map element type"]

.test.ASSERT_ERROR[serializeArrayFromDict; (`MapSpecifiersTestDynamic; map_specifiers_compatible_dict); "Invalid map element type"]


-1 "\n+----------|| Test oneof permutations ||----------+\n";

-1 "<--- Pass correct data --->";

oneof1:(1.1f;();();"str");
oneof2:(();12:34:56;();"str");
oneof3:(();();(1j; 2.1 2.2f);"str");
oneofnone:(();();();"str");

.test.ASSERT_TRUE[parseArrayToList; (`OneofTest; serializeArrayFromList[`OneofTest;oneof1]); oneof1]
.test.ASSERT_TRUE[parseArrayToList; (`OneofTest; serializeArrayFromList[`OneofTest;oneof2]); oneof2]
.test.ASSERT_TRUE[parseArrayToList; (`OneofTest; serializeArrayFromList[`OneofTest;oneof3]); oneof3]
.test.ASSERT_TRUE[parseArrayToList; (`OneofTest; serializeArrayFromList[`OneofTest;oneofnone]); oneofnone]

.test.ASSERT_TRUE[parseArrayToList; (`OneofTestDynamic; serializeArrayFromList[`OneofTest;oneof1]); oneof1]
.test.ASSERT_TRUE[parseArrayToList; (`OneofTestDynamic; serializeArrayFromList[`OneofTest;oneof2]); oneof2]
.test.ASSERT_TRUE[parseArrayToList; (`OneofTestDynamic; serializeArrayFromList[`OneofTest;oneof3]); oneof3]
.test.ASSERT_TRUE[parseArrayToList; (`OneofTestDynamic; serializeArrayFromList[`OneofTest;oneofnone]); oneofnone]

-1 "<--- Pass wrong type data --->";

oneofwrong:(42i; (); (); "str");
.test.ASSERT_ERROR[serializeArrayFromList; (`OneofTest; oneofwrong); "Invalid scalar type"]

oneofwrong2:((); 123456; (); "str");
.test.ASSERT_ERROR[serializeArrayFromList; (`OneofTestDynamic; oneofwrong2); "Invalid scalar type"]

-1 "<--- Pass multiple populated data --->";

// If mulitple oneofs are set, only the last is populated
oneofall:(1.1f;12:34:56;(1j; 2.1 2.2f);"str");

.test.ASSERT_TRUE[parseArrayToList; (`OneofTest; serializeArrayFromList[`OneofTest; oneofall]); oneof3]

.test.ASSERT_TRUE[parseArrayToList; (`OneofTest; serializeArrayFromList[`OneofTestDynamic; oneofall]); oneof3]


-1 "\n+----------|| Test oneof permutations with field name dictionary ||----------+\n";

-1 "<--- Pass correct data --->";

oneof_fields:getMessageFields[`OneofTest];
oneof1_dict:oneof_fields!oneof1;
oneof2_dict:oneof_fields!oneof2;
oneofmsg_fields:getMessageFields[`OneofTest.OneofMsg];
oneof3_dict:oneof_fields!(();();oneofmsg_fields!(1j; 2.1 2.2f);"str");
oneofnone_dict:oneof_fields!oneofnone;

.test.ASSERT_TRUE[parseArrayToDict; (`OneofTest; serializeArrayFromDict[`OneofTest;oneof1_dict]); oneof1_dict]
.test.ASSERT_TRUE[parseArrayToDict; (`OneofTest; serializeArrayFromDict[`OneofTest;oneof2_dict]); oneof2_dict]
.test.ASSERT_TRUE[parseArrayToDict; (`OneofTest; serializeArrayFromDict[`OneofTest;oneof3_dict]); oneof3_dict]
.test.ASSERT_TRUE[parseArrayToDict; (`OneofTest; serializeArrayFromDict[`OneofTest;oneofnone_dict]); oneofnone_dict]

.test.ASSERT_TRUE[parseArrayToDict; (`OneofTestDynamic; serializeArrayFromDict[`OneofTest;oneof1_dict]); oneof1_dict]
.test.ASSERT_TRUE[parseArrayToDict; (`OneofTestDynamic; serializeArrayFromDict[`OneofTest;oneof2_dict]); oneof2_dict]
.test.ASSERT_TRUE[parseArrayToDict; (`OneofTestDynamic; serializeArrayFromDict[`OneofTest;oneof3_dict]); oneof3_dict]
.test.ASSERT_TRUE[parseArrayToDict; (`OneofTestDynamic; serializeArrayFromDict[`OneofTest;oneofnone_dict]); oneofnone_dict]

-1 "<--- Pass wrong type data --->";

onoofwrong_dict:oneof_fields!oneofwrong;
.test.ASSERT_ERROR[serializeArrayFromDict; (`OneofTest; onoofwrong_dict); "Invalid scalar type"]

oneofwrong2_dict:oneof_fields!oneofwrong2;
.test.ASSERT_ERROR[serializeArrayFromDict; (`OneofTestDynamic; oneofwrong2_dict); "Invalid scalar type"]

-1 "<--- Pass multiple populated data --->";

// If mulitple oneofs are set, only the last is populated
oneofall_dict:oneof_fields!(1.1f;12:34:56;oneofmsg_fields!(1j; 2.1 2.2f);"str");

.test.ASSERT_TRUE[parseArrayToDict; (`OneofTest; serializeArrayFromDict[`OneofTest; oneofall_dict]); oneof3_dict]

.test.ASSERT_TRUE[parseArrayToDict; (`OneofTest; serializeArrayFromDict[`OneofTestDynamic; oneofall_dict]); oneof3_dict]


-1 "\n+----------|| Finished testing ||----------+\n";
