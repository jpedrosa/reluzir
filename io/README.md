IO
=====

The IO library is devoted to bringing some ease of use to Dart IO. It borrows ideas from Ruby, starting with a Glob pattern matching for browsing files and directories.

File
----

The default File class of Dart just maps to some fairly atomic and easy-to-use methods to both read and write stuff in one single call. With this new File class we turn it into the RandomAccessFile for the sync APIs, but also inspired by Ruby with some new additions as shown in the following sample:

```dart
import "../../lang/lib/lang.dart";
import "../lib/io.dart";
import "../lib/file.dart";


main() {
  var af, fruits = ["Banana\n", "Grapes\n", "Watermelon"];
//File.open("c:/t_/d2.txt", "w") {|f| f.puts fruits } Ruby version
  af = File.open("fruits_sample.txt", "w", (f) => f.puts(fruits));
  /*af = File.open("fruits_sample.txt", "a", (f) { // "a" mode for appending.
    f << "Banana\n" << "Grapes\n" << "Watermelon\n";
  });
  af = File.open("fruits_sample.txt", "w", (f) {
    f << "Banana\n" << "Grapes\n" << "Watermelon\n";
  });*/
  p("File path: ${af.path}");
  var a = IO.readLines("fruits_sample.txt"), e;
  p(a.length);
  for (e in a) {
    p(e);
  }
  a = IO.readLines("stored_fruits_sample.txt");
  p(a.length);
  for (e in a) {
    p(e);
  }
}
```

Like in Ruby, File.open takes a block. When the block is provided via a function parameter, the block is called and the file is closed soon thereafter.

The static methods of Dart's File class, their sync versions, can be used from the IO class instead. In Ruby class and instance can have same name methods. In Dart that's not possible because in Dart there's a conflict in that case. So File takes some names that are used by the instance and IO takes names that are used like the static ones.

----------

By the way, given that in Dart we have Async and Sync IO, and depending on the use case we could prefer one to the other, I haven't settled on my choices of IO APIs quite yet.

IO
--

The IO class is also inspired by Ruby's own IO class. Fortunately in Dart there are already some easy-to-use File methods to read string and lines. With the IO class they just are sync by default and are more succinct. As shown in this sample:

```dart
import "../../lang/lib/lang.dart";
import "../lib/io.dart";


main() {
  var a = IO.readLines("fruits_sample.txt"), e;
  p(a.length);
  for (e in a) {
    p(e);
  }
  p(IO.read("fruits_sample.txt"));
}
```

Glob
----

It has a lexer, a parser and a supporting pattern matching library called CodeUnitMatcher that has been placed in the CodeUnitStream library.

It supports these Glob features:

* \* for matching many. E.g. "t\*"
* ? for matching one character. E.g. "file.?"
* [a-z] and [^0-9] for character sets similar to Regex. E.g. "[a-z][0-9]\*"
* {one,two,so\_on} for alternative names.
* Case insensitive searches on Windows by default.
* Skips files and directories starting with a dot (".") by default.
* Comprehensive recursive searching which can help to filter directories before trying to match files. E.g. "c:/r\*/s\*/\*\*/t\*/\*\*/r\*/\*.dart"
* Errors or exceptions can lead to returning just the base directory instead.

Patterns are strings and the path separator used in the pattern is a slash. Backslashes are used for escaping purposes, even though I have yet to implement escaping of meta-characters as escaping is not used a lot to begin with. :-)

-----------

To recurse subdirectories use the "/\*\*/" pattern inserted at the appropriate directory level. I.e. the two stars need to be placed between path separators, otherwise for now they would be interpreted as a single star for matching at just the directory level.

-----------

The Glob features are present in the Dir methods Dir["\*"] or Dir.glob("\*"). Dir["\*"] is similar to Ruby. Dir.glob takes parameters to set the case sensitivity and the choice whether to skip leading dot files or not.

The leading dot files are a standard of Unix for files that should be ignored or that should be hidden by default, many of which carry configuration data. So skipping them by default is quite OK.

-----------

Glob is a feature of shells that has been adopted by many scripting languages.

-----------

Sample:

