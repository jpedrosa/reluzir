library CssLexer;

import "common.dart";
import "../../lang/lib/lang.dart";


class CssLexer extends LexerCommon {
  
  CssLexer() {
    entryTokenizer = inOpenImportBlock;
    defaultTokenizer = inText;
    spaceTokenizer = space;
    commentTokenizer = comment;
  }

  static const TEXT = 0;
  static const KEYWORD = 1;
  static const VARIABLE = 2;
  static const SYMBOL = 3;
  static const STRING = 4;
  static const COMMENT = 5;
  static const HEXA = 6;
  static const NUMBER = 7;
  
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
        r = "hexa";
        break;
      case 7:
        r = "number";
        break;
    }
    return r;
  }

  static const OPEN_COMMENT_STR = "/*";
  static const CLOSE_COMMENT_STR = "*/";
  static const IMPORT_STR_UPPER = "IMPORT";
  static const IMPORT_STR_LOWER = "import";
  static const URL_STR_UPPER = "URL";
  static const URL_STR_LOWER = "url";
  
  inComment(stream, status) {
    if (stream.eatWhileNotString(CLOSE_COMMENT_STR)) {
      // ignore
    } else {
      stream.currentIndex += 2; // */
      status.tokenizer = status.saveTokenizer;
      status.spaceTokenizer = space;
    }
    return COMMENT;
  }
  
  eatIdentifier(o) {
    var r = o.eatAlphaUnderline() || 
      (o.eatMinus() && o.eatAlphaUnderline());
    if (r) {
      o.eatWhileAlphaUnderlineDigitMinus();
    }
    return r;
  }
  
  // Disambiguate in case of matches like the following:
  // @media { .example:before { font-family: serif } }
  isColonOfSelection(stream) {
    var r = stream.maybeMatch((o) {
      var b = false;
      if (o.currentIndex > 0) {
        o.backUp(1);
        b = o.eatAlphaUnderlineDigitMinus() && o.eatColon() && o.eatAlpha();
      }
      return b;
      });
    return r >= 0;
  }

  inAtRuleBlock(stream, status) {
    var r;
    if (!isColonOfSelection(stream)) {
      r = clearValueBlock(stream, status, inAtRuleBlock);
    }
    if (r != null) {
      // ignore
    } else if (stream.eatWhileNeitherFour(123, 125, 58, 47)) { // { } : /
      r = TEXT;
    } else {
      r = clearRuleBlock(stream, status, inAtRuleBlock);
      if (r != null) {
        // ignore
      } else if (stream.eatCloseBrace()) {
        status.tokenizer = inText;
        r = SYMBOL;
      } else {
        stream.skipToEnd();
        r = TEXT;
      }
    }
    return r;
  }
  
  eatNumber(o) {
    var r = o.eatDigit();
    if (!r) {
      if (o.eatMinus()) {
        r = o.eatDigit();
      }
      if (!r && o.eatPoint()) {
        r = o.eatDigit();
      }
    }
    if (r) {
      o.eatWhileDigit();
      if (o.eatPoint()) {
        if (o.eatWhileDigit()) {
          o.eatPercent() || o.eatWhileAlpha();
        } else {
          o.backUp(1);
        }
      } else {
        o.eatPercent() || o.eatWhileAlpha();
      }
    }
    return r;
  }
  
  eatHexa(o) {
    var r = o.eatHash() && o.eatHexa();
    if (r) {
      o.eatHexa() && o.eatHexa() && o.eatHexa() &&
      o.eatHexa() && o.eatHexa();
    }
    return r;
  }
  
  specialValue(c) {
    var r = -1;
    if (c >= 48 && c <= 57) {
      r = c;
    } else {
      switch (c) {
        case 34: // '
        case 35: // #
        case 39: // "
        case 45: // -
        case 46: // .
        case 47: // /
        case 59: // ;
        case 85: // U
        case 117: // u
        case 125: // }
          r = c;
          break;
      }
    }
    return r;
  }

  inValueBlock(stream, status) {
    var r = clearString(stream, status, inValueBlock);
    if (r != null) {
      // ignore
    } else if (stream.eatUntil(specialValue)) {
      r = TEXT;
    } else {
      r = clearUrl(stream, status, inValueBlock, inValueBlock);
      if (r != null) {
        // ignore
      } else if (stream.eatSemicolon()) {
        r = SYMBOL;
        status.tokenizer = status.pop();
      } else if (stream.matchCloseBrace() >= 0) {
        status.tokenizer = status.pop();
        r = status.tokenizer(stream, status); 
      } else if (stream.maybeEat(eatHexa)) {
        r = HEXA;
      } else if (stream.maybeEat(eatNumber)) {
        r = NUMBER;
      } else {
        stream.next();
        r = TEXT;
      }
    }
    return r;
  }
  
  clearValueBlock(stream, status, outTokenizer) {
    var r;
    if (stream.eatColon()) {
      status.push(outTokenizer);
      status.tokenizer = inValueBlock;
      r = SYMBOL;
    }
    return r;
  }
  
  inVariableBlock(stream, status) {
    var r = clearValueBlock(stream, status, inRuleBlock);
    if (r == null) {
      status.tokenizer = inRuleBlock;
      r = inRuleBlock(stream, status);
    }
    return r;
  }
  
  inRuleBlock(stream, status) {
    var r;
    if (stream.eatCloseBrace()) {
      status.tokenizer = status.pop();
      r = SYMBOL;
    } else if (eatIdentifier(stream)) {
      status.tokenizer = inVariableBlock;
      r = VARIABLE;
    } else {
      status.tokenizer = status.pop();
      r = status.tokenizer(stream, status);
    }
    return r;
  }
  
  clearRuleBlock(stream, status, outTokenizer) {
    var r;
    if (stream.eatOpenBrace()) {
      status.push(outTokenizer);
      status.tokenizer = inRuleBlock;
      r = SYMBOL;
    }
    return r;
  }
  
  inAtRule(stream, status) {
    var r;
    if (stream.eatWhileNeitherThree(123, 59, 47)) { // { ; /
      r = TEXT;
    } else if (stream.eatOpenBrace()) {
      status.tokenizer = inAtRuleBlock;
      r = SYMBOL;
    } else if (stream.eatSemicolon()) {
      status.tokenizer = inText;
      r = SYMBOL;
    } else {
      stream.skipToEnd();
      r = TEXT;
    }
    return r;
  }
  
  eatAtRule(o) {
    return o.eatAt() && eatIdentifier(o);
  }
  
  clearComment(stream, status, outTokenizer) {
    var r;
    if (stream.eatString(OPEN_COMMENT_STR)) {
      r = COMMENT;
      status.saveTokenizer = outTokenizer;
      status.spaceTokenizer = null;
      status.tokenizer = inComment;
    }
    return r;
  }
  
  inText(stream, status) {
    var r = clearString(stream, status, inText);
    if (r != null) {
      // ignore
    } else if (stream.maybeEat(eatAtRule)) {
      status.tokenizer = inAtRule;
      r = KEYWORD;
    } else if (stream.eatWhileNeitherFour(123, 47, 34, 39)) { // { / " '
      r = TEXT;
    } else {
      r = clearRuleBlock(stream, status, inText);
      if (r == null) {
        stream.skipToEnd();
        r = TEXT;
      }
    }
    return r;
  }
  
  eatAtImport(o) {
    var b = o.eatAt() && o.eatOnEitherString(IMPORT_STR_UPPER,
      IMPORT_STR_LOWER);
    if (o.matchAlphaUnderlineDigitMinus() >= 0) {
      b = false;
    }
    return b;
  }

  clearString(stream, status, outTokenizer) {
    var r;
    if (stream.eatInEscapedQuotes(34) || // "
        stream.eatInEscapedQuotes(39)) { // '
      status.tokenizer = outTokenizer;
      r = STRING;
    }
    return r;
  }
  
  inUrlOpenString(stream, status) {
    var r = clearString(stream, status, inUrlCloseParen);
    if (r == null) {
      // " ' ( ) \ space 
      if (stream.eatWhileNeitherSix(34, 39, 40, 41, 92, 32)) {
        status.tokenizer = inUrlCloseParen;
        r = STRING;
      } else {
        r = inUrlCloseParen(stream, status);
      }
    }
    return r;
  }

  inUrlCloseParen(stream, status) {
    var r;
    if (stream.eatCloseParen()) {
      r = SYMBOL;
    }
    return exitUrl(stream, status, r);
  }
  
  inUrlOpenParen(stream, status) {
    var r;
    if (stream.eatOpenParen()) {
      status.tokenizer = inUrlOpenString;
      r = SYMBOL;
    } else {
      r = exitUrl(stream, status, r);
    }
    return r;
  }

  eatOpenUrl(o) {
    var b = o.eatOnEitherString(URL_STR_UPPER, URL_STR_LOWER);
    if (o.matchAlphaUnderlineDigitMinus() >= 0) {
      b = false;
    }
    return b;
  }

  inImportAfterUrlComma(stream, status) {
    var r;
    if (stream.eatComma()) {
      status.tokenizer = inImportAfterUrl;
      r = SYMBOL;
    } else if (stream.eatSemicolon()) {
      status.tokenizer = inOpenImportBlock;
      r = SYMBOL;
    } else {
      status.tokenizer = inText;
      r = inText(stream, status);
    }
    return r;
  }
  
  inImportAfterUrl(stream, status) {
    var r;
    if (stream.eatSemicolon()) {
      status.tokenizer = inOpenImportBlock;
      r = SYMBOL;
    } else if (stream.maybeEat(eatIdentifier)) {
      status.tokenizer = inImportAfterUrlComma;
      r = TEXT;
    } else {
      status.tokenizer = inText;
      r = inText(stream, status);
    }
    return r;
  }
  
  exitUrl(stream, status, result) {
    var r = result, outTokenizerBad = status.pop(), 
      outTokenizerGood = status.pop();
    if (r != null) {
      status.tokenizer = outTokenizerGood;
    } else {
      status.tokenizer = outTokenizerBad;
      r = outTokenizerBad(stream, status);
    }
    return r;
  }
  
  clearUrl(stream, status, outTokenizerGood, outTokenizerBad) {
    var r;
    if (stream.maybeEat(eatOpenUrl)) {
      status.push(outTokenizerGood);
      status.push(outTokenizerBad);
      status.tokenizer = inUrlOpenParen;
      r = KEYWORD;
    }
    return r;
  }
  
  inImportBlock(stream, status) {
    var r = clearUrl(stream, status, inImportAfterUrl, inText);
    if (r == null) {
      r = clearString(stream, status, inImportAfterUrl);
    }
    if (r == null) {
      status.tokenizer = inText;
      r = inText(stream, status);
    }
    return r;
  }
  
  inOpenImportBlock(stream, status) {
    var r;
    if (stream.maybeEat(eatAtImport)) {
      status.tokenizer = inImportBlock;
      r = KEYWORD;
    } else {
      status.tokenizer = inText;
      r = inText(stream, status);
    }
    return r;
  }
  
  space(stream, status) {
    var r;
    if (stream.eatWhileSpaceTab()) {
      r = TEXT;
    }
    return r;
  }
  
  comment(stream, status) {
    return clearComment(stream, status, status.tokenizer);
  }
  
}




