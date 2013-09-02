import "../../lang/lib/lang.dart";
import "../lib/glob/parser.dart";

genSample1() => "**/*.dart";
genSample2() => "c:/t_/**/*.?";
genSample3() => "c:/t_/**/image*[0-9]";


main() {
  var parser = new GlobParser(), m = parser.parse(genSample1());
  p(m); // Matcher returned as a result of the parsing.
  m.prepare();
  p(m);
  p(parser.parse(genSample2()));
  p(parser.parse(genSample3()));
}





