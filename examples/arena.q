// arena.q
// Examples of serializing from and deserializing to kdb+ data with Google arena

-1"\n+----------|| arena.q ||----------+\n";

// import the Protobuf library
\l ../q/protobufkdb.q

// Move into the protobufkdb namespace
\d .protobufkdb

//-------------------------------------------------//
// Example-1. Serialize/Deserialize without arena  //
//-------------------------------------------------//

// Prepare huge submessage data
huge:submessage:((0i;0f;`str); (1000#enlist (`int$til 100; `float$til 100; 100#`str)));

// Serialize data into char array
serialized:.protobufkdb.serializeArray[`SubMessageExample; huge];
show serialized;

// Deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArray[`SubMessageExample; serialized];
show deserialized;

//----------------------------------------------//
// Example-2. Serialize/Deserialize with arena  //
//----------------------------------------------//

// Serialize data into char array
serialized:.protobufkdb.serializeArrayArena[`SubMessageExample; huge];
show serialized;

// Deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArrayArena[`SubMessageExample; serialized];
show deserialized;

-1 "\n+----------------------------------------+\n";

// Process off
exit 0;