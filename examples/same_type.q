// same_type.q
// Examples of serializing from and deserializing to general list kdb+ data each element of which has the same type.

-1"\n+----------|| same_type.q ||----------+\n";

// import the Protobuf library
\l ../q/protobufkdb.q

// Add impot path of schema file for dynamic schema import
.protobufkdb.addProtoImportPath["../proto"];

// Import schema file
.protobufkdb.importProtoFile["examples_dynamic.proto"];

//-------------------------------------//
// Example-1. Same type atom elements  //
//-------------------------------------//

// Display imported schema of SametypeExampleDynamic message
.protobufkdb.displayMessageSchema[`SametypeExampleDynamic];

// Prepare general list with same type elements.
// Note that the list of same type atom elements must have `::` at the tail to make it a general list.
triple:(39.27524; 51.70911; 51.59796; ::);

// Serialize data into char array
serialized:.protobufkdb.serializeArrayFromList[`SametypeExampleDynamic; triple];
show serialized;

// Deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArrayToList[`SametypeExampleDynamic; serialized];
show deserialized;

// Compare the kdb+ objects.
// Note that returned list does not have `::` any more but still its type is general list.
show triple ~ deserialized, (::);

//-------------------------------------//
// Example-2. Same type list elements  //
//-------------------------------------//

// Display imported schema of SametypeExampleDynamic2 message
.protobufkdb.displayMessageSchema[`SametypeExampleDynamic2];

// Prepare general list with same type elements.
// Note: As list of string is a general list, we don't need to append `::` at the tail.
triple:("single"; "double"; "triple");

// Serialize data into char array
serialized:.protobufkdb.serializeArrayFromList[`SametypeExampleDynamic2; triple];
show serialized;

// Deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArrayToList[`SametypeExampleDynamic2; serialized];
show deserialized;

// Compare the kdb+ objects.
show triple~deserialized;

-1 "\n+----------------------------------------+\n";

// Process off
exit 0;