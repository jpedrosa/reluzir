library HtmlLexer;

import "common.dart";


class HtmlLexer extends LexerCommon {
  
  HtmlLexer() {
    entryTokenizer = inOpenDoctype;
    defaultTokenizer = inText;
    spaceTokenizer = space;
  }

  static const TEXT = 0;
  static const KEYWORD = 1;
  static const VARIABLE = 2;
  static const SYMBOL = 3;
  static const STRING = 4;
  static const COMMENT = 5;
  static const DOCTYPE = 6;
  
  static keywordString(n) {
    var r;
    switch (n) {
      case 0:
        r = "text";
        break;
      case 1:
        r = "keyword";
        break;
      case 2:
        r = "variable";
        break;
      case 3:
        r = "symbol";
        break;
      case 4:
        r = "string";
        break;
      case 5:
        r = "comment";
        break;
      case 6:
        r = "doctype";
        break;
    }
    return r;
  }
  
  static const CLOSE_COMMENT_STR = "-->";
  static const DOCTYPE_STR_UPPER = "DOCTYPE";
  static const DOCTYPE_STR_LOWER = "doctype";
  
  inDoubleQuotedAttrValue(stream, status) {
    var r;
    if (stream.eatWhileNeitherThree(34, 60, 62)) { // " and < and >
      r = STRING;
    } else if (stream.eatDoubleQuote()) {
      r = STRING;
      status.tokenizer = inTag;
      status.spaceTokenizer = space;
    } else if (stream.eatGreaterThan()) {
      r = SYMBOL;
      status.tokenizer = inText;
      status.spaceTokenizer = space;
    } else {
      status.spaceTokenizer = space;
    }
    return r;
  }
  
  inSingleQuotedAttrValue(stream, status) {
    var r;
    if (stream.eatWhileNeitherThree(39, 60, 62)) { // ' and < and >
      r = STRING;
    } else if (stream.eatSingleQuote()) {
      r = STRING;
      status.tokenizer = inTag;
      status.spaceTokenizer = space;
    } else if (stream.eatGreaterThan()) {
      r = SYMBOL;
      status.tokenizer = inText;
      status.spaceTokenizer = space;
    } else {
      status.spaceTokenizer = space;
    }
    return r;
  }
  
  inAttrValue(stream, status) {
    var r;
    if (stream.eatDoubleQuote()) {
      r = STRING;
      status.spaceTokenizer = null;
      status.tokenizer = inDoubleQuotedAttrValue;
    } else if (stream.eatSingleQuote()) {
      r = STRING;
      status.spaceTokenizer = null;
      status.tokenizer = inSingleQuotedAttrValue;
    } else if (stream.eatWhileNeitherFive(34, 39, 60, 62, 32)) {
      // not one of these: " ' < > space
      r = STRING;
      status.tokenizer = inTag;
    }
    return r;
  }
  
  inAttr(stream, status) {
    var r;
    if (stream.eatEqual()) {
      r = SYMBOL;
      status.tokenizer = inAttrValue;
    }
    return r;
  }
  
  eatAttrName(o) {
    var i = o.currentIndex, s = o.text, c = s.codeUnitAt(i),
      r = (c >= 97 && c <= 122) || //a-z
          (c >= 65 && c <= 90) || //A-Z
          c == 95 || c == 58; // _ :
    if (r) {
      var len = o.lineEndIndex; 
      i++;
      while (i < len) {
        c = s.codeUnitAt(i);
        if ((c >= 97 && c <= 122) || //a-z
            (c >= 65 && c <= 90) || //A-Z
            (c >= 48 && c <= 57) || //0-9
            c == 95 || c == 58 || c == 45 || c == 46) { // _ : - .
          i++;
        } else {
          break;
        }
      }
      o.currentIndex = i;
    }
    return r;
  }
  
  inTag(stream, status) {
    var r;
    if (eatAttrName(stream)) { //stream.eatWhileAlpha()) {
      r = VARIABLE; // attr key
      status.tokenizer = inAttr;
    } else if (stream.eatGreaterThan()) {
      r = SYMBOL;
      status.tokenizer = inText;
    }
    return r;
  }
  
  eatTagName(o) => eatAttrName(o);
  
  inCloseTagName(stream, status) {
    var r;
    if (eatTagName(stream)) {
      r = KEYWORD; // tagName
    } else if (stream.eatGreaterThan()) {
      r = SYMBOL;
      status.tokenizer = inText;
    }
    return r;
  }
  
  closeTag(stream, status) {
    var r;
    if (stream.eatGreaterThan()) {
      r = SYMBOL;
      status.tokenizer = inText;
    }
    return r;
  }
  
  postTagName(stream, status) {
    var r;
    if (stream.eatSlash()) {
      r = SYMBOL;
      status.tokenizer = closeTag;
    } else {
      r = inTag(stream, status);
    }
    return r;
  }
  
  inTagName(stream, status) {
    var r;
    if (eatTagName(stream)) {
      r = KEYWORD; // tagName
      status.tokenizer = postTagName;
    } else if (stream.eatSlash()) {
      r = SYMBOL;
      status.tokenizer = inCloseTagName;
    }
    return r;
  }
  
  eatOpenComment(o) {
    return o.eatMinus() && o.eatMinus();
  }
  
  inCloseComment(stream, status) {
    stream.currentIndex += 3; // -->
    status.spaceTokenizer = space;
    status.tokenizer = inText;
    return COMMENT;
  }
  
  inComment(stream, status) {
    var r;
    if (stream.eatWhileNotString(CLOSE_COMMENT_STR)) { // -->
      r = COMMENT;
    } else {
      r = inCloseComment(stream, status);
    }
    return r;
  }
  
  inText(stream, status) {
    var r;
    if (stream.eatWhileNot(60)) { // <
      r = TEXT;
    } else if (stream.eatLessThan()) {
      r = SYMBOL;
      if (stream.eatExclamation()) {
        if (stream.maybeEat(eatOpenComment)) {
          r = COMMENT;
          status.spaceTokenizer = null;
          status.tokenizer = inComment;
        } else {
          stream.backUp(1);
        }
      } else {
        status.tokenizer = inTagName;
      }
    } else {
      stream.skipToEnd();
      r = TEXT;
    }
    return r;
  }
  
  eatOpenDoctype(o) {
    return o.eatLessThan() && o.eatExclamation() &&
        o.eatOnEitherString(DOCTYPE_STR_UPPER, DOCTYPE_STR_LOWER);
  }
  
  inDoctype(stream, status) {
    var r;
    if (stream.eatWhileNeitherTwo(60, 62)) {
      r = DOCTYPE;
    } else if (stream.eatGreaterThan()) {
      r = DOCTYPE;
      status.tokenizer = inText;
      status.spaceTokenizer = space;
    } else {
      status.spaceTokenizer = space;
    }
    return r;
  }
  
  inOpenDoctype(stream, status) {
    var r;
    if (stream.maybeEat(eatOpenDoctype)) {
      r = DOCTYPE;
      status.tokenizer = inDoctype;
      status.spaceTokenizer = null;
    } else {
      status.tokenizer = inText;
      r = inText(stream, status);
    }
    return r;
  }
  
  space(stream, status) {
    var r;
    if (stream.eatWhileSpace()) {
      r = TEXT;
    }
    return r;
  }
  
}




