// arena.q
// Examples of serializing from and deserializing to kdb+ data with Google arena
//
// Note:
// The performance of Google Arenas with Protocol Buffers is highly architecture dependent.
// Typically on Windows and Mac a significant improvement is observed in both serialization and parsing times.
// However, on Linux an improvement is only observed with parsing, changes to the serialization performance
// is negligible or slightly worse.
// There can also be a noticeable variation in timings from one run to the next depending on the stability of
// the system memory allocator (how susceptible it is to fragmentation).

-1"\n+----------|| arena.q ||----------+\n";

// import the Protobuf library
\l ../q/protobufkdb.q

// Prepare huge submessage data
huge:submessage:((0i;0f;`str); (10000#enlist (`int$til 100; `float$til 100; 100#enlist "str")));

-1 "Time for serialiation without arena";
// Serialize data into char array
\t serialized:.protobufkdb.serializeArrayFromList[`SubMessageExample; huge];
show serialized;

-1 "Time for serialiation with arena";
// Serialize data into char array
\t serialized:.protobufkdb.serializeArrayArenaFromList[`SubMessageExample; huge];
show serialized;

-1 "Time for deserialiation without arena";
// Deserialize char array into kdb+ data
\t deserialized:.protobufkdb.parseArrayToList[`SubMessageExample; serialized];
show deserialized;

-1 "Time for deserialiation with arena";
// Deserialize char array into kdb+ data
\t deserialized:.protobufkdb.parseArrayArenaToList[`SubMessageExample; serialized];
show deserialized;

-1 "\n+----------------------------------------+\n";

// Process off
exit 0;