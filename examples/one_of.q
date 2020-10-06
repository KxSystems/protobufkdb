// one_of.q
// Examples of serializing from and deserializing to oneof kdb+ data

-1"\n+----------|| one_of.q ||----------+\n";

// import the Protobuf library
\l ../q/protobufkdb.q

// Move into the protobufkdb namespace
\d .protobufkdb

//-------------------------------------//
// Example-1. Use compiled schema file //
//-------------------------------------//

// Show embeded schema of OneofExample message
.protobufkdb.displayMessageSchema[`OneofExample];

// Prepare oneof data
// Note that the third element (string) is not oneof message
oneof:(1.1f;();`str);

// Serialize data into char array
serialized:.protobufkdb.serializeArray[`OneofExample; oneof];
show serialized;

// Deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArray[`OneofExample; serialized];
show deserialized;

// Compare the kdb+ objects
show oneof~deserialized

// Serialize into char array and then deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArray[`OneofExample;.protobufkdb.serializeArray[`OneofExample;(();12:34:56;`str)]];
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
oneof:(-35.712f;();`str);

// Serialize data into char array
serialized:.protobufkdb.serializeArray[`OneofExampleDynamic; oneof];
show serialized;

// Deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArray[`OneofExampleDynamic; serialized];
show deserialized;

// Compare the kdb+ objects
show oneof~deserialized

// Serialize into char array and then deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArray[`OneofExampleDynamic;.protobufkdb.serializeArray[`OneofExampleDynamic;(();00:01:02;`foo)]];
show deserialized;

-1 "\n+----------------------------------------+\n";

// Process off
exit 0;