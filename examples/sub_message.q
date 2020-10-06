// sub_message.q
// Examples of serializing from and deserializing to sub_message kdb+ data (mixed list)

-1"\n+----------|| sub_message.q ||----------+\n";

// import the Protobuf library
\l ../q/protobufkdb.q

// Move into the protobufkdb namespace
\d .protobufkdb

//-------------------------------------//
// Example-1. Use compiled schema file //
//-------------------------------------//

// Show embeded schema of SubMessageExample message
.protobufkdb.displayMessageSchema[`SubMessageExample];

// Prepare sub message (mixed list) data
submessage:((12i;55f;`str); ((1 2i;-12.3 20.492f;`s1`s2); (3 4 5i;-102.1048 -732.239 -39.201f;enlist `s2)));

// Serialize data into char array
serialized:.protobufkdb.serializeArray[`SubMessageExample; submessage];
show serialized;

// Deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArray[`SubMessageExample; serialized];
show deserialized;

// Compare the kdb+ objects
show submessage~deserialized

//-------------------------------------------------//
// Example-2. Use dynamically imported schema file //
//-------------------------------------------------//

// Add impot path of schema file for dynamic schema import
.protobufkdb.addProtoImportPath["../proto"];

// Import schema file
.protobufkdb.importProtoFile["examples_dynamic.proto"];

// Show embeded schema of SubMessageExampleDynamic message
.protobufkdb.displayMessageSchema[`SubMessageExampleDynamic];

// Prepare sub message (mixed list) data
submessage:((-2i;2.5;`str); ((-44 3i;2.47 8.9 -0.492f;enlist `s2); (90 13 25i;38.9472 39.71f; `str1`str2)));

// Serialize data into char array
serialized:.protobufkdb.serializeArray[`SubMessageExampleDynamic; submessage];
show serialized;

// Deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArray[`SubMessageExampleDynamic; serialized];
show deserialized;

// Compare the kdb+ objects
show submessage~deserialized

-1 "\n+----------------------------------------+\n";

// Process off
exit 0;