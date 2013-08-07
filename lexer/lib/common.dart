library Lexer;

import "../../codeunitstream/lib/codeunitstream.dart"; 
import "../../str/lib/str.dart";
import "../../lang/lib/lang.dart";


class LexerStatus {
  
  var tokenizer, spaceTokenizer;
  
  LexerStatus({entryTokenizer, spaceTokenizer}) {
    tokenizer = entryTokenizer;
    this.spaceTokenizer = spaceTokenizer;
  }
  
  clone() {
    return new LexerStatus(entryTokenizer: tokenizer,
        spaceTokenizer: spaceTokenizer);
  }
  
  operator == (other) {
    return tokenizer.toString() == other.tokenizer.toString() &&
        spaceTokenizer.toString() == other.spaceTokenizer.toString();
  }
  
  toString() {
    return "LexerStatus(tokenizer: ${tokenizer}, "
        "spaceTokenizer: ${spaceTokenizer})";
  }
  
}


class LexerCommon {
  
  var entryTokenizer, defaultTokenizer, spaceTokenizer;

  parseLine(stream, status, resultFn(tokenType)) {
    var tt;
    while (!stream.isEol) {
      tt = null;
      if (status.spaceTokenizer != null) {
        tt = status.spaceTokenizer(stream, status);
      }
      if (tt == null) {
        tt = status.tokenizer(stream, status);
        if (tt == null) {
          status.tokenizer = defaultTokenizer;
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
        parseLine(stream, status, resultFn);
      }
      si = i + 1;
      stream.startIndex = si;
      stream.currentIndex = si;
      stream.lineStartIndex = si;
      i = Str.indexOfNewLine(s, si);
    }
    if (len > si) {
      stream.lineEndIndex = len;
      parseLine(stream, status, resultFn);
    }
  }
  
  spawnStatus() {
    return new LexerStatus(entryTokenizer: this.entryTokenizer,
        spaceTokenizer: this.spaceTokenizer);
  }
  
}


