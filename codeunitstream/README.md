CodeUnitStream
==============

CodeUnitStream is sort of like a [StringStream of other languages](http://www.cplusplus.com/reference/sstream/stringstream/). It helps to parse text after tokens. Such technology is often used by text processors such as text editors like [CodeMirror](https://github.com/marijnh/CodeMirror/blob/master/mode/xml/index.html).

In Dart strings are still being optimized and the RegExp currently seems to have a bug that slows it down. That's why I've focused on the character int values instead, as it could be faster.

==========

To get the code units of a string in Dart, use code like this:

```dart
main() {
  print("abc".codeUnits);
}
```

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

=========

Or a more complicated example for matching phone numbers in the (123)456-7890 format as seen in a [Rebol example](http://rebol2.blogspot.com.br/2013/07/parse-aid.html) that motivated it:

```
import "../../lang/lib/lang.dart";
import "../lib/codeunitstream.dart";

genSample1() => "(123)456-7890";
genSample2() => "(123)456-7890\n554-0213";
genSample3() => "123445";
genSample4() => "ass323-2445ff";
genSample5() => "(123)1456-78901\n9554-02139";
genSample6() => "(23)456-781\n94-31139";
genSample7() => "012345678901234567890";
genSample8() => "1010-2314987-07541";

leanerParsePhones(stream) {
  // 40 - open paren
  openParenOrDigit(c) => (c == 40 || (c >= 48 && c <= 57)) ? c : -1;
  localArea(o) {
    return o.eatDigit() &&
      o.eatDigit() &&
      o.eatMinus() &&
      o.eatDigit() &&
      o.eatDigit() &&
      o.eatDigit() &&
      o.eatDigit();
  }
  areaCode(o) {
    return o.eatDigit() &&
      o.eatDigit() &&
      o.eatDigit() &&
      o.eatCloseParen() &&
      o.eatDigit() && localArea(o);
  }
  while (!stream.isEol) {
    //p(stream);
    if (stream.seekContext(openParenOrDigit)) {
      if (stream.eatOpenParen()) {
        if (stream.maybeEat(areaCode)) {
          p(["namaste", stream.collectTokenString()]);
        }
      } else if (stream.eatDigit() && stream.maybeEat(localArea)) {
        p(["yat", stream.collectTokenString()]);
      }
    } else {
      break;
    }
  }
}

parsePhones(stream) {
  // 40 - open paren
  openParenOrDigit(c) => (c == 40 || (c >= 48 && c <= 57)) ? c : -1;
  localArea(o) {
    return o.keepMilestoneIfNot(o.eatDigit) &&
      o.keepMilestoneIfNot(o.eatDigit) &&
      (o.eatMinus() || o.yankMilestoneIfNot(o.eatDigit)) &&
      o.keepMilestoneIfNot(o.eatDigit) &&
      o.keepMilestoneIfNot(o.eatDigit) &&
      o.keepMilestoneIfNot(o.eatDigit) &&
      o.keepMilestoneIfNot(o.eatDigit);
  }
  areaCode(o) {
    return o.keepMilestoneIfNot(o.eatDigit) &&
      o.keepMilestoneIfNot(o.eatDigit) &&
      o.keepMilestoneIfNot(o.eatDigit) &&
      (o.eatCloseParen() || o.yankMilestoneIfNot(o.eatDigit)) &&
      o.keepMilestoneIfNot(o.eatDigit) && localArea(o);
  }
  while (!stream.isEol) {
    //p(stream);
    if (stream.seekContext(openParenOrDigit)) {
      if (stream.eatOpenParen()) {
        if (stream.maybeEat(areaCode)) {
          p(["namaste", stream.collectTokenString()]);
        }
      } else if (stream.eatDigit() && stream.maybeEat(localArea)) {
        p(["yat", stream.collectTokenString()]);
      }
    } else {
      break;
    }
  }
}

main() {
  var sample = genSample1();
  
  p("verbose");
  // keep milestone to try to optimize a little. too verbose
  parsePhones(new CodeUnitStream(text: sample));
  
  p("leaner");
  // one version that's leaner which worries less about optimization
  leanerParsePhones(new CodeUnitStream(text: sample));
}
```

I've also used CodeUnitStream to parse HTML which helped to develop it a little more. Check the [Reluzir Lexer](https://github.com/jpedrosa/reluzir/tree/master/lexer) library soon for that.

=============

I expect to continue using CodeUnitStream for other kinds of parsers.

It's pretty quick. To parse HTML of thousands of lines it takes anywhere from 2ms to over 50ms depending on whether I'm running it from Dart or Dart2JS and also depending on the browser. I haven't yet worked on more optimizations as I don't have more benchmarks yet.

To help to keep the code faster I have avoided nesting functions too much. That way I've sort of "inlined" them myself. Then again, I've added a lot of methods by default, some of which I may never use. :-)

