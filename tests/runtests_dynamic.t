\l q/protobufkdb.q

\d .protobufkdb

-1 "Import dynamic tests";
addProtoImportPath["proto"]
importProtoFile["tests_dynamic.proto"]

-1 "Test scalars with file";
scalars:(1i;2i;3j;4j;5f;6e;1b;2i;`string)
saveMessage[`ScalarTestDynamic;`scalar_file;scalars]
a:loadMessage[`ScalarTestDynamic;`scalar_file]
a~scalars

-1 "Test scalars with array";
array:serializeArray[`ScalarTestDynamic;scalars]
b:parseArray[`ScalarTestDynamic;array]
b~scalars

-1 "Test repeated with file";
repeated:scalars,'scalars
saveMessage[`RepeatedTestDynamic;`repeated_file;repeated]
c:loadMessage[`RepeatedTestDynamic;`repeated_file]
c~repeated

-1 "Test repeated with array";
array:serializeArray[`RepeatedTestDynamic;repeated]
d:parseArray[`RepeatedTestDynamic;array]
d~repeated

-1 "Test submessage with file";
submessage:(scalars;enlist repeated)
saveMessage[`SubMessageTestDynamic;`submessage_file;submessage]
e:loadMessage[`SubMessageTestDynamic;`submessage_file]
e~submessage

-1 "Test submessage with array";
array:serializeArray[`SubMessageTestDynamic;submessage]
f:parseArray[`SubMessageTestDynamic;array]
f~submessage

-1 "Test map with file";
// Protobuf maps are unordered and unsorted so use single item lists for each dictionary 
// element to perform a simple equality check.
map:((enlist 1i)!(enlist 2j);(enlist 3i)!(enlist 4j);(enlist 5j)!(enlist 6f);(enlist 7j)!(enlist 8e);(enlist 0b)!(enlist 1i);(enlist `one)!(enlist scalars);(enlist `three)!(enlist submessage))
//map:(1 2i!3 4j;5 6i!7 8j;1 2j!3 4f;5 6j!7 8e;01b!2 1i;(`one,`two)!(scalars;scalars);(`three,`four)!(submessage;submessage))
saveMessage[`MapTestDynamic;`map_file;map]
g:loadMessage[`MapTestDynamic;`map_file]
g~map

-1 "Test map with array";
array:serializeArray[`MapTestDynamic;map]
h:parseArray[`MapTestDynamic;array]
h~map

-1 "Test scalar specifiers with file";
scalar_specifiers:(2020.01.01D12:34:56.123456789;2020.01m;2020.01.01;2020.01.01T12:34:56.123;12:34:56.123456789;12:34;12:34:56;12:34:56.123;(1?0Ng)0)
saveMessage[`ScalarSpecifiersTestDynamic;`scalar_specifiers_file;scalar_specifiers]
i:loadMessage[`ScalarSpecifiersTestDynamic;`scalar_specifiers_file]
i~scalar_specifiers

-1 "Test scalar specifiers with array";
array:serializeArray[`ScalarSpecifiersTestDynamic;scalar_specifiers]
j:parseArray[`ScalarSpecifiersTestDynamic;array]
j~scalar_specifiers

-1 "Test repeated specifiers with file";
repeated_specifiers:scalar_specifiers,'scalar_specifiers
saveMessage[`RepeatedSpecifiersTestDynamic;`repeated_specifiers_file;repeated_specifiers]
k:loadMessage[`RepeatedSpecifiersTestDynamic;`repeated_specifiers_file]
k~repeated_specifiers

-1 "Test repeated specifiers with array";
array:serializeArray[`RepeatedSpecifiersTestDynamic;repeated_specifiers]
l:parseArray[`RepeatedSpecifiersTestDynamic;array]
l~repeated_specifiers

-1 "Test map specifiers with file";
map_specifiers:((enlist 2020.01.01D12:34:56.123456789)!(enlist 2020.01m);(enlist 2020.01.01)!(enlist 2020.01.01T12:34:56.123);(enlist 12:34:56.123456789)!(enlist 12:34);(enlist 12:34:56)!(enlist 12:34:56.123);(1?0Ng)!(1?0Ng))
saveMessage[`MapSpecifiersTestDynamic;`map_specifiers_file;map_specifiers]
m:loadMessage[`MapSpecifiersTestDynamic;`map_specifiers_file]
m~map_specifiers

-1 "Test scalar specifiers with array";
array:serializeArray[`MapSpecifiersTestDynamic;map_specifiers]
n:parseArray[`MapSpecifiersTestDynamic;array]
n~map_specifiers

-1 "Test oneof permutations";
oneof1:(1.1f;();();`str)
oneof2:(();12:34:56;();`str)
oneof3:(();();(1j; 2.1 2.2f);`str)
oneofnone:(();();();`str)
oneof1~parseArray[`OneofTestDynamic;serializeArray[`OneofTestDynamic;oneof1]]
oneof2~parseArray[`OneofTestDynamic;serializeArray[`OneofTestDynamic;oneof2]]
oneof3~parseArray[`OneofTestDynamic;serializeArray[`OneofTestDynamic;oneof3]]
oneofnone~parseArray[`OneofTestDynamic;serializeArray[`OneofTestDynamic;oneofnone]]
// If mulitple oneofs are set, only the last is populated
oneofall:(1.1f;12:34:56;(1j; 2.1 2.2f);`str)
oneof3~parseArray[`OneofTestDynamic;serializeArray[`OneofTestDynamic;oneofall]]
