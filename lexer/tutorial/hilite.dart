import 'dart:html' as DH; // Give a wrapping name to the imported library.
import "../lib/html.dart"; // HtmlLexer
import "../lib/css.dart"; // CssLexer
import "../../codeunitstream/lib/codeunitstream.dart"; // CodeUnitStream


class Hilite {

  // Declare the instance variables.
  var idSel, idTa, debugWindow, idHiliteButton, debugWindowCls,
    idLoadSampleButton, ta, htmlSample, cssSample, sel,
    idOutputDiv, outDiv;
  
  // Configuration is passed to the instance via named parameters.
  // The "this." prefix sets the variables for us. It's a shortcut.
  Hilite({this.idSel: "selType", this.idTa: "ta1",
      this.idHiliteButton: 'bHilite',
      this.idLoadSampleButton: 'bLoadSample',
      this.debugWindowCls: "debugWindow",
      this.idOutputDiv: "outputDiv1",
      this.htmlSample: "", this.cssSample: ""}) {
    prepareInput();
    loadSample();
  }
  
  // Shortcut for retrieving elements based on id.
  el(s) => DH.query("#${s}");
  
  // Prepare the input events.
  prepareInput() {
    // Events generally include one parameter which we need to
    // specify even if we just ignore it.
    sel = el(idSel);
    sel.onChange.listen((ev) => noticeTypeChange());
    el(idHiliteButton).onClick.listen((ev) => hilite());
    el(idLoadSampleButton).onClick.listen((ev) => loadSample());
    ta = el(idTa);
    outDiv = el(idOutputDiv);
  }
  
  noticeTypeChange() {
    p("<Type changed!>");
    loadSample(); // Load sample data on type change.
  }
  
  // The way to write a side-effect free getter.
  get isCssSelected => sel.value == 'CSS'; 
  
  // Load some sample data.
  loadSample() {
    ta.value = isCssSelected ? cssSample : htmlSample;
    hilite();
  }
  
  // Uses the neighboring lexer features to get ahead.
  hilite() {
    var lexer = isCssSelected ? new CssLexer() : new HtmlLexer(), 
      stream = new CodeUnitStream(),
      status = lexer.spawnStatus(), // The status needs to be a fresh one.
      prefix = sel.value.toLowerCase(),
      colorClass = isCssSelected ? defaultCssColorSet : defaultHtmlColorSet;
    // In one swoop get the sample data from the TextArea element,
    // split it into lines, pass each line to the lexer to
    // transform into tokens. From the tokens make span elements
    // which with their style class feature should paint the tokens
    // into the configurable colors set in the style of the hilite HTML.
    outDiv.innerHtml = ta.value.split("\n").map((line) {
      var sb = new StringBuffer(); // Some efficient string concatenation.
      stream.text = line; // Load line into CodeUnitStream.
      lexer.parse(stream, status, (tt) { // Give the lexer some work.
        // String interpolation makes this more succinct.
        sb.write('<span class="${prefix}${colorClass(tt)}">');
        // Escape some special HTML characters.
        sb.write(escapeHtml(stream.currentTokenString));
        sb.write('</span>');
      });
      // map iterates the lines replacing them with the returned content.
      return sb.toString(); // OK. Join the StringBuffer into a string.
    }).join("<br/>"); // Add HTML lines in place of the newlines.
  }
  
  escapeHtml(s) => s.replaceAll("<", "&lt;").replaceAll(">", "&gt;").
      replaceAll(" ", "&nbsp;");
  
  // print for debugging purposes.
  p(s) {
    var dw = debugWindow, md = new DH.DivElement();
    if (dw == null) {
      // Create a hosting element dynamically.
      dw = new DH.DivElement();
      dw.classes.add(debugWindowCls);
      debugWindow = dw;
      DH.document.body.children.add(dw);
    }
    md.text = s;
    // Collections standardize many DOM calls.
    dw.children.add(md);
  }

  // No hard-coded colors. Just hard-coded style classes instead.
  // These will be used as suffix. Like this: cssText.
  // Where css or html is the prefix. Some other prefix or suffix
  // could be added via constructor parameter instead.
  defaultCssColorSet(tt) {
    var r;
    switch (tt) {
      case 0: r = 'Text'; break;
      case 1: r = 'Keyword'; break;
      case 2: r = 'Variable'; break;
      case 3: r = 'Symbol'; break;
      case 4: r = 'String'; break;
      case 5: r = 'Comment'; break;
      case 6: r = 'Hexa'; break;
      case 7: r = 'Number'; break;
      default: r = 'Text';
    }
    return r;
  }

  defaultHtmlColorSet(tt) {
    var r;
    switch (tt) {
      case 0: r = 'Text'; break;
      case 1: r = 'Keyword'; break;
      case 2: r = 'Variable'; break;
      case 3: r = 'Symbol'; break;
      case 4: r = 'String'; break;
      case 5: r = 'Comment'; break;
      case 6: r = 'Doctype'; break;
      default: r = 'Text';
    }
    return r;
  }
  
}


main() {
  DH.query('#status').innerHtml = "Hello Hilite!";
  var o = new Hilite(htmlSample: genHtmlSample(),
    cssSample: genCssSample()); // Prepare our instance.
}


genCssSample() {
  return """
#ta1 {
  width: 400px;
  height: 600px; 
}
.debugWindow {
  border: 1px solid gray;
  padding: 2px;
  background-color: silver;
  position: absolute;
  width: 150px;
  height: 250px;
  left: 700px;
  top: 400px;
  overflow: scroll;
}
#outputDiv1 {
  float: left;
  margin-left: 20px;
  padding: 5px;
  background-color: #ABABAB;
  border: 1px solid orange;
  width: 500px;
  height: 600px;
  overflow: scroll;
}
#hostTADiv1 {
  float: left;
  width: 400px;
  height: 600px;
}
#clearDiv1 {
  clear: both;
}
.cssText { color: red; }
.cssKeyword { color: green; }
.cssVariable { color: blue; }
.cssSymbol { color: #C8025A; }
.cssString { color: #9634BE; }
.cssComment { color: #3228C8; }
.cssHexa { color: #32C832; }
.cssNumber { color: #506478; }

.htmlText { color: red; }
.htmlKeyword { color: green; }
.htmlVariable { color: blue; }
.htmlSymbol { color: #C8025A; }
.htmlString { color: #9634BE; }
.htmlComment { color: #3228C8; }
.htmlDoctype { color: #32C832; }
""";
}


genHtmlSample() {
  return """
<!DOCTYPE html>

<html>
  <head>
    <title>Hilite</title>
    <style>
    </style>
  </head>
  <body>
    <h1>Hilite</h1>
    <h2 id="status">Dart is not running</h2>
    <div style="width:1000px; height:650px; border: 10px silver groove; padding:10px" >
      <div>
      <select id="selType"><option>CSS</option><option>HTML</option></select>
      <button id="bHilite">Hilite!</button>
      <button id="bLoadSample">Reload sample of selected type</button>
      </div>
      <div id="hostTADiv1">
      <textarea id="ta1">Sample data</textarea>
      </div>
      <div id="outputDiv1"></div>
      <div id="clearDiv1"></div>
    </div>
    <script type="application/dart" src="hilite.dart"></script>
    <script src="dart.js"></script>
  </body>
</html>
""";
}



