Reluzir is an umbrella project for several Dart libraries.

Motivation: Dart is a young language with a bright future. So why not use it
more?

=======

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

ParseLeadingIng is useful when parsing CSS values in the browser that may contain a leading int. E.g. "21px".

```dart
import "../lib/parseleadingint.dart";

main() {
  print(ParseLeadingInt.parse("34px"));
  print(ParseLeadingInt.parse("-", orZero: true));
}
```

=======

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

Reluzir is a Portuguese word that means to sparkle.

The author has seen a comment before mentioning how much easier it can be to
pick a name in a foreign language such as Portuguese for a project. Picking a 
unique English name can be a lot of trouble. So let's go Portuguese! :-)

=======

Author: Joao Pedrosa - joaopedrosa at gmail dot com



