\l q/protobufkdb.q

\d .protobufkdb

-1! "Test scalars with file";
scalars:(1i;2i;3j;4j;5f;6e;1b;2i;`string)
saveMessage[`ScalarTest;`scalar_file;scalars]
a:loadMessage[`ScalarTest;`scalar_file]
a~scalars

-1 "Test scalars with array";
array:serializeArray[`ScalarTest;scalars]
b:parseArray[`ScalarTest;array]
b~scalars

-1! "Test repeated with file";
repeated:scalars,'scalars
saveMessage[`RepeatedTest;`repeated_file;repeated]
c:loadMessage[`RepeatedTest;`repeated_file]
c~repeated

-1 "Test repeated with array";
array:serializeArray[`RepeatedTest;repeated]
d:parseArray[`RepeatedTest;array]
d~repeated

-1 "Test submessage with file";
submessage:(scalars;enlist repeated)
saveMessage[`SubMessageTest;`submessage_file;submessage];
e:loadMessage[`SubMessageTest;`submessage_file]
e~submessage

-1 "Test submessage with array";
array:serializeArray[`SubMessageTest;submessage]
f:parseArray[`SubMessageTest;array]
f~submessage

-1 "Test map with file";
// Protobuf maps are unordered and unsorted so use single item lists for each dictionary 
// element to perform a simple equality check.
map:((enlist 1i)!(enlist 2j);(enlist 3i)!(enlist 4j);(enlist 5j)!(enlist 6f);(enlist 7j)!(enlist 8e);(enlist 0b)!(enlist 1i);(enlist `one)!(enlist scalars);(enlist `three)!(enlist submessage))
//map:(1 2i!3 4j;5 6i!7 8j;1 2j!3 4f;5 6j!7 8e;01b!2 1i;(`one,`two)!(scalars;scalars);(`three,`four)!(submessage;submessage))
saveMessage[`MapTest;`map_file;map]
g:loadMessage[`MapTest;`map_file]
g~map

-1 "Test map with array";
array:serializeArray[`MapTest;map]
h:parseArray[`MapTest;array]
h~map

-1 "Test scalar specifiers with file";
scalar_specifiers:(2020.01.01D12:34:56.123456789;2020.01m;2020.01.01;2020.01.01T12:34:56.123;12:34:56.123456789;12:34;12:34:56;12:34:56.123;(1?0Ng)0)
saveMessage[`ScalarSpecifiersTest;`scalar_specifiers_file;scalar_specifiers]
i:loadMessage[`ScalarSpecifiersTest;`scalar_specifiers_file]
i~scalar_specifiers

-1 "Test scalar specifiers with array";
array:serializeArray[`ScalarSpecifiersTest;scalar_specifiers]
j:parseArray[`ScalarSpecifiersTest;array]
j~scalar_specifiers

-1 "Test repeated specifiers with file";
repeated_specifiers:scalar_specifiers,'scalar_specifiers
saveMessage[`RepeatedSpecifiersTest;`repeated_specifiers_file;repeated_specifiers]
k:loadMessage[`RepeatedSpecifiersTest;`repeated_specifiers_file]
k~repeated_specifiers

-1 "Test repeated specifiers with array";
array:serializeArray[`RepeatedSpecifiersTest;repeated_specifiers]
l:parseArray[`RepeatedSpecifiersTest;array]
l~repeated_specifiers

-1 "Test map specifiers with file";
map_specifiers:((enlist 2020.01.01D12:34:56.123456789)!(enlist 2020.01m);(enlist 2020.01.01)!(enlist 2020.01.01T12:34:56.123);(enlist 12:34:56.123456789)!(enlist 12:34);(enlist 12:34:56)!(enlist 12:34:56.123);(1?0Ng)!(1?0Ng))
saveMessage[`MapSpecifiersTest;`map_specifiers_file;map_specifiers]
m:loadMessage[`MapSpecifiersTest;`map_specifiers_file]
m~map_specifiers

-1 "Test map specifiers with array";
array:serializeArray[`MapSpecifiersTest;map_specifiers]
n:parseArray[`MapSpecifiersTest;array]
n~map_specifiers

-1! "Test oneof permutations";
oneof1:(1.1f;();();`str)
oneof2:(();12:34:56;();`str)
oneof3:(();();(1j; 2.1 2.2f);`str)
oneofnone:(();();();`str)
oneof1~parseArray[`OneofTest;serializeArray[`OneofTest;oneof1]]
oneof2~parseArray[`OneofTest;serializeArray[`OneofTest;oneof2]]
oneof3~parseArray[`OneofTest;serializeArray[`OneofTest;oneof3]]
oneofnone~parseArray[`OneofTest;serializeArray[`OneofTest;oneofnone]]
// If mulitple oneofs are set, only the last is populated
oneofall:(1.1f;12:34:56;(1j; 2.1 2.2f);`str)
oneof3~parseArray[`OneofTest;serializeArray[`OneofTest;oneofall]]