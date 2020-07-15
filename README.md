# protobufkdb


## Introduction

This interface allows kdb+ users to parse data which has been encoded using Google Protocol Buffers [(protobuf)](https://github.com/protocolbuffers/protobuf) into kdb according to the proto schema and serialise it back to the encoded wire format. The interface utilises the libprotobuf descriptor and reflection C++  [APIs](https://developers.google.com/protocol-buffers/docs/reference/cpp#google.protobuf).

This is part of the [*Fusion for kdb+*](http://code.kx.com/q/interfaces/fusion/) interface collection.



## New to kdb+ ?

Kdb+ is the world's fastest time-series database, optimized for  ingesting, analyzing and storing massive amounts of structured data. To  get started with kdb+, please visit https://code.kx.com/q/learn/ for downloads and developer information. For general information, visit https://kx.com/



## New to Protocol Buffers ?

Protocol Buffers (Protobuf) is a language-neutral, platform-neutral, extensible mechanism for serializing structured data. It is used both in the development of programs which are required to communicate over the wire or for data storage. Developed originally for internal use by Google, it is released under an open source BSD license. The core principle behind this data format is to allow a user to define the expected structure of their data and incorporate this within specially generated source code. This allows a user to easily read and write structured data to and from a variety of languages. You can find [protobuf's documentation on the Google Developers site](https://developers.google.com/protocol-buffers/docs/overview).



## Importing protobuf schema files

Protobuf messages are defined in a `.proto` schema file and these message definitions must be imported into the interface in order for it to be able to create messages of those types.  The interface supports two ways to do this (or a combination of both) but the method used will impact how protobufkdb should be installed.

### 1.  Compiling in the generated message definitions

Normally the protocol buffers compiler is used to generate source code from the `.proto` schema files which is then compiled in to the binary:

protoc compiles your message definitions based on a file defined as:

```bash
<schema>.proto
```

producing both a C++ source and header file defined as:

```bash
<schema>.pb.cc
<schema>.pb.h
```

These files contain the classes and metadata which describe the schema and the functionality required to serialise to and parse from this schema.

This mechanism is more performant but does require that protobufkdb be built from source since the binary needs to be rebuilt to change the statically available messages.

### 2.  Dynamically importing the message definitions at runtime

In order to provide greater flexibility and usability it is also possible to dynamically import a `.proto` schema file at runtime from within the q session.  Imported message definitions can then be used subsequently by the interface and behave similarly to compiled in ones (the import procedure leverages the same functionality as used by the protobuf compiler).

If only dynamically imported message definitions are required then the packaged installation of protobufkdb can be used.  However, importing message definitions is less performant - in addition to the one off import cost there is also an overhead from the subsequent use of these dynamically created messages (approx. 10% for parsing, 20% for serialising).  Alternatively a hybrid approach can be employed where dynamic messages are used during development until the schemas are finalised at which point they are compiled into the interface.



## Installation

### Requirements

- kdb+ ≥ 3.5 64-bit (Linux/MacOS/Windows)
- protobuf ≥ 3.0 (recommended [^1])
- C++11 or later [^2] 
- CMake ≥ 3.1 [^2]

[^1]: Protocol Buffers language version 3 ([proto3](https://developers.google.com/protocol-buffers/docs/proto3)) simplifies the protocol buffer language, both for ease of use and to make it available in a  wider range of programming languages.  However, schemas defined in [proto2](https://developers.google.com/protocol-buffers/docs/cpptutorial) should also be supported.

[^2]: Required when building from source

### Installing a release

The protobufkdb releases are linked statically against libprotobuf to avoid potential C++ ABI [compatibility issues](https://github.com/protocolbuffers/protobuf/tree/master/src#binary-compatibility-warning) with different versions of libprotobuf.  Therefore it is not necessary to install protobuf separately when used a packaged release.

1. Download a release from [here](https://github.com/KxSystems/protobufkdb/releases)

2. Install required q executable script `q/protobufkdb.q` and binary file `lib/protobufkdb.(so|dll)` to `$QHOME` and `$QHOME/[mlw](64)`, by executing the following from the Release directory

   ```bash
   ## Linux/MacOS
   chmod +x install.sh && ./install.sh
   
   ## Windows
   install.bat
   ```

3. If you wish to use the KdbTypeSpecifier field option (described below) with dynamic messages then the directory containing `kdb_type_specifier.proto` must be specified to the interface as an import search location.  In the release package `kdb_type_specifier.proto` (and its dependencies) are found in the `proto` subdirectory.  Import paths can be relative or absolute.  For example, if the q session is started from the root of the release package run:

   ```
   q).protobufkdb.addProtoImportPath["proto"]
   ```

### Building and installing from source

#### Third-Party Library Installation

You can check whether protocol buffers is already installed and its version by running:

```bash
protoc --version
```

If not installed or you wish to upgrade please follow Google's C++ installation instructions [here](https://github.com/protocolbuffers/protobuf/blob/master/src/README.md).

**Note**: When building from source on Linux/MacOS you must pass `-fPIC` to the autoconf generated `configure` script since protobufkdb builds a shared object:

```
./configure --prefix=/usr "CFLAGS=-fPIC" "CXXFLAGS=-fPIC"
```

On MacOS, a brew packaged version of protobuf can be used as long as it includes the the protoc compiler, headers and libprotobuf.

On Linux, although there are numerous packaged versions of protobuf, it is recommended that you build from source.  There is a large disto dependent variation in the `apt-get` packages and unless the package was build with `-fPIC`, symbol relocation errors will occur during linking of protobufkdb.  Similarly `conda` packages can cause problems for the cmake functionality used by protobufkdb to locate the protobuf installation on the system.

On Windows, it is also recommended that you build from source using the cmake instructions [here](https://github.com/protocolbuffers/protobuf/blob/master/cmake/README.md).  The vcpkg installation of protobuf currently builds a DLL rather than a static library (open [issue](https://github.com/microsoft/vcpkg/issues/7936)) which is [not recommended](https://github.com/protocolbuffers/protobuf/blob/master/cmake/README.md#dlls-vs-static-linking) by Google and will cause problems since protobufkdb builds a DLL.

#### Add the protobuf schema files to the build procedure

protobufkdb uses a factory to create a message class object of the correct type from the message type string passed from kdb.  The lookup requires that the message type string passed from kdb is the same as the message name in its .proto definition.

In order to populate the factory, the .proto files for all messages to be serialised/parsed must be incorporated into the build as follows:

1. Place the new `<schema>.proto` file into the `src/` subdirectory
2. Edit `src/CMakeLists.txt` file, adding the new .proto file to the line below the following comment:

  ```cmake
  # ### GENERATE PROTO FILES ###
  ```

  For example, to add `examples.proto` (which is already present in the `src/` subdirectory), in addition to the existing `tests.proto`, change:

  ```cmake
  set(MY_PROTO_FILES tests.proto)
  ```

  to:

  ```cmake
  set(MY_PROTO_FILES tests.proto examples.proto)
  ```

**Note:** `MY_PROTO_FILES` is a CMake space separated list, do not wrap the list of .proto files in a string.

#### Building protobufkdb

A cmake script is provided to build protobufkdb. This uses the cmake functionality to locate the protobuf installation on your system. From the root of this repository create and move into a directory in which to perform the build:

```bash
mkdir build && cd build
```

Generate the scripts for your system's default build tools:

```bash
cmake ..
```

Start the build:

```bash
cmake --build . --config Release
```

Create the install package and deploy:

```bash
cmake --build . --config Release --target install
```

**Note:**  By default `src/CMakeLists.txt` is configured to link statically against libprotobuf to avoid potential C++ ABI [compatibility issues](https://github.com/protocolbuffers/protobuf/tree/master/src#binary-compatibility-warning) with different versions of libprotobuf.  This is a particular issue on [Windows](https://github.com/protocolbuffers/protobuf/blob/master/cmake/README.md#dlls-vs-static-linking).



## Protobuf / Kdb Mappings

### Overview

A protobuf message is composed of a number of fields where each field can be scalar, repeated scalar, sub-message, repeated sub-message, enum or map.  For example:

```protobuf
message MyMessage {
  int32 scalar_int = 1;
  repeated double repeated_double = 2;
  MyMessage sub_message = 3;
  repeated MyMessage repeated_msg = 4;
  enum EnumType {
    ZERO = 0;
    ONE = 1;
  }
  EnumType enum_field = 5;
  map<int64, string> int_str = 6;
}
```

A message is represented in kdb using a mixed list of length equal to the number of fields in the message.  The fields are iterated in the order they are declared in the message definition (which may be different to the field number tags).

The kdb type of each list item depends on the field type:

| <u>Field Type</u>    | <u>**Kdb Type**</u>         |
| -------------------- | --------------------------- |
| Scalar               | Atom                        |
| Repeated scalar      | Simple list                 |
| Sub-message          | Mixed list                  |
| Repeated sub-message | Mixed list (of mixed lists) |
| Enum                 | Int of enum value           |
| Map                  | Dictionary                  |

### Scalar Fields

Scalar fields are represented as kdb atoms depending on the scalar type:

| <u>Scalar Type</u>      | <u>C++ Type</u> | <u>Kdb Type</u> |
| ----------------------- | --------------- | --------------- |
| int32, sint32, sfixed32 | int32           | -KI             |
| uint32, fixed32         | int32           | -KI             |
| int64, sint64, sfixed64 | int64           | -KJ             |
| uint64, fixed64         | int64           | -KJ             |
| double                  | double          | -KF             |
| float                   | float           | -KE             |
| bool                    | bool            | -KB             |
| enum                    | int32           | -KI             |
| string, bytes           | string          | -KS             |

**Note**: When parsing from protobuf to kdb, for any field which has not been explicity set in the encoded message, protobuf will return the [default value](https://developers.google.com/protocol-buffers/docs/proto3#default) for that field type which is then populated as usual into the corresponding kdb element.  Similarly when serialising from kdb to protobuf, any kdb element set to its field-specific default value is equivalent to not explicitly setting that field in the encoded message.  It is necessary to 'pad' unspecified message fields with their default value in kdb in order to maintain the one-to-one mapping between any given message field and its corresponding kdb element.

### Repeated Fields

Repeated fields are represented as kdb simple lists depending on the repeated type:

| <u>Repeated Type</u>    | <u>C++ Type</u> | <u>Kdb Type</u> |
| ----------------------- | --------------- | --------------- |
| int32, sint32, sfixed32 | int32           | KI              |
| uint32, fixed32         | int32           | KI              |
| int64, sint64, sfixed64 | int64           | KJ              |
| uint64, fixed64         | int64           | KJ              |
| double                  | double          | KF              |
| float                   | float           | KE              |
| bool                    | bool            | KB              |
| enum                    | int32           | KI              |
| string, bytes           | string          | KS              |

### Map Fields

Map are represented as a kdb dictionary comprised of two lists, the first list type dependent on the map-key type and the second on the map-value type.

Protobuf map keys can only be an integer, bool or string and therefore produce a simple key-list of type: 

| <u>Map-key Type</u>     | <u>C++ Type</u> | <u>Kdb Type</u> |
| ----------------------- | --------------- | --------------- |
| int32, sint32, sfixed32 | int32           | KI              |
| uint32, fixed32         | int32           | KI              |
| int64, sint64, sfixed64 | int64           | KJ              |
| uint64, fixed64         | int64           | KJ              |
| bool                    | bool            | KB              |
| string                  | string          | KS              |

Protobuf map values can be any type other than repeated or map and therefore produce a value-list of type:

| <u>Map-value Type</u>   | <u>C++ Type</u> | <u>Kdb Type</u>               |
| ----------------------- | --------------- | ----------------------------- |
| int32, sint32, sfixed32 | int32           | KI                            |
| uint32, fixed32         | int32           | KI                            |
| int64, sint64, sfixed64 | int64           | KJ                            |
| uint64, fixed64         | int64           | KJ                            |
| double                  | double          | KF                            |
| float                   | float           | KE                            |
| bool                    | bool            | KB                            |
| enum                    | int32           | KI                            |
| string, bytes           | string          | KS                            |
| message                 | [message class] | 0 (mixed list of mixed lists) |

**Note:**  The protobuf wire format and map iteration ordering of map items is undefined, so you cannot rely on a particular dictionary ordering.

### Oneof Fields

Oneof fields are like regular fields except all the fields in a oneof  share memory, and at most one field can be set at the same time. Setting any member of the oneof automatically clears all the other members.

The kdb representation of a oneof field is therefore dependent on whether that field is currently the active member of the oneof:

| <u>Oneof field state</u> | Kdb Representation   |
| ------------------------ | -------------------- |
| Set                      | As per regular field |
| Unset                    | Empty mixed list     |

Oneof fields can only be scalars or sub-messages.

**Note:** When serialising from kdb to protobuf it is possible to specify values for multiple oneof fields.  This is valid usage of oneof and doesn't produce an error, rather the oneof will be set to the value of the last specified field.

### KdbTypeSpecifier field option

To support the use of the kdb temporal types and GUIDs, a field option extension is provided in `src/kdb_type_specifier.proto` (for compiled in message definitions) and `proto/kdb_type_specified.proto` (for dynamically imported message definitions).  This allows kdb+ specific context to be applied to fields, map-keys and map-values:

```protobuf
syntax = "proto2";

import "google/protobuf/descriptor.proto";

enum KdbTypeSpecifier {
    DEFAULT     = 0;
    TIMESTAMP   = 1;
    MONTH       = 2;
    DATE        = 3;
    DATETIME    = 4;
    TIMESPAN    = 5;
    MINUTE      = 6;
    SECOND      = 7;
    TIME        = 8;
    GUID        = 9;

    // Internal use only
    // Must be at the end since it is used to determine the enum size for lookup arrays
    KDBTYPE_LEN = 10;
}

message MapKdbTypeSpecifier {
    optional KdbTypeSpecifier key_type   = 1;
    optional KdbTypeSpecifier value_type = 2;
}

extend google.protobuf.FieldOptions {
    optional KdbTypeSpecifier    kdb_type        = 756866;
    optional MapKdbTypeSpecifier map_kdb_type    = 756867;
}
```

**Note:** For the purpose of compatibility across different versions of protobuf the above has been defined in proto2, this is also equally valid in proto3.

In order to apply a KdbTypeSpecifier to a field you must import `kdb_type_specifier.proto` into your .proto file.   Then specify the KdbTypeSpecifier  field option as follows:

| <u>Field Type</u> | Field option                                       |
| ----------------- | -------------------------------------------------- |
| scalar            | `[(kdb_type) = <KdbTypeSpecifier>]`                |
| repeated          | `[(kdb_type) = <KdbTypeSpecifier>]`                |
| map-key           | `[(map_kdb_type).key_type = <KdbTypeSpecifier>]`   |
| map-value         | `[(map_kdb_type).value_type = <KdbTypeSpecifier>]` |

The map-key and map-value field options may be amalgamated if both require a KdbTypeSpecifier.

For example:

```protobuf
syntax = "proto3";

import "kdb_type_specifier.proto";

message SpecifierExample {
    int32           date        = 1 [(kdb_type) = DATE]; // Scalar
    repeated int32  time        = 2 [(kdb_type) = TIME]; // Repeated
    map<string, int64>  guid_timespan  = 3 [(map_kdb_type).key_type = GUID,         // Map-key
                                            (map_kdb_type).value_type = TIMESPAN];  // Map-value
}
```

Fields with a KdbTypeSpecifier are represented as the Kdb type:

| <u>KdbTypeSpecifier</u> | <u>Kdb Type</u> |
| ----------------------- | --------------- |
| TIMESTAMP               | KP              |
| MONTH                   | KM              |
| DATE                    | KD              |
| DATETIME                | KZ              |
| TIMESPAN                | KN              |
| MINUTE                  | KU              |
| SECOND                  | KV              |
| TIME                    | KT              |
| GUID                    | UU              |

KdbTypeSpecifier=DEFAULT is equivalent to the specifier not being present, i.e. the Kdb type is determined from the proto field type.

**Note:** The KdbTypeSpecifier must be compatible with the defined proto field type. The following outlines the compatible combinations of types:

| <u>KdbTypeSpecifier</u> | <u>Compatible Field Type</u>             |
| ----------------------- | ---------------------------------------- |
| TIMESTAMP               | int64, sint64, sfixed64, uint64, fixed64 |
| MONTH                   | int32, sint32, sfixed32, uint32, fixed32 |
| DATE                    | int32, sint32, sfixed32, uint32, fixed32 |
| DATETIME                | double                                   |
| TIMESPAN                | int64, sint64, sfixed64, uint64, fixed64 |
| MINUTE                  | int32, sint32, sfixed32, uint32, fixed32 |
| SECOND                  | int32, sint32, sfixed32, uint32, fixed32 |
| TIME                    | int32, sint32, sfixed32, uint32, fixed32 |
| GUID                    | string, bytes                            |

### Type Checking

When serialising from kdb to protobuf, the kdb structure must conform to the mappings detailed above with respect to that particular message definition. This is important both in terms of the type of each message field (scalar, repeated, map, etc.) and the proto type specified to represent that field (int32, double, string, etc.)

The interface will type check each field as appropriate and return an error if a mismatch is detected detailing:

- The type of failure
- The message/field where it occurred
- The expected kdb type
- The received kdb type

For example:

```
q).protobufkdb.displayMessageSchema[`ScalarExample]
message ScalarExample {
  int32 scalar_int32 = 1;
  double scalar_double = 2;
  string scalar_string = 3;
}

q)array:.protobufkdb.serializeArray[`ScalarExample;(12i;55f;`str)]

q)array:.protobufkdb.serializeArray[`ScalarExample;(12i;55f;`str;1)]
'Incorrect number of fields, message: 'ScalarExample', expected: 3, received: 4
  [0]  array:.protobufkdb.serializeArray[`ScalarExample;(12i;55f;`str;1)]
             ^

q)array:.protobufkdb.serializeArray[`ScalarExample;(12j;55f;`str)]
'Invalid scalar type, field: 'ScalarExample.scalar_int32', expected: -6, received: -7
  [0]  array:.protobufkdb.serializeArray[`ScalarExample;(12j;55f;`str)]
             ^

q)array:.protobufkdb.serializeArray[`ScalarExample;(enlist 12i;55f;`str)]
'Invalid scalar type, field: 'ScalarExample.scalar_int32', expected: -6, received: 6
  [0]  array:.protobufkdb.serializeArray[`ScalarExample;(enlist 12i;55f;`str)]
             ^

