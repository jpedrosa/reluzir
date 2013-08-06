library DigitLexer;

import "common.dart";
import "../../lang/lib/lang.dart";


class DigitLexer extends LexerCommon {
  
  DigitLexer() {
    entryTokenizer = inText;
    defaultTokenizer = inText;
  }

  static const TEXT = 0;
  static const DIGIT = 1;
  
  static keywordString(n) {
    var r;
    if (n == 0) {
      r = "text";
    } else if (n == 1) {
      r = "number";
    }
    return r;
  }
  
  inText(stream, status) {
    var r;
    if (stream.eatUntil((c) => c >= 48 && c <= 57 ? c : -1)) { // 0-9
      r = TEXT;
    } else if (stream.eatWhileDigit()) {
      r = DIGIT;
    } else {
      stream.skipToEnd();
      r = TEXT;
    }
    return r;
  }
  
}




