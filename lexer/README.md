Lexer
=====

Lexer is a library designed for parsing tokens using the Reluzir [CodeUnitStream](https://github.com/jpedrosa/reluzir/tree/master/codeunitstream) library for driving the matching.

It includes the HtmlParser for a simple HTML parsing that could be used directly to provide syntax coloring of HTML data.

It could also serve a higher level parser with already parsed tokens.

=========

Recently added a CssLexer to the set:

```dart
import "../../lang/lib/lang.dart";
import "../lib/css.dart";
import "../../codeunitstream/lib/codeunitstream.dart";

genSample1() => '.a { background-color: #FFF; }';

main() {
  var sample = genSample1(), lexer = new CssLexer(), tokens = [],
    stream = new CodeUnitStream(text: sample);
  lexer.parseTokenStrings(stream, lexer.spawnStatus(), 
      (tt, ts) => tokens.add([tt, ts]));
  p(tokens.map((kv) => [CssLexer.keywordString(kv[0]), kv[1]]).toList());
}
```

When run it prints this:

```
[["text", ".a "], ["symbol", "{"], ["text", " "], ["variable", "background-color"], ["symbol", ":"], ["text", " "], ["hexa", "#FFF"], ["symbol", ";"], ["text", " "], ["symbol", "}"]]
```

=========

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

It prints this when run:

```
[["symbol", "<"], ["keyword", "a"], ["text", " "], ["variable", "href"], ["symbol", "="], ["string", "\""], ["string", "http://"], ["string", "\""], ["symbol", ">"], ["text", "etc"], ["symbol", "<"], ["symbol", "/"], ["keyword", "a"], ["symbol", ">"]]
[3, 0, 1]
[1, 1, 2]
[0, 2, 3]
[2, 3, 7]
[3, 7, 8]
[4, 8, 9]
[4, 9, 16]
[4, 16, 17]
[3, 17, 18]
[0, 18, 21]
[3, 21, 22]
[3, 22, 23]
[1, 23, 24]
[3, 24, 25]
```

Tokens are found in the CodeUnitStream instance between the startIndex and the currentIndex variables.

A lower level parsing method called Lexer#parse returns just the token types which are numeric by default.

A higher level parsing method called Lexer#parseTokenStrings returns both the numeric token type and the token string.

To convert the numeric token type to a readable string, pass the token type to the static method of the HtmlLexer.keywordString(int tokenType).

======

I expect to include these Lexer methods in a text editor. So far I've only included them in a web sample:

[http://postimg.org/image/fk0ww2lbn/](http://postimg.org/image/fk0ww2lbn/)

======

Of note is that I've avoided using RegExp because Dart still might have a bug that slows RegExp down.

I had used a lot of parsing with switch statements. Switch statements are harder to build and maintain.

Using CodeUnitStream and Lexer makes parsing more maintanable and still quite quick. Halting and resuming parsing is also standard by default.

I had also used a lot of RegExp for parsing purposes before. I always used them in small pieces rather than as the only parsing force. This made it easier to replace my using of them with custom pattern methods hosted by CodeUnitStream. Such as eatWhileAlpha for a-zA-Z matches or eatWhileDigit for 0-9 matches.








