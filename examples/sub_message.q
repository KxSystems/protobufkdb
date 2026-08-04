// sub_message.q
// Examples of serializing from and deserializing to sub_message kdb+ data (mixed list)

-1"\n+----------|| sub_message.q ||----------+\n";

// import the Protobuf library
$[5<=.z.K;.protobufkdb:use`kx.protobuf;system"l q/init.q"];

//-------------------------------------//
// Example-1. Use compiled schema file //
//-------------------------------------//

// Show embeded schema of SubMessageExample message
.protobufkdb.displayMessageSchema[`SubMessageExample];

// Prepare sub message (mixed list) data
submessage:((12i;55f;"str"); ((1 2i;-12.3 20.492f;("s1";"s2")); (3 4 5i;-102.1048 -732.239 -39.201f;enlist "s2")));

// Serialize data into char array
serialized:.protobufkdb.serializeArrayFromList[`SubMessageExample; submessage];
show serialized;

// Deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArrayToList[`SubMessageExample; serialized];
show deserialized;

// Compare the kdb+ objects
show submessage~deserialized

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

// Show embeded schema of SubMessageExampleDynamic message
.protobufkdb.displayMessageSchema[`SubMessageExampleDynamic];

// Prepare sub message (mixed list) data
submessage:((-2i;2.5;"str"); ((-44 3i;2.47 8.9 -0.492f;enlist "s2"); (90 13 25i;38.9472 39.71f; ("str1";"str2"))));

// Serialize data into char array
serialized:.protobufkdb.serializeArrayFromList[`SubMessageExampleDynamic; submessage];
show serialized;

// Deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArrayToList[`SubMessageExampleDynamic; serialized];
show deserialized;

// Compare the kdb+ objects
show submessage~deserialized

-1 "\n+----------------------------------------+\n";

// Process off
exit 0;