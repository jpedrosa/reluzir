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



