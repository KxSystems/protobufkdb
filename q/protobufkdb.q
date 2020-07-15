\d .protobufkdb

init:`protobufkdb 2:(`Init;1);
version:`protobufkdb 2:(`Version;1);
versionStr:`protobufkdb 2:(`VersionStr;1);

getMessageSchema:`protobufkdb 2:(`GetMessageSchema;1);
displayMessageSchema:{[x] -1 getMessageSchema[x];};

addProtoImportPath:`protobufkdb 2:(`AddProtoImportPath;1);
importProtoFile:`protobufkdb 2:(`ImportProtoFile;1);
listImportedMessageTypes:`protobufkdb 2:(`ListImportedMessageTypes;1);

saveMessage:`protobufkdb 2:(`SaveMessage;3);
loadMessage:`protobufkdb 2:(`LoadMessage;2);
serializeArray:`protobufkdb 2:(`SerializeArray;2);
parseArray:`protobufkdb 2:(`ParseArray;2);
serializeArrayArena:`protobufkdb 2:(`SerializeArrayArena;2);
parseArrayArena:`protobufkdb 2:(`ParseArrayArena;2);

init[]
