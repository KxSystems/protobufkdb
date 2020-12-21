// oneof.q
// Examples of serializing from and deserializing to oneof kdb+ data

-1"\n+----------|| oneof.q ||----------+\n";

// import the Protobuf library
\l ../q/protobufkdb.q

//-------------------------------------//
// Example-1. Use compiled schema file //
//-------------------------------------//

// Show embeded schema of OneofExample message
.protobufkdb.displayMessageSchema[`OneofExample];

// Prepare oneof data
// Note that the third element (string) is not oneof message
oneof:(1.1f;();"str");

// Serialize data into char array
serialized:.protobufkdb.serializeArrayFromList[`OneofExample; oneof];
show serialized;

// Deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArrayToList[`OneofExample; serialized];
show deserialized;

// Compare the kdb+ objects
show oneof~deserialized

// Serialize into char array and then deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArrayToList[`OneofExample;.protobufkdb.serializeArrayFromList[`OneofExample;(();12:34:56;"str")]];
show deserialized;

//-------------------------------------------------//
// Example-2. Use dynamically imported schema file //
//-------------------------------------------------//

// Add impot path of schema file for dynamic schema import
.protobufkdb.addProtoImportPath["../proto"];

// Import schema file
.protobufkdb.importProtoFile["examples_dynamic.proto"];

// Show embeded schema of OneofExampleDynamic message
.protobufkdb.displayMessageSchema[`OneofExampleDynamic];

// Prepare oneof data
// Note that the third element (string) is not oneof message
oneof:(-35.712f;();"str");

// Serialize data into char array
serialized:.protobufkdb.serializeArrayFromList[`OneofExampleDynamic; oneof];
show serialized;

// Deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArrayToList[`OneofExampleDynamic; serialized];
show deserialized;

// Compare the kdb+ objects
show oneof~deserialized

// Serialize into char array and then deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArrayToList[`OneofExampleDynamic;.protobufkdb.serializeArrayFromList[`OneofExampleDynamic;(();00:01:02;"foo")]];
show deserialized;

-1 "\n+----------------------------------------+\n";

// Process off
exit 0;