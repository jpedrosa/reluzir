import "../../lang/lib/lang.dart";
import "../lib/glob/lexer.dart";
import "../../codeunitstream/lib/codeunitstream.dart";

genSample1() => 't_';

genSample10() => 'c:/t_';

genSample20() => 'c:/t_/shango';

genSample30() => 'c:/t_/**/';

genSample40() => 'c:/t_/**/*.{dart,html}';

genSample50() => 'c:/t_/**/*.[ch]';

genSample60() => 'c:/t_/**/*.[^a-z]';

genSample70() => 'c:/t_/**/image*[0-9]';


main() {
  var sample = genSample70(), lexer = new GlobLexer(), tokens = [],
    stream = new CodeUnitStream(text: sample);
  lexer.parseTokenStrings(stream, lexer.spawnStatus(),
      (tt, ts) => tokens.add([tt, ts]));
  p(tokens.map((kv) => [GlobLexer.keywordString(kv[0]), kv[1]]).toList());
}





