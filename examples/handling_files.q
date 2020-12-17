// handling_files.q
// Examples of saving kdb+ data into a file with serializing using Protobuf schema file
// and loading the file with deserializing

-1"\n+----------|| handling_files.q ||----------+\n";

// import the Protobuf library
\l ../q/protobufkdb.q

// Prepare data to be saved
scalars:(12i;55f;"str");

// Save the data to a file named "sample_scalars_file"
.protobufkdb.saveMessageFromList[`ScalarExample; `sample_scalars_file; scalars];

// Load the file
loaded:.protobufkdb.loadMessageToList[`ScalarExample; `sample_scalars_file];
show loaded;

// Compare the kdb+ objects
show scalars~loaded

-1 "\n+----------------------------------------+\n";

// Process off
exit 0;