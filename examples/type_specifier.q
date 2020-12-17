// repeated.q
// Examples of serializing from and deserializing to type specified kdb+ data

-1"\n+----------|| type_specified.q ||----------+\n";

// import the Protobuf library
\l ../q/protobufkdb.q

//-------------------------------------//
// Example-1. Use compiled schema file //
//-------------------------------------//

// Show embeded schema of SpecifierExample message
.protobufkdb.displayMessageSchema[`SpecifierExample];

// Prepare type specified data
type_specified:(2020.01.01;enlist 12:34:56.123;(1?0Ng)!(enlist 12:34:56.123456789));

// Serialize data into char array
serialized:.protobufkdb.serializeArrayFromList[`SpecifierExample; type_specified];
show serialized;

// Deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArrayToList[`SpecifierExample;serialized];
show deserialized;

// Compare the kdb+ objects
show type_specified~deserialized

//-------------------------------------------------//
// Example-2. Use dynamically imported schema file //
//-------------------------------------------------//

// Add impot path of schema file for dynamic schema import
.protobufkdb.addProtoImportPath["../proto"];

// Import schema file
.protobufkdb.importProtoFile["examples_dynamic.proto"];

// Show embeded schema of SpecifierExampleDynamic message
.protobufkdb.displayMessageSchema[`SpecifierExampleDynamic];

// Prepare type specified data
type_specified:(2008.02.29;00:30:58 12:34:56.123;(2?0Ng)!2D00:00:00:000000001 12:34:56.123456789);

// Serialize data into char array
serialized:.protobufkdb.serializeArrayFromList[`SpecifierExampleDynamic; type_specified];
show serialized;

// Deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArrayToList[`SpecifierExampleDynamic;serialized];
show deserialized;

// Compare the kdb+ objects
show type_specified~deserialized

-1 "\n+----------------------------------------+\n";

// Process off
exit 0;