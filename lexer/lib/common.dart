library Lexer;

import "../../codeunitstream/lib/codeunitstream.dart"; 
import "../../str/lib/str.dart";
import "../../lang/lib/lang.dart";


class LexerStatus {
  
  var lexer, tokenizer, spaceTokenizer;
  
  LexerStatus({this.lexer}) {
    tokenizer = lexer.entryTokenizer;
    spaceTokenizer = lexer.spaceTokenizer;
  }
  
}


class LexerCommon {
  
  var entryTokenizer, defaultTokenizer, spaceTokenizer;

  doParseStream(stream, status, resultFn(tokenType)) {
    var tt;
    while (!stream.isEol) {
      tt = null;
      if (status.spaceTokenizer != null) {
        tt = status.spaceTokenizer(stream, status);
      }
      if (tt == null) {
        tt = status.tokenizer(stream, status);
        if (tt == null) {
          tt = defaultTokenizer(stream, status);
        }
      }
      resultFn(tt);
      stream.startIndex = stream.currentIndex;
    }
  }
  
  parseTokenStrings(stream, status, resultFn(tokenType, tokenString)) {
    parse(stream, status, (tt) => resultFn(tt, stream.currentTokenString));
  }
  
  parse(stream, status, resultFn(tokenType)) {
    var s = stream.text, i = Str.indexOfNewLine(s),
      len = s.length, si = 0;
    while (i >= 0) {
      if (i - si > 1) {
        stream.lineEndIndex = i;
        doParseStream(stream, status, resultFn);
      }
      si = i + 1;
      stream.startIndex = si;
      stream.currentIndex = si;
      stream.lineStartIndex = si;
      i = Str.indexOfNewLine(s, si);
    }
    if (len > si) {
      stream.lineEndIndex = len;
      doParseStream(stream, status, resultFn);
    }
  }
  
  spawnStatus() {
    return new LexerStatus(lexer: this);
  }
  
}


