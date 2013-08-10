import "../../lang/lib/lang.dart";
import "../lib/css.dart";
import "../../codeunitstream/lib/codeunitstream.dart";

genSample1() => '.a { background-color: #FFF; }';
genSample2() => '.a {';

genSample10() => '.a { background-image: url("i.png"); }';
genSample11() => '.a { background-image: url';
genSample12() => '.a { background-image: url(';
genSample13() => '.a { background-image: url("i.png"';
genSample14() => '.a { background-image: url("i.png")';
genSample15() => '.a { background-image: url("i.png");';
genSample16() => '.a { background-image: url("i.png"); ';


genSample20() => '/* comment */';
genSample21() => '/*';
genSample22() => '/* comment';
genSample23() => '/*\ncomment\n*/';
genSample24() => '\n/*\ncomment\n*/';
genSample25() => ' /* comment */ ';

genSample50() => '@a { background-color: #FFF; }';

genSample60() => '@a ;';

genSample70() => 'a { /* comment */ }';
genSample71() => 'a { /*';
genSample72() => 'a { /* comment ';
genSample73() => 'a { /* comment */';
genSample74() => 'a { /* comment */ ';

genSample80() => 'a { b: ; }';
genSample81() => 'a { b';
genSample82() => 'a { b:';
genSample83() => 'a { b: ;';

genSample90() => 'a { b /* comment */: ; }';
genSample91() => 'a { b /*';
genSample92() => 'a { b /* comment ';
genSample93() => 'a { b /* comment */';
genSample94() => 'a { b /* comment */:';

genSample100() => 'a { b: /* comment */; }';

genSample110() => """a {
b: /* comment */;
c: 10px;
}""";

genSample120() => '@import url("a.css");';
genSample121() => '@import';
genSample122() => '@import url';
genSample123() => '@import url(';
genSample124() => '@import url("';
genSample125() => '@import url("a.css';
genSample126() => '@import url("a.css"';

genSample130() => '@import "a.css";';
genSample131() => '@import "';
genSample132() => '@import "a.css';
genSample133() => '@import "a.css"';

genSample140() => '@import "a.css" bb, ccc;';

genSample150() => "@import 'a.css'";
genSample151() => "@import '\"'";
genSample152() => r"@import '\''";
genSample153() => r'@import "\""';

genSample160() => """
@import 'a.css';
@import 'b.css';
""";

genSample170() => '@import "a.css" print, media;';
genSample171() => '@import "a.css" print';
genSample172() => '@import "a.css" print,';
genSample173() => '@import "a.css" print, media';

genSample180() => """
/* not yet? */
/* comment */ @import /* comment */ "yay.css" /* comment */ print /* comment */ ; /* comment */ 
""";

genSample190() => '@import url("a.css") bb, ccc;';

genSample200() => 'span[hello="Cleveland"][goodbye="Columbus"] { color: blue; }';

genSample210() => 'a { background: #FFF; }';
genSample211() => 'a { background: #FFF';
genSample212() => 'a { background: #FFF;';
genSample213() => 'a { background: #FFF; ';

genSample220() => '@import url(a.css);';

genSample300() => '@page { margin: 1.5cm 1.1cm; }';
genSample301() => '@page { margin';
genSample302() => '@page { margin:';
genSample303() => '@page { margin: 1.5cm 1.1cm';
genSample304() => '@page { margin: 1.5cm 1.1cm;';
genSample305() => '@page { margin: 1.5cm 1.1cm; ';

genSample400() => "html { margin: 0 }";

genSample410() => "@media { .example:before { font-family: serif } }";

main() {
  var sample = genSample220(), lexer = new CssLexer(), tokens = [],
    stream = new CodeUnitStream(text: sample);
  lexer.parseTokenStrings(stream, lexer.spawnStatus(), 
      (tt, ts) => tokens.add([tt, ts]));
  p(tokens.map((kv) => [CssLexer.keywordString(kv[0]), kv[1]]).toList());
  //stream.reset();
  //lexer.parse(stream, lexer.spawnStatus(), (tt) {
  //  p([tt, stream.startIndex, stream.currentIndex]);
  //});
}



