\l ../q/protobufkdb.q

// Import dynamic tests
.protobufkdb.addProtoImportPath["../proto"]
.protobufkdb.importProtoFile["tests_dynamic.proto"]

// Test scalars with file
scalars:(1i;2i;3j;4j;5f;6e;1b;2i;`string)
.protobufkdb.saveMessage[`ScalarTestDynamic;`scalar_file;scalars]
a:.protobufkdb.loadMessage[`ScalarTestDynamic;`scalar_file]
a~scalars

// Test scalars with array
array:.protobufkdb.serializeArray[`ScalarTestDynamic;scalars]
b:.protobufkdb.parseArray[`ScalarTestDynamic;array]
b~scalars

// Test repeated with file
repeated:scalars,'scalars
.protobufkdb.saveMessage[`RepeatedTestDynamic;`repeated_file;repeated]
c:.protobufkdb.loadMessage[`RepeatedTestDynamic;`repeated_file]
c~repeated

// Test repeated with array
array:.protobufkdb.serializeArray[`RepeatedTestDynamic;repeated]
d:.protobufkdb.parseArray[`RepeatedTestDynamic;array]
d~repeated

// Test submessage with file
submessage:(scalars;enlist repeated)
.protobufkdb.saveMessage[`SubMessageTestDynamic;`submessage_file;submessage]
e:.protobufkdb.loadMessage[`SubMessageTestDynamic;`submessage_file]
e~submessage

// Test submessage with array
array:.protobufkdb.serializeArray[`SubMessageTestDynamic;submessage]
f:.protobufkdb.parseArray[`SubMessageTestDynamic;array]
f~submessage

// Test map with file
// Protobuf maps are unordered and unsorted so use single item lists for each dictionary 
// element to perform a simple equality check.
map:((enlist 1i)!(enlist 2j);(enlist 3i)!(enlist 4j);(enlist 5j)!(enlist 6f);(enlist 7j)!(enlist 8e);(enlist 0b)!(enlist 1i);(enlist `one)!(enlist scalars);(enlist `three)!(enlist submessage))
//map:(1 2i!3 4j;5 6i!7 8j;1 2j!3 4f;5 6j!7 8e;01b!2 1i;(`one,`two)!(scalars;scalars);(`three,`four)!(submessage;submessage))
.protobufkdb.saveMessage[`MapTestDynamic;`map_file;map]
g:.protobufkdb.loadMessage[`MapTestDynamic;`map_file]
g~map

// Test map with array
array:.protobufkdb.serializeArray[`MapTestDynamic;map]
h:.protobufkdb.parseArray[`MapTestDynamic;array]
h~map

// Test scalar specifiers with file
scalar_specifiers:(2020.01.01D12:34:56.123456789;2020.01m;2020.01.01;2020.01.01T12:34:56.123;12:34:56.123456789;12:34;12:34:56;12:34:56.123;(1?0Ng)0)
.protobufkdb.saveMessage[`ScalarSpecifiersTestDynamic;`scalar_specifiers_file;scalar_specifiers]
i:.protobufkdb.loadMessage[`ScalarSpecifiersTestDynamic;`scalar_specifiers_file]
i~scalar_specifiers

// Test scalar specifiers with array
array:.protobufkdb.serializeArray[`ScalarSpecifiersTestDynamic;scalar_specifiers]
j:.protobufkdb.parseArray[`ScalarSpecifiersTestDynamic;array]
j~scalar_specifiers

// Test repeated specifiers with file
repeated_specifiers:scalar_specifiers,'scalar_specifiers
.protobufkdb.saveMessage[`RepeatedSpecifiersTestDynamic;`repeated_specifiers_file;repeated_specifiers]
k:.protobufkdb.loadMessage[`RepeatedSpecifiersTestDynamic;`repeated_specifiers_file]
k~repeated_specifiers

// Test repeated specifiers with array
array:.protobufkdb.serializeArray[`RepeatedSpecifiersTestDynamic;repeated_specifiers]
l:.protobufkdb.parseArray[`RepeatedSpecifiersTestDynamic;array]
l~repeated_specifiers

// Test map specifiers with file
map_specifiers:((enlist 2020.01.01D12:34:56.123456789)!(enlist 2020.01m);(enlist 2020.01.01)!(enlist 2020.01.01T12:34:56.123);(enlist 12:34:56.123456789)!(enlist 12:34);(enlist 12:34:56)!(enlist 12:34:56.123);(1?0Ng)!(1?0Ng))
.protobufkdb.saveMessage[`MapSpecifiersTestDynamic;`map_specifiers_file;map_specifiers]
m:.protobufkdb.loadMessage[`MapSpecifiersTestDynamic;`map_specifiers_file]
m~map_specifiers

// Test scalar specifiers with array
array:.protobufkdb.serializeArray[`MapSpecifiersTestDynamic;map_specifiers]
n:.protobufkdb.parseArray[`MapSpecifiersTestDynamic;array]
n~map_specifiers

// Test oneof permutations
oneof1:(1.1f;();();`str)
oneof2:(();12:34:56;();`str)
oneof3:(();();(1j; 2.1 2.2f);`str)
oneofnone:(();();();`str)
oneof1~.protobufkdb.parseArray[`OneofTestDynamic;.protobufkdb.serializeArray[`OneofTestDynamic;oneof1]]
oneof2~.protobufkdb.parseArray[`OneofTestDynamic;.protobufkdb.serializeArray[`OneofTestDynamic;oneof2]]
oneof3~.protobufkdb.parseArray[`OneofTestDynamic;.protobufkdb.serializeArray[`OneofTestDynamic;oneof3]]
oneofnone~.protobufkdb.parseArray[`OneofTestDynamic;.protobufkdb.serializeArray[`OneofTestDynamic;oneofnone]]
// If mulitple oneofs are set, only the last is populated
oneofall:(1.1f;12:34:56;(1j; 2.1 2.2f);`str)
oneof3~.protobufkdb.parseArray[`OneofTestDynamic;.protobufkdb.serializeArray[`OneofTestDynamic;oneofall]]