```



## Function Reference

Where a function takes a `message_type` parameter to specify the name of the message to be be processed, the interface first looks for that message type in the compiled in messages.  If that fails it then searches the imported message definitions.  Only if the message type is not found in either is an error returned.

#### .protobufkdb.init

Checks that the version of the library that we linked against is compatible with the version of the headers we compiled against.

Syntax: `.protobufkdb.init[]`

#### .protobufkdb.version

Returns the libprotobuf version as an integer.

Syntax: `.protobufkdb.version[]`

#### .protobufkdb.versionStr

Returns the libprotobuf version as a char array

Syntax: `.protobufkdb.versionStr[]`

#### .protobufkdb.displayMessageSchema

Displays the proto schema of the specified message.

Syntax: `.protobufkdb.displayMessageSchema[message_type]`

Where: 

- `message_type` is a string containing the name of the message type.  Must be the same as the message name in its .proto definition.

**Note:** This function is intended for debugging use only. The schema is generated by the libprotobuf DebugString() functionality and displayed on stdout to preserve the formatting and indentation.

#### .protobufkdb.addProtoImportPath

Adds a path to be searched when dynamically importing `.proto` file definitions.  Can be called more than once to specify multiple import locations.

Syntax: `.protobufkdb.addProtoImportPath[import_path]`

Where:

- `import_path` is a string containing the path to be searched for `.proto` file definitions.  Can be absolute or relative.

#### .protobufkdb.importProtoFile

Dynamically imports a `.proto` file definition into the interface, allowing the messages types defined in that file to be parsed and serialised by the interface.

Syntax: `.protobufkdb.importProtoFile[filename]`

Where:

- `filename` is a string containing the name of the `.proto` file to be imported.  Must not contain any directory specifiers - directory search locations should be setup up beforehand using `.protobufkdb.addProtoImportPath`

returns an error containing information on the errors and warnings which occurred if the file fails to parse.

#### .protobufkdb.listImportedMessageTypes

Returns a list of the message types which have been successfully imported.

Syntax: `.protobufkdb.listImportedMessageTypes[]`

returns symbol list of the successfully imported message types.

**Note:** The list does not contain message types which have been compiled into the interface.

#### .protobufkdb.saveMessage

Convert a kdb object to a protobuf message, serializes it, then write the result to the specified file.

Syntax: `.protobufkdb.saveMessage[message_type; file_name; msg_in]`

Where:

- `message_type` is a string containing the name of the message type.  Must be the same as the message name in its .proto definition.
- `file_name` is a string containing the name of the file to write to.
- `msg_in` is the kdb object to be converted.

#### .protobufkdb.loadMessage

Parse a proto-serialized stream from a specified file to a protobuf message then converts this into a corresponding kdb object.

Syntax: `.protobufkdb.loadMessage[message_type; file_name]`

Where:

- `message_type` is a string containing the name of the message type.  Must be the same as the message name in its .proto definition.
- `file_name` is a string containing the name of the file to read from.

returns a kdb object corresponding to the protobuf message.

#### .protobufkdb.serializeArray

Convert a kdb object to a protobuf message and serialize this into a char array.

Syntax: `.protobufkdb.serializeArray[message_type; msg_in]`

Where:

- `message_type` is a string containing the name of the message type.  Must be the same as the message name in its .proto definition.
- `msg_in` is the kdb object to be converted.

returns Kdb char array containing the serialized message.

#### .protobufkdb.parseArray

Parse a proto-serialized char array into a protobuf message, then converts that into a corresponding kdb object.

Syntax: `.protobufkdb.parseArray[message_type; char_array]`

Where:

- `message_type` is a string containing the name of the message type.  Must be the same as the message name in its .proto definition.
- `char_array` is a kdb char array containing the serialized protobuf message.

returns Kdb object corresponding to the protobuf message.

#### .protobufkdb.serializeArrayArena

Identical to `.protobufkdb.serializeArray[]` except the intermediate protobuf message is created on a google arena (can help improves memory allocation performance for large messages with deep repeated/map fields - see [here](https://developers.google.com/protocol-buffers/docs/reference/arenas)).

#### .protobufkdb.parseArrayArena

Identical to `.protobufkdb.parseArray[]` except the intermediate protobuf message is created on a google arena (can help improves memory allocation performance for large messages with deep repeated fields/map - see [here](https://developers.google.com/protocol-buffers/docs/reference/arenas)).



## Examples

### Compiled in messages

`src/examples.proto` provides sample message definitions which help to illustrate the different protobuf field types and the mappings each uses when converting to and from kdb: `ScalarExample`, `RepeatedExample`, `SubMessageExample`, `MapExample`, `SpecifierExample` and `OneofExample`.

Starting with `ScalarExample`, create a kdb mixed list which conforms to the message definition:

```
q).protobufkdb.displayMessageSchema[`ScalarExample]
message ScalarExample {
  int32 scalar_int32 = 1;
  double scalar_double = 2;
  string scalar_string = 3;
}

q)a:(12i;55f;`str)
```

Serialise the kdb structure to a protobuf encoded char array:

```
q)array:.protobufkdb.serializeArray[`ScalarExample;a]

q)array
"\010\014\021\000\000\000\000\000\200K@\032\003str"
```

Parse the char array back to kdb and check the result is the same as the original mixed list:

```
q)b:.protobufkdb.parseArray[`ScalarExample;array]

