\l ../q/protobufkdb.q

// Import dynamic tests
.protobufkdb.addProtoImportPath["../proto"]
.protobufkdb.importProtoFile["examples_dynamic.proto"]

// Scalar example
.protobufkdb.displayMessageSchema[`ScalarExampleDynamic]
a:(12i;55f;`str)
array:.protobufkdb.serializeArray[`ScalarExampleDynamic;a]
array
b:.protobufkdb.parseArray[`ScalarExampleDynamic;array]
a~b
array:.protobufkdb.serializeArray[`ScalarExampleDynamic;(12i;55f;`str)]

// Repeated example
.protobufkdb.displayMessageSchema[`RepeatedExampleDynamic]
c:(1 2i;10 20f;`s1`s2)
array:.protobufkdb.serializeArray[`RepeatedExampleDynamic;c]
array
d:.protobufkdb.parseArray[`RepeatedExampleDynamic;array]
array:.protobufkdb.serializeArray[`RepeatedExampleDynamic;(1 2i;10 20f;`s1`s2)]

// Sub-message example
.protobufkdb.displayMessageSchema[`SubMessageExampleDynamic]
e:(a;(c;c))
array:.protobufkdb.serializeArray[`SubMessageExampleDynamic;e]
array
f:.protobufkdb.parseArray[`SubMessageExampleDynamic;array]
e~f
array:.protobufkdb.serializeArray[`SubMessageExampleDynamic;(a;(c;c))]

// Map example
.protobufkdb.displayMessageSchema[`SubMessageExampleDynamic]
g:(1 2j!3 4f;`s1`s2!(a;a))
array:.protobufkdb.serializeArray[`MapExampleDynamic;g]
array
h:.protobufkdb.parseArray[`MapExampleDynamic;array]
// Ordering of protobuf maps is undefined so compare using key lookups
(count g)~(count h)
g[0][1]~h[0][1]
g[0][2]~h[0][2]
g[1][`s1]~h[1][`s1]
g[1][`s2]~h[1][`s2]
array:.protobufkdb.serializeArray[`MapExampleDynamic;(1 2j!3 4f;`s1`s2!(a;a))]

// Specifier example
.protobufkdb.displayMessageSchema[`SpecifierExampleDynamic]
i:(2020.01.01;enlist 12:34:56.123;(1?0Ng)!(enlist 12:34:56.123456789))
array:.protobufkdb.serializeArray[`SpecifierExampleDynamic;i]
array
j:.protobufkdb.parseArray[`SpecifierExampleDynamic;array]
i~j
.protobufkdb.parseArray[`SpecifierExampleDynamic;.protobufkdb.serializeArray[`SpecifierExampleDynamic;(2020.01.01;enlist 12:34:56.123;(1?0Ng)!(enlist 12:34:56.123456789))]]

// Oneof example
.protobufkdb.displayMessageSchema[`OneofExampleDynamic]
k:(1.1f;();`str)
array:.protobufkdb.serializeArray[`OneofExampleDynamic;k]
array
l:.protobufkdb.parseArray[`OneofExampleDynamic;array]
k~l
.protobufkdb.parseArray[`OneofExampleDynamic;.protobufkdb.serializeArray[`OneofExampleDynamic;(1.1f;();`str)]]
.protobufkdb.parseArray[`OneofExampleDynamic;.protobufkdb.serializeArray[`OneofExampleDynamic;(();12:34:56;`str)]]
