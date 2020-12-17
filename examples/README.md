# Examples

Each script contained within this folder deals with a different aspect of the interface and aims to showcases a particular section of the protobufkdb library. The use cases highlighted below are:

1. Messages added to a session at compile time
2. Messages dynamically loaded into the session

More basic example workflows are highlighted in the documentation for this interface [here](https://code.kx.com/q/interfaces/protobuf/examples).

## Compiled in messages

`src/examples.proto` provides sample message definitions which help to illustrate the different protobuf field types and the mappings each uses when converting to and from kdb: `ScalarExample`, `RepeatedExample`, `SubMessageExample`, `MapExample`, `SpecifierExample` and `OneofExample`.

The following example is taken from the first section in `examples/scalar.q`:

```q
q).protobufkdb.displayMessageSchema[`ScalarExample]
message ScalarExample {
  int32 scalar_int32 = 1;
  double scalar_double = 2;
  string scalar_string = 3;
}

q)scalars:(12i;55f;"str")

// Serialize the kdb structure to a protobuf encoded char array:
q)serialized:.protobufkdb.serializeArrayFromList[`ScalarExample;scalars]

q)serialized
"\010\014\021\000\000\000\000\000\200K@\032\003str"

// Parse the char array back to kdb and check the result is the same as the original mixed list
q)deserialized:.protobufkdb.parseArrayToList[`ScalarExample;serialized]

q)scalars~deserialized
1b
```

Modify the structure of the kdb+ list to make it non-conformant in order to observe potential type checking errors:

```q
q).protobufkdb.serializeArrayFromList[`ScalarExample;(12i;55f)]
'Incorrect number of fields, message: 'ScalarExample', expected: 3, received: 2
  [0]  array:.protobufkdb.serializeArray[`ScalarExample;(12i;55f)]
             ^

q).protobufkdb.serializeArray[`ScalarExample;(12j;55f;"str")]
'Invalid scalar type, field: 'ScalarExample.scalar_int32', expected: -6, received: -7
```

## Dynamically imported messages

Equivalent to the compiled in message examples, `proto/examples_dynamic.proto` provides sample message definitions which help to illustrate the different protobuf field types and the mappings each uses when converting to and from kdb: `ScalarExampleDynamic`, `RepeatedExampleDynamic`, `SubMessageExampleDynamic`, `MapExampleDynamic`, `SpecifierExampleDynamic` and `OneofExampleDynamic`.

The following example is taken from the second section of `examples/scalar.q` and outlines the retrieval of a schema from a `.proto` file based specified on a specified import search path. So if the q session is started in the `examples` subdirectory then the path to the `proto` subdirectory is specified as follows:

```q
q).protobufkdb.addProtoImportPath["../proto"]
```

**Note:** `examples_dynamic.proto` imports `kdb_type_specifier.proto` as this is also present in the `proto` subdirectory as such no further import locations must be defined.  However, if the required `.proto` files are spread across different locations on the OS then multiple import paths can be specified.

Import the message definitions contained in `examples_dynamic.proto` into the q session:

```q
q).protobufkdb.importProtoFile["examples_dynamic.proto"]
```

The examples then proceed as per the compiled in messages (using the corresponding dynamic message type names):

```q
q).protobufkdb.displayMessageSchema[`ScalarExampleDynamic]
message ScalarExampleDynamic {
  int32 scalar_int32 = 1;
  double scalar_double = 2;
  string scalar_string = 3;
}

```