q)a~b
1b
```

Modify the structure of the kdb list to make it non-conformant in order to observe potential type checking errors:

```
q)array:.protobufkdb.serializeArray[`ScalarExample;(12i;55f;`str;1)]
'Incorrect number of fields, message: 'ScalarExample', expected: 3, received: 4
  [0]  array:.protobufkdb.serializeArray[`ScalarExample;(12i;55f;`str;1)]
             ^

q)array:.protobufkdb.serializeArray[`ScalarExample;(12j;55f;`str)]
'Invalid scalar type, field: 'ScalarExample.scalar_int32', expected: -6, received: -7
  [0]  array:.protobufkdb.serializeArray[`ScalarExample;(12j;55f;`str)]
             ^

q)array:.protobufkdb.serializeArray[`ScalarExample;(enlist 12i;55f;`str)]
'Invalid scalar type, field: 'ScalarExample.scalar_int32', expected: -6, received: 6
  [0]  array:.protobufkdb.serializeArray[`ScalarExample;(enlist 12i;55f;`str)]
             ^
```

This example and similar ones for the other message definitions in `src/examples.proto` can be found in `examples/examples.q`

More exhaustive examples can be found in `src/tests.proto` and `examples/runtests.q`

### Dynamically imported messages

Equivalent to the compiled in message examples, `proto/examples_dynamic.proto` provides sample message definitions which help to illustrate the different protobuf field types and the mappings each uses when converting to and from kdb: `ScalarExampleDynamic`, `RepeatedExampleDynamic`, `SubMessageExampleDynamic`, `MapExampleDynamic`, `SpecifierExampleDynamic` and `OneofExampleDynamic`.

First the directory containing `examples_dynamic.proto`  must be specified as an import seach path.  So if the q session is started in the `examples` subdirectory then the path to the `proto` subdirectory is specified as:

```
q).protobufkdb.addProtoImportPath["../proto"]
```

Note that `examples_dynamic.proto` imports `kdb_type_specifier.proto` but that is also present in the `proto` subdirectory so no further import locations are required.  However, if the required `.proto` files are spread across different locations then multiple import paths can be specified.

The message definitions contained in `examples_dynamic.proto` are imported into the interface:

```
q).protobufkdb.importProtoFile["examples_dynamic.proto"]
```

The examples then proceed as per the compiled in messages (using the corresponding dynamic message type names):

```
q).protobufkdb.displayMessageSchema[`ScalarExampleDynamic]
message ScalarExampleDynamic {
  int32 scalar_int32 = 1;
  double scalar_double = 2;
  string scalar_string = 3;
}

```

This example and similar ones for the other message definitions in `proto/examples_dynamic.proto` can be found in `examples/examples_dynamic.q`

More exhaustive examples can be found in `proto/tests_dynamic.proto` and `examples/runtests_dynamic.q`



## Status

The protobufkdb interface is provided here under an Apache 2.0 license.

Protocol Buffers is used under the terms of [Google's license](https://github.com/protocolbuffers/protobuf/blob/master/LICENSE).

If you find issues with the interface or have feature requests, please consider raising an issue [here](https://github.com/KxSystems/protobufkdb/issues).

If you wish to contribute to this project, please follow the contributing guide [here](CONTRIBUTING.md).
