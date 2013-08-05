RE
==

RE is a RegExp wrapper library for Dart. Its main purpose is to approximate the succinctness of literal RegExp of other languages.

With a lot of RegExp in code it's hard to cache them all or to name them all. Using a library like this one helps to make RegExp more of a first-class construct in Dart.

=========

A simple test:

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

It prints this:

```
DRRegExp(pattern: "\\s", caseSensitive: true, multiLine: false)
Match(" ")
true
Match("ABC" 1: "BC", 2: "B", 3: "C")
null
Iterable(Match("zA" 1: "A"), Match("BC" 1: "C"))
Match("zA" 1: "A")
Match("AB" 1: "B")
Iterable(Match("zA"), Match("zD"), Match("zG"))
Iterable(Match("zA" 1: "A"), Match("zD" 1: "D"), Match("zG" 1: "G"))
Iterable(Match("zA" 1: "A"))

```

And a simple benchmark:

```dart
import "../grant/text/re.dart";


runMultipleTimes(fn()) {
  for (var i = 0; i < 10000; i++) {
    fn();
  }
}


bm(desc, fn()) {
  runMultipleTimes(fn); // Warm up some.
  var sw = new Stopwatch();
  sw.start();
  runMultipleTimes(fn);
  sw.stop();
  print("${desc}: ${sw.elapsedMilliseconds}ms");
}


runRawString(String s) {
  var i, mirror = s.codeUnits, len = s.length, mi = -1, r, c;
  for (i = 0; i < len; i++) {
    c = mirror[i];
    if (c >= 48 && c <= 57) {
      if (mi < 0) {
        mi = i;
      }
    } else if (mi >= 0) {
      break;
    }
  }
  if (mi >= 0) {
    r = s.substring(mi, i);
  }
  return r;
}


runDefaultRegExp(s) {
  return new RegExp(r"\d+").firstMatch(s);
}


var reCached = new RegExp(r"\d+");

runDefaultRegExpCached(s) {
  return reCached.firstMatch(s);
}


runDRRegExp(s) {
  return RE[r"\d+"].match(s);
}


main() {
  var sampleData = """
Lorem Ipsum is simply dummy text of the printing and typesetting industry.
Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,
when an unknown printer took a galley of type and scrambled it to make a type
specimen book. It has survived not only five centuries, but also the leap into
electronic typesetting, remaining essentially unchanged. It was popularised in
the 1960s with the release of Letraset sheets containing Lorem Ipsum passages,
and more recently with desktop publishing software like Aldus PageMaker
including versions of Lorem Ipsum.
""";
  bm("runDefaultRegExp", () => runDefaultRegExp(sampleData));
  bm("runDefaultRegExpCached", () => runDefaultRegExpCached(sampleData));
  bm("runRawString", () => runRawString(sampleData));
  bm("runDRRegExp", () => runDRRegExp(sampleData));
  var e = "1500", v1 = runDefaultRegExp(sampleData)[0],
    v2 = runDefaultRegExpCached(sampleData)[0],
    v3 = runRawString(sampleData),
    v4 = runDRRegExp(sampleData)[0];
  print("Litmus test: ${e == v1 && e == v2 && e == v3 && e == v4}");
}
```

The bench prints:

```
runDefaultRegExp: 68ms
runDefaultRegExpCached: 64ms
runRawString: 6ms
runDRRegExp: 65ms
Litmus test: true
```

=========

I've discovered that using library code is nearly enough to make RegExp about as easy to use as literal RegExp of other languages.

On top of that I added new methods and aliases to the RegExp wrapper to make it more familiar to those of us who come from languages like Ruby or JavaScript.

From Ruby we have the "match" method. From JavaScript we have the "test" and "exec" methods. 

I don't know why, but the default Dart RegExp methods are named passively: "firstMatch", "allMatches"... That annoys me a little. 

Beside "match" that I really like for being shorter and because I was used to it from Ruby, I also added two experiments: "matchAll" and "matchAt". I'm a little addicted to these method names ending in "At" to give an idea of position.

So unlike in Ruby which has a second parameter on "match" for index positioning, we have "matchAt" instead for that case. Dart also has the 
"matchAsPrefix" for that use-case. So we alias to it.

=========

A little story: At first I didn't want to add a RegExp wrapper just because I wanted the extra "match" method. To justify creating a wrapper, I thought other people would want to have JavaScript friendly methods "test" and "exec". Then when I added "matchAll" and "matchAt" that settled the deal.

What cause me to work on this was that I've been trying to get a small part of CodeMirror that deals with syntax lexer converted to Dart so I could perhaps plug it into a text editor. CodeMirror has tons of syntax highlighters. But CodeMirror also uses tons of RegExp!

At the moment Dart's RegExp is said to have a bug that slows it down. Hopefully it will be fixed at some point.

=========

Thanks.

* Credit for Lorem Ipsum explanation goes to http://www.lipsum.com/
