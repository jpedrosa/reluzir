library GlobLexer;

import "../../../lexer/lib/common.dart";
import "../../../lang/lib/lang.dart";


class GlobLexer extends LexerCommon {
  
  GlobLexer() {
    entryTokenizer = inRoot;
    defaultTokenizer = inText;
  }

  static const TEXT = 0;
  static const SEPARATOR = 1;
  static const NAME = 2;
  static const SYMBOL = 3;
  
  static keywordString(n) {
    var r;
    if (n == 0) {
      r = "text";
    } else if (n == 1) {
      r = "separator";
    } else if (n == 2) {
      r = "name";
    } else if (n == 3) {
      r = "symbol";
    }
    return r;
  }
  
  isContextChar(c) {
    return c == 47 || c == 42 || c == 63 || c == 123 ||
        c == 91 ? c : -1; // / * ? { [
  }

  inOptionalNameComma(stream, status) {
    var r;
    if (stream.eatComma()) {
      status.tokenizer = inOptionalName;
      r = SYMBOL;
    } else if (stream.eatCloseBrace()) {
      status.tokenizer = inBody; 
      r = SYMBOL;
    } else {
      r = inText(stream, status);
    }
    return r;
  }
  
  inOptionalName(stream, status) {
    var r;
    if (stream.eatWhileNeitherTwo(125, 44)) { // } ,
      status.tokenizer = inOptionalNameComma; 
      r = NAME;
    } else {
      r = inText(stream, status);
    }
    return r;
  }
  
  inOptionalNameMaybeEmpty(stream, status) {
    var r;
    if (stream.eatCloseBrace()) {
      r = SYMBOL;
      status.tokenizer = inBody;
    } else {
      r = inOptionalName(stream, status);
    }
    return r;
  }

  inSetMinusChar(stream, status) {
    stream.next();
    status.tokenizer = inSet;
    return NAME;
  }
  
  inSetLowerCaseMinus(stream, status) {
    var r;
    stream.eatMinus();
    if (stream.matchLowerCase() >= 0) {
      r = SYMBOL;
      status.tokenizer = inSetMinusChar;
    } else {
      r = NAME;
      status.tokenizer = inSet;
    }
    return r;
  }

  inSetUpperCaseMinus(stream, status) {
    var r;
    stream.eatMinus();
    if (stream.matchUpperCase() >= 0) {
      r = SYMBOL;
      status.tokenizer = inSetMinusChar;
    } else {
      r = NAME;
      status.tokenizer = inSet;
    }
    return r;
  }

  inSetDigitMinus(stream, status) {
    var r;
    stream.eatMinus();
    if (stream.matchDigit() >= 0) {
      r = SYMBOL;
      status.tokenizer = inSetMinusChar;
    } else {
      r = NAME;
      status.tokenizer = inSet;
    }
    return r;
  }
  
  inSet(stream, status) {
    var r;
    status.tokenizer = inSet;
    if (stream.eatCloseBracket()) {
      r = SYMBOL;
      status.tokenizer = inBody;
    } else if (stream.eatLowerCase()) {
      r = NAME;
      if (stream.matchMinus() >= 0) {
        status.tokenizer = inSetLowerCaseMinus;
      }
    } else if (stream.eatUpperCase()) {
      r = NAME;
      if (stream.matchMinus() >= 0) {
        status.tokenizer = inSetUpperCaseMinus;
      }
    } else if (stream.eatDigit()) {
      r = NAME;
      if (stream.matchMinus() >= 0) {
        status.tokenizer = inSetDigitMinus;
      }
    } else if (stream.next() >= 0) {
      r = NAME;
    } else {
      r = inText(stream, status);
    }
    return r;
  }
  
  inSetCharMaybeEmpty(stream, status) {
    var r;
    if (stream.eatCloseBracket()) {
      r = inText(stream, status);
    } else {
      r = inSet(stream, status);
    }
    return r;
  }
  
  inSetNegation(stream, status) {
    var r;
    if (stream.eatCircumflex()) {
      r = SYMBOL;
      status.tokenizer = inSet;
    } else {
      r = inSetCharMaybeEmpty(stream, status);
    }
    return r;
  }
  
  inSetMaybeEmpty(stream, status) {
    var r;
    if (stream.eatCloseBracket()) {
      r = inText(stream, status);
    } else {
      r = inSetNegation(stream, status);
    }
    return r;
  }
  
  inBody(stream, status) {
    var r;
    if (stream.eatSlash()) {
      r = SEPARATOR;
    } else if (stream.eatAsterisk()) {
      stream.eatAsterisk();
      r = SYMBOL;
    } else if (stream.eatQuestionMark()) {
      r = SYMBOL;
    } else if (stream.eatOpenBrace()) {
      status.tokenizer = inOptionalNameMaybeEmpty;
      r = SYMBOL;
    } else if (stream.eatOpenBracket()) {
      status.tokenizer = inSetMaybeEmpty;
      r = SYMBOL;
    } else {
      stream.eatUntil(isContextChar);
      r = NAME;
    }
    return r;
  }

  eatWindowsRoot(o) {
    return o.eatAlpha() && o.eatColon() && o.matchSlash() >= 0;
  }

  inWindowsRootSeparator(stream, status) {
    status.tokenizer = inBody;
    stream.eatSlash();
    return SEPARATOR;
  }
  
  inRoot(stream, status) {
    var r;
    status.tokenizer = inBody;
    if (stream.eatSlash()) {
      r = SEPARATOR;
    } else if (stream.maybeEat(eatWindowsRoot)) {
      r = SEPARATOR;
      status.tokenizer = inWindowsRootSeparator;
    } else {
      r = inBody(stream, status);
    }
    return r;
  }
  
  inText(stream, status) {
    stream.skipToEnd();
    status.tokenizer = inText;
    return TEXT;
  }
  
}




