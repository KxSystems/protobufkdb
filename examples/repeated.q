// repeated.q
// Examples of serializing from and deserializing to repeated kdb+ data (simple list)

-1"\n+----------|| repeated.q ||----------+\n";

// import the Protobuf library
$[5<=.z.K;.protobufkdb:use`kx.protobuf;system"l q/init.q"];

//-------------------------------------//
// Example-1. Use compiled schema file //
//-------------------------------------//

// Show embeded schema of RepeatedExample message
.protobufkdb.displayMessageSchema[`RepeatedExample];

// Prepare repeated (simple list) data
repeated:(1 2i;10 -20f;("s1";"s2"));

// Serialize data into char array
serialized:.protobufkdb.serializeArrayFromList[`RepeatedExample; repeated];
show serialized;

// Deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArrayToList[`RepeatedExample; serialized];
show deserialized;

// Compare the kdb+ objects
show repeated~deserialized

//-------------------------------------------------//
// Example-2. Use dynamically imported schema file //
//-------------------------------------------------//

// Add import path of schema file for dynamic schema import
.protobufkdb.addProtoImportPath["../proto"];
if[not""~getenv`CONDA_PREFIX;
 .protobufkdb.addProtoImportPath[(getenv`CONDA_PREFIX),"/include"]
 ]

// Import schema file
.protobufkdb.importProtoFile["examples_dynamic.proto"];

// Show embeded schema of RepeatedExampleDynamic message
.protobufkdb.displayMessageSchema[`RepeatedExampleDynamic];

// Prepare repeated (simple list) data
repeated:(1 -2 -3i; 102.4 0.3971f; enlist "str");

// Serialize data into char array
serialized:.protobufkdb.serializeArrayFromList[`RepeatedExampleDynamic; repeated];
show serialized;

// Deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArrayToList[`RepeatedExampleDynamic; serialized];
show deserialized;

// Compare the kdb+ objects
show repeated~deserialized

-1 "\n+----------------------------------------+\n";

// Process off
exit 0;