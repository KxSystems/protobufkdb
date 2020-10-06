// map.q
// Examples of serializing from and deserializing to map kdb+ data (dictionary)

-1"\n+----------|| map.q ||----------+\n";

// import the Protobuf library
\l ../q/protobufkdb.q

// Move into the protobufkdb namespace
\d .protobufkdb

//-------------------------------------//
// Example-1. Use compiled schema file //
//-------------------------------------//

// Show embeded schema of MapExample message
.protobufkdb.displayMessageSchema[`MapExample];

// Prepare map (dictionary list) data
map:(1 2j!3 4f;`s1`s2!((42i;1.58;`foo); (-30i;5.999;`bar)));

// Serialize data into char array
serialized:.protobufkdb.serializeArray[`MapExample; map];
show serialized;

// Deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArray[`MapExample; serialized];
show deserialized;

// Ordering of protobuf maps is undefined so compare using key lookups
show (count map)~(count deserialized);
show map[0][1]~deserialized[0][1];
show map[0][2]~deserialized[0][2];
show map[1][`s1]~deserialized[1][`s1];
show map[1][`s2]~deserialized[1][`s2];

//-------------------------------------------------//
// Example-2. Use dynamically imported schema file //
//-------------------------------------------------//

// Add impot path of schema file for dynamic schema import
.protobufkdb.addProtoImportPath["../proto"];

// Import schema file
.protobufkdb.importProtoFile["examples_dynamic.proto"];

// Show embeded schema of MapExampleDynamic message
.protobufkdb.displayMessageSchema[`MapExampleDynamic];

// Prepare map (dictionary list) data
map:(enlist[0]!enlist[100.4]; `s1`s2`s3!((-77i;29.123;`foo); (1260i;3.14;`bar); (3i;0.0001;`po)));

// Serialize data into char array
serialized:.protobufkdb.serializeArray[`MapExampleDynamic; map];
show serialized;

// Deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArray[`MapExampleDynamic; serialized];
show deserialized;

// Ordering of protobuf maps is undefined so compare using key lookups
show (count map)~(count deserialized);
show map[0][0]~deserialized[0][0];
show map[1][`s1]~deserialized[1][`s1];
show map[1][`s2]~deserialized[1][`s2];
show map[1][`s3]~deserialized[1][`s3];

-1 "\n+----------------------------------------+\n";

// Process off
exit 0;