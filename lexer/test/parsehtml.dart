import "../../lang/lib/lang.dart";
import "../lib/html.dart";
import "../../codeunitstream/lib/codeunitstream.dart";

genSample1() => '<a href="  ht  tp://">etc</a>';
genSample2() => '<a href="http://">etc</a>';
genSample3() => 'ball';
genSample4() => 'ball<';
genSample5() => 'ball<a';
genSample6() => 'ball<a href';
genSample7() => 'ball<a href=';
genSample8() => 'ball<a href="';
genSample9() => '<a href="http://"';
genSample10() => '<a href="http://">';
genSample11() => '<a href="http://">etc';
genSample12() => '<a href="http://">etc<';
genSample13() => '<a href="http://">etc</';
genSample14() => '<a href="http://">etc</a';
genSample15() => '<a href="http://">etc</a>';

genSample20() => '</a>';

genSample30() => '<a href=http://essa.com>';

genSample40() => '<!-- comment -->';
genSample41() => '<!';
genSample42() => '<!--';
genSample43() => '<!-- comment';
genSample44() => '<!-- comment -->';
genSample45() => '<!-- multiline\ncomment -->';

genSample50() => '<!DOCTYPE html>';

genSample60() => "<a href='http://'>etc</a>";

genSample90() => """
<a href=http://essa.com>
etc
</a>
""";

genSample91() => """
<ul class="menu">
<li class="menu"><a class="menu" href="http://www.christianwimmer.at/">Home</a></li>
<li class="menu"><a class="menu" href="http://www.christianwimmer.at/About/">About Me</a></li>
<li class="menu"><a class="menu" href="http://www.christianwimmer.at/Publications/">Publications</a></li>
<li class="menu"><a class="menu" href="http://www.christianwimmer.at/Activities/">Professional Activities</a></li>
<li class="menu"><a class="menu" href="http://www.christianwimmer.at/Teaching/">Teaching</a></li>
<li class="menu"><a class="menu" href="http://www.christianwimmer.at/Bassoon/">Bassoon</a></li>
<li class="menu"><a class="menu" href="http://www.christianwimmer.at/Contact/">Contact</a></li>
</ul>
""";

genSample92() => """
<!DOCTYPE html>
<!--[if IE 8]><html class="lt-ie10 ie8 " lang="en" 
data-fouc-class-names="swift-loading"><![endif]-->
<!--[if IE 9]><html class="lt-ie10 ie9 " lang="en" 
data-fouc-class-names="swift-loading"><![endif]-->
<!--[if gt IE 9]><!--><html lang="en"  
data-fouc-class-names="swift-loading"><!--<![endif]-->
  <head>
""";

genSample200() => '<a/b>';
genSample201() => '<br />';


main() {
  var sample = genSample60(), lexer = new HtmlLexer(), tokens = [],
    stream = new CodeUnitStream(text: sample);
  lexer.parseTokenStrings(stream, lexer.spawnStatus(), 
      (tt, ts) => tokens.add([tt, ts]));
  p(tokens.map((kv) => [HtmlLexer.keywordString(kv[0]), kv[1]]).toList());
  stream.reset();
  lexer.parse(stream, lexer.spawnStatus(),
      (tt) => p([tt, stream.startIndex, stream.currentIndex]));
}



