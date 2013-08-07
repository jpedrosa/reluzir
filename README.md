Reluzir is an umbrella project for several Dart libraries.

Motivation: Dart is a young language with a bright future. So why not use it
more?

Know Dart yet? We also have [learn Dart in 15 minutes tutorial.](https://github.com/jpedrosa/reluzir/blob/master/learn_dart_in_15_minutes/learn_dart_in_15_minutes.dart)

=======

Lexer
-----

Lexer is a library designed for parsing tokens using the Reluzir [CodeUnitStream](https://github.com/jpedrosa/reluzir/tree/master/codeunitstream) library for driving the matching.

It includes the HtmlParser for a simple HTML parsing that could be used directly to provide syntax coloring of HTML data.

Here's a sample:

```dart
import "../../lang/lib/lang.dart";
import "../lib/html.dart";
import "../../codeunitstream/lib/codeunitstream.dart";

genSample1() => '<a href="http://">etc</a>';

main() {
  var sample = genSample1(), lexer = new HtmlLexer(), tokens = [],
    stream = new CodeUnitStream(text: sample);
  lexer.parseTokenStrings(stream, lexer.spawnStatus(), 
      (tt, ts) => tokens.add([tt, ts]));
  p(tokens.map((kv) => [HtmlLexer.keywordString(kv[0]), kv[1]]).toList());
  stream.reset();
  lexer.parse(stream, lexer.spawnStatus(),
      (tt) => p([tt, stream.startIndex, stream.currentIndex]));
}
```

CodeUnitStream
--------------

CodeUnitStream is sort of like a [StringStream of other languages](http://www.cplusplus.com/reference/sstream/stringstream/). It helps to parse text after tokens. Such technology is often used by text processors such as text editors like [CodeMirror](https://github.com/marijnh/CodeMirror/blob/master/mode/xml/index.html).

CodeUnitStream includes often used patterns in its methods to make the common case easier. Here's how to match digits:

```
import "../../lang/lib/lang.dart";
import "../lib/codeunitstream.dart";

parseLeadingInt(stream) {
  var n;
  if (stream.eatWhileDigit() || (stream.eatMinus() && stream.eatWhileDigit())) {
    n = int.parse(stream.collectTokenString());
  }
  return n;
}

main() {
  p(parseLeadingInt(new CodeUnitStream(text: "78px")));
  p(parseLeadingInt(new CodeUnitStream(text: "-54px")));
}
```

Str
---

Str is a library dedicated to generic String methods.

Here's a sample:

```dart
import "../lib/str.dart";
import "../../lang/lib/lang.dart";


main() {
  var sample = "first\nsecond\nthird", i = Str.indexOfNewLine(sample),
    lineCount = 1;
  while (i >= 0) {
    lineCount++;
    i = Str.indexOfNewLine(sample, i + 1);
  }
  p("Line count: ${lineCount}");
}
```

RE
--

RE is a RegExp wrapper library for Dart. Its main purpose is to approximate the succinctness of literal RegExp of other languages.

```dart
import "../lib/re.dart";
import "../../lang/lib/lang.dart";


main() {
  p(RE[r"\s"]);
  p(RE[r"\s"].match("s s"));
  p(REi[r"a((b)(c))"].test("zABCz"));
  p(REi[r"a((b)(c))"].match("zABCz"));
  p(REi[r"a((b)(c))"].firstMatch("=-yt"));
  p(RE[r".(.)"].matchAll("zABCz"));
  p(RE[r".(.)"].exec("zABCz"));
  p(RE[r".(.)"].matchAt("zABCz", 1));
  p(REm[r"^\w\w"].matchAll("""
zABCz
zDEFz
zGHIz
"""));
  p(REmi[r"^[a-z]([a-z])"].matchAll("""
zABCz
zDEFz
zGHIz
"""));
  p(REi[r"^[a-z]([a-z])"].matchAll("""
zABCz
zDEFz
zGHIz
"""));
}
```

=======

Lang
----

Lang is a small library that adds some core language extensions to Dart.

```dart
import "../lib/lang.dart";


main() {
  var s = "   ", a = ["   ", "bee", "   "]; // Only spaces
  print("'s' using just the print command: ${s}");
  print("'s' using inspect within the print command: ${inspect(s)}");
  print("'a' using just the print command:");
  print(a);
  print("'a' using the p (printInspect) command:");
  p(a);
}
```

=======

ParseLeadingInt
---------------

ParseLeadingInt is useful when parsing CSS values in the browser that may contain a leading int. E.g. "21px".

```dart
import "../lib/parseleadingint.dart";

main() {
  print(ParseLeadingInt.parse("34px"));
  print(ParseLeadingInt.parse("-", orZero: true));
}
```

=======

ParseDict
---------

ParseDict is a library for parsing Python Dict-like structures. The first
version only covers String keys to String values.

Example:

```dart
import "../lib/parsedict.dart";
    
main() {
  var sample = r"""
{'abrac\'a': 'dabra','Dart':'Rocks'}
""";
  var k, dict = ParseDict.parse(sample);
  for (k in dict.keys) {
    print("${k}:${dict[k]}");
  }
}
```

=======

LICENSE

Pick one of the three. MIT LICENSE, BSD LICENSE or GPL LICENSE.

=======

About the name.

Reluzir is a Portuguese word that means glisten.

The author has seen a comment before mentioning how much easier it can be to
pick a name in a foreign language such as Portuguese for a project. Picking a 
unique English name can be a lot of trouble. So let's go Portuguese! :-)

=======

Author: Joao Pedrosa - joaopedrosa at gmail dot com



