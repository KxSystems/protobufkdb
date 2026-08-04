if[5>.z.K;system"d .protobufkdb"]
clib:$[5<=.z.K;use`.clib;(`protobufkdb 2:(`kexport;1))[]]

displayMessageSchema:{[x] -1 clib.getMessageSchema[x];};

saveMessageFromList:clib.saveMessage[;;;0b];
saveMessageFromDict:clib.saveMessage[;;;1b];

loadMessageToList:clib.loadMessage[;;0b];
loadMessageToDict:clib.loadMessage[;;1b];

serializeArrayFromList:clib.serializeArray[;;0b];
serializeArrayFromDict:clib.serializeArray[;;1b];

parseArrayToList:clib.parseArray[;;0b];
parseArrayToDict:clib.parseArray[;;1b];

serializeArrayArenaFromList:clib.serializeArrayArena[;;0b];
serializeArrayArenaFromDict:clib.serializeArrayArena[;;1b];

parseArrayArenaToList:clib.parseArrayArena[;;0b];
parseArrayArenaToDict:clib.parseArrayArena[;;1b];

loadMessageDebug:{[x;y] -1 clib.loadMessageDebug[x;y];};
parseArrayDebug:{[x;y] -1 clib.parseArrayDebug[x;y];};

clib.init[]

if[5<=.z.K;export:clib,`0clib`clib _ .z.m]
if[5>.z.K;{set'[key x;value x]}clib]