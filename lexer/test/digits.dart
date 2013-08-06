import "../../lang/lib/lang.dart";
import "../lib/digit.dart";
import "../../codeunitstream/lib/codeunitstream.dart";


genSample1() => 'some 123 for the 8272 win';
genSample2() => 'some';
genSample3() => 'some 123';
genSample4() => 'some 123 for';
genSample5() => 'some 123 for the 8272';
genSample6() => '123 for the 8272 win';

main() {
  var sample = genSample1(), lexer = new DigitLexer(), tokens = [],
    stream = new CodeUnitStream(text: sample);
  lexer.parseTokenStrings(stream, lexer.spawnStatus(), 
      (tt, ts) => tokens.add([tt, ts]));
  p(tokens.map((kv) => [DigitLexer.keywordString(kv[0]), kv[1]]).toList());
  stream.reset();
  lexer.parse(stream, lexer.spawnStatus(), (tt) {
    p([tt, stream.startIndex, stream.currentIndex]);
  });
}



