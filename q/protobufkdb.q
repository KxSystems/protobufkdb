\d .protobufkdb

init:`protobufkdb 2:(`Init;1);
version:`protobufkdb 2:(`Version;1);
versionStr:`protobufkdb 2:(`VersionStr;1);

getMessageSchema:`protobufkdb 2:(`GetMessageSchema;1);
displayMessageSchema:{[x] -1 getMessageSchema[x];};

getMessageFields:`protobufkdb 2:(`GetMessageFields;1);

addProtoImportPath:`protobufkdb 2:(`AddProtoImportPath;1);
importProtoFile:`protobufkdb 2:(`ImportProtoFile;1);
listImportedMessageTypes:`protobufkdb 2:(`ListImportedMessageTypes;1);

saveMessage:`protobufkdb 2:(`SaveMessage;4);
saveMessageFromList:saveMessage[;;;0b];
saveMessageFromDict:saveMessage[;;;1b];

loadMessage:`protobufkdb 2:(`LoadMessage;3);
loadMessageToList:loadMessage[;;0b];
loadMessageToDict:loadMessage[;;1b];

serializeArray:`protobufkdb 2:(`SerializeArray;3);
serializeArrayFromList:serializeArray[;;0b];
serializeArrayFromDict:serializeArray[;;1b];

parseArray:`protobufkdb 2:(`ParseArray;3);
parseArrayToList:parseArray[;;0b];
parseArrayToDict:parseArray[;;1b];

serializeArrayArena:`protobufkdb 2:(`SerializeArrayArena;3);
serializeArrayArenaFromList:serializeArrayArena[;;0b];
serializeArrayArenaFromDict:serializeArrayArena[;;1b];

parseArrayArena:`protobufkdb 2:(`ParseArrayArena;3);
parseArrayArenaToList:parseArrayArena[;;0b];
parseArrayArenaToDict:parseArrayArena[;;1b];

LoadMessageDebug:`protobufkdb 2:(`LoadMessageDebug;2);
loadMessageDebug:{[x;y] -1 LoadMessageDebug[x;y];};
ParseArrayDebug:`protobufkdb 2:(`ParseArrayDebug;2);
parseArrayDebug:{[x;y] -1 ParseArrayDebug[x;y];};

init[]
