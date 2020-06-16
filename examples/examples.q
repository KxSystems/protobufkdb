\l ../q/protobufkdb.q

// Scalar example
.protobufkdb.displayMessageSchema[`ScalarExample]
a:(12i;55f;`str)
array:.protobufkdb.serializeArray[`ScalarExample;a]
array
b:.protobufkdb.parseArray[`ScalarExample;array]
a~b
array:.protobufkdb.serializeArray[`ScalarExample;(12i;55f;`str)]

// Repeated example
.protobufkdb.displayMessageSchema[`RepeatedExample]
c:(1 2i;10 20f;`s1`s2)
array:.protobufkdb.serializeArray[`RepeatedExample;c]
array
d:.protobufkdb.parseArray[`RepeatedExample;array]
array:.protobufkdb.serializeArray[`RepeatedExample;(1 2i;10 20f;`s1`s2)]

// Sub-message example
.protobufkdb.displayMessageSchema[`SubMessageExample]
e:(a;(c;c))
array:.protobufkdb.serializeArray[`SubMessageExample;e]
array
f:.protobufkdb.parseArray[`SubMessageExample;array]
e~f
array:.protobufkdb.serializeArray[`SubMessageExample;(a;(c;c))]

// Map example
.protobufkdb.displayMessageSchema[`SubMessageExample]
g:(1 2j!3 4f;`s1`s2!(a;a))
array:.protobufkdb.serializeArray[`MapExample;g]
array
h:.protobufkdb.parseArray[`MapExample;array]
// Ordering of protobuf maps is undefined so compare using key lookups
(count g)~(count h)
g[0][1]~h[0][1]
g[0][2]~h[0][2]
g[1][`s1]~h[1][`s1]
g[1][`s2]~h[1][`s2]
array:.protobufkdb.serializeArray[`MapExample;(1 2j!3 4f;`s1`s2!(a;a))]

// Specifier example
.protobufkdb.displayMessageSchema[`SpecifierExample]
i:(2020.01.01;enlist 12:34:56.123;(1?0Ng)!(enlist 12:34:56.123456789))
array:.protobufkdb.serializeArray[`SpecifierExample;i]
array
j:.protobufkdb.parseArray[`SpecifierExample;array]
i~j
.protobufkdb.parseArray[`SpecifierExample;.protobufkdb.serializeArray[`SpecifierExample;(2020.01.01;enlist 12:34:56.123;(1?0Ng)!(enlist 12:34:56.123456789))]]

// Oneof example
.protobufkdb.displayMessageSchema[`OneofExample]
k:(1.1f;();`str)
array:.protobufkdb.serializeArray[`OneofExample;k]
array
l:.protobufkdb.parseArray[`OneofExample;array]
k~l
.protobufkdb.parseArray[`OneofExample;.protobufkdb.serializeArray[`OneofExample;(1.1f;();`str)]]
.protobufkdb.parseArray[`OneofExample;.protobufkdb.serializeArray[`OneofExample;(();12:34:56;`str)]]
