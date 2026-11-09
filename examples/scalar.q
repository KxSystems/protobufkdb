// scalar.q
// Examples of serializing from and deserializing to scalar KDB-X data (atom)

-1"\n+----------|| scalar.q ||----------+\n";

// import the Protobuf library
.protobufkdb:use`kx.protobuf;

//-------------------------------------//
// Example-1. Use compiled schema file //
//-------------------------------------//

// Show embeded schema of ScalarExample message
.protobufkdb.displayMessageSchema[`ScalarExample];

// Prepare scalar (atom) data
scalars:(12i;55f;"str");

// Serialize data into char array
serialized:.protobufkdb.serializeArrayFromList[`ScalarExample; scalars];
show serialized;

// Deserialize char array into KDB-X data
deserialized:.protobufkdb.parseArrayToList[`ScalarExample; serialized];
show deserialized;

// Compare the KDB-X objects
show scalars~deserialized

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

// Display imported schema of ScalarExampleDynamic message
.protobufkdb.displayMessageSchema[`ScalarExampleDynamic];

// Prepare scalar data
scalars:(12i;55f;"str");

// Serialize data into char array
serialized:.protobufkdb.serializeArrayFromList[`ScalarExampleDynamic; scalars];
show serialized;

// Deserialize char array into KDB-X data
deserialized:.protobufkdb.parseArrayToList[`ScalarExampleDynamic; serialized];
show deserialized;

// Compare the KDB-X objects
show scalars~deserialized

-1 "\n+----------------------------------------+\n";

// Process off
exit 0;