```dart
import "../../lang/lib/lang.dart";
import "../lib/dir.dart";

genSample1() => "**/*.dart";

genSample10() => "c:/t_/*";

genSample20() => "c:/t_/**/";

genSample30() => "c:/t_/**/*.dart";

genSample40() => "c:/t_/**/*dm";

genSample50() => "c:/t_/**/web";

genSample60() => "c:/t_/**/*dm*";

genSample70() => "c:/t_/ruby-1.9.3-rc1/**/*.rb";

genSample80() => "c:/t_/ruby-1.9.3-rc1/**/tool*";

genSample90() => "c:/t_/ruby-1.9.3-rc1/**/*.?";

genSample100() => "c:/t_/ruby-1.9.3-rc1/**/?????";

genSample110() => "c:/t_/r*";

genSample120() => "c:/t_/r*/r*";

genSample130() => "c:/t_/r*/r*/**/";

genSample140() => "c:/t_/r*/r*/**/r*";

genSample150() => "c:/t_/r*/r*/**/r*/r*";

genSample160() => "c:/t_/**/*.rb";

genSample170() => "c:/t_/r*/r*/**/s*/r*";

genSample180() => "c:/t_/r*/r*/**/s*/**/r*";

genSample190() => "c:/t_/**/r*/s*/**/r*";

genSample200() => "c:/t_/**/r*/**/s*/**/r*";

genSample210() => "c:/t_/**/*.{dart,html}";

genSample220() => "c:/t_/**/*_{en,ja}*";

genSample230() => "c:/t_/**/*.[ch]";

genSample240() => "c:/t_/**/*.{c,h}";

genSample250() => "c:/t_/**/*.[a-z]";

genSample260() => "c:/t_/**/*.[0-9]";

genSample270() => "c:/t_/**/*.[^0-9]";

genSample280() => "c:/t_/**/*.[^a-z]";

genSample290() => "c:/t_/**/*[0-9]";

genSample300() => "c:/t_/**/image*[0-9]";

genSample310() => "c:/t_/**/image*";

genSample320() => "c:/t_/**/image*[^0-9]";

genSample330() => "c:/t_/**/*.[a-z][a-z]";

genSample340() => "c:/t_/**/*?";

genSample350() => "c:/t_/**/*";

genSample360() => "c:/t_/**/*??????????";

genSample370() => "c:/t_/Virtual City/t1/*[0-9]";

genSample380() => "c:/t_/**/*[^0-9]";

genSample390() => "c:/t_/Virtual City/t2/*[^0-9]";

genSample400() => "c:/t_/**/??????????*";

genSample410() => "c:/t_/**/[a-z]?[a-z]";

genSample420() => "c:/t_/**/[a-z]*[a-z]";

genSample430() => "../../../**/";

genSample440() => "c:/t_/**/[^a-zA-Z0-9]*";

genSample450() => "c:/t_/**/[A-Z]*";

genSample460() => "c:/**/*";

genSample470() => "c:/Windows/**/";

genSample480() => "c:/Windows/**/*";

genSample490() => "c:/t_/*/**/*";

genSample500() => "../*";

main() {
  var a = Dir[genSample500()], e;
  p("Number of matching files: ${a.length}");
  for (e in a) {
    p(e);
    //print(e.path);
  }
}
```

Those are many of the patterns I've tested with while developing the Glob library.

------------

The inspiration for the Glob library came when I was looking to test some other library by loading random files that ended with the .dart extension. In Ruby I hardly needed to think before doing basic IO. In Dart I also wish I can close that gap and make Dart easier to use.

After I had started it, I googled "dart glob" and found a related discussion on the Dart bug tracker. While the interest exists, I think this Glob library went further than the previous attempt.

The Lexer can also be used for syntax highlighting which I use in a custom text editor of mine. The parser gave birth to the TokenStream and ParserStatus classes which I have yet to document.

I have not used Regex for the pattern matching because I had started a pattern matching library with the CodeUnitStream class which I used for lexers. So I tried to expand it with the CodeUnitMatcher class and use that instead. That gave me a need to add several supporting methods to the CodeUnitStream class. And the Regex of Dart is not known for being super efficient yet. :-)

While testing the Glob library, I'd often run the same pattern with Ruby for comparison purposes. Ruby has very good IO features, some of which are written in C. I found one difference related to how Ruby did some recursions with out of order directories, but that was Ruby's fault. Mostly both Ruby and Dart were about as quick with these Glob features.

One of my personal goals was to learn some more about pattern matching. At the end of it I felt like an old curmudgeon who still cared about files, when a lot of programming nowadays is just sockets, browser and databases. :-)

Enjoy!

Cheers,
Joao














