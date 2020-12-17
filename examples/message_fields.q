// message_fields.q
// Examples of serializing from and deserializing to kdb+ data using field name dictionaries for proto messages

-1"\n+----------|| message_fields.q ||----------+\n";

// import the Protobuf library
\l ../q/protobufkdb.q

//------------------------------------------------------//
// Example-1. Trivial message without submessage fields //
//------------------------------------------------------//

// Show embeded schema of ScalarExample message
.protobufkdb.displayMessageSchema[`ScalarExample];

// Get the symbol list of field names in the ScalarExample message
scalar_fields:.protobufkdb.getMessageFields[`ScalarExample];

// Prepare scalar (atom) data for field values
scalar_values:(12i;55f;"str");

// Create dictionary from field names to field values
scalars:scalar_fields!scalar_values;

// Serialize data into char array
serialized:.protobufkdb.serializeArrayFromDict[`ScalarExample; scalars];
show serialized;

// Deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArrayToDict[`ScalarExample; serialized];
show deserialized;

// Compare the kdb+ objects
show scalars~deserialized

//-------------------------------------------//
// Example-2. Message with submessage fields //
//-------------------------------------------//

// Show embeded schema of SubMessageExample message
.protobufkdb.displayMessageSchema[`SubMessageExample];

// Prepare ScalarExample sub-message for sub_scalar field
.protobufkdb.displayMessageSchema[`ScalarExample];
scalar_fields:.protobufkdb.getMessageFields[`ScalarExample];
scalar_values:(12i;55f;"str");
scalars:scalar_fields!scalar_values;

// Prepare RepeatedExample sub-message for sub_rep field
.protobufkdb.displayMessageSchema[`RepeatedExample];
repeated_fields:.protobufkdb.getMessageFields[`RepeatedExample];
repeated_values:(1 2i;10 -20f;("s1";"s2"));
repeated:repeated_fields!repeated_values;

// Get the symbol list of field names in the SubMessageExample message
submessage_fields:.protobufkdb.getMessageFields[`SubMessageExample];

// Prepare sub-message field values
submessage_values:(scalars;enlist repeated);

// Create dictionary from field names to field values
submessage:submessage_fields!submessage_values;

// Serialize data into char array
serialized:.protobufkdb.serializeArrayFromDict[`SubMessageExample; submessage];
show serialized;

// Deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArrayToDict[`SubMessageExample; serialized];
show deserialized;

// Compare the kdb+ objects
show submessage~deserialized

//---------------------------------------------------//
// Example-3. Message with map to sub-message fields //
//---------------------------------------------------//

// Show embeded schema of MapExample message
.protobufkdb.displayMessageSchema[`MapExample];

// Prepare ScalarExample sub-message for map_msg field
.protobufkdb.displayMessageSchema[`ScalarExample];
scalar_fields:.protobufkdb.getMessageFields[`ScalarExample];
scalar_values:(12i;55f;"str");
scalars:scalar_fields!scalar_values;

// Get the symbol list of field names in the MapExample message
map_fields:.protobufkdb.getMessageFields[`MapExample];

// Prepare map (dictionary) data for field values
map_values:(1 2j!3 4f;`s1`s2!(scalars; scalars));

// Create dictionary from field names to field values
map:map_fields!map_values;

// Serialize data into char array
serialized:.protobufkdb.serializeArrayFromDict[`MapExample; map];
show serialized;

// Deserialize char array into kdb+ data
deserialized:.protobufkdb.parseArrayToDict[`MapExample; serialized];
show deserialized;

// Compare the kdb+ objects
show map~deserialized

-1 "\n+----------------------------------------+\n";

// Process off
exit 0;
