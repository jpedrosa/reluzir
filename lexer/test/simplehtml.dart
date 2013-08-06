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



