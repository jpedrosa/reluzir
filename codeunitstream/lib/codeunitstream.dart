library CodeUnitStream;

import "../../str/lib/str.dart";
import "../../lang/lib/lang.dart";


class CodeUnitStream {
  
  var currentIndex, startIndex, _text, lineStartIndex, lineEndIndex,
    milestoneIndex = 0;
  
  CodeUnitStream({text: "", this.startIndex: 0,
      this.lineStartIndex: 0, this.lineEndIndex: 0}) {
    _text = text;
    currentIndex = startIndex;
    if (lineEndIndex == 0) {
      lineEndIndex = text.length;
    }
  }
  
  get text => _text;
  
  set text(s) {
    _text = s;
    currentIndex = 0;
    startIndex = 0;
    lineStartIndex = 0;
    lineEndIndex = s.length;
  }
  
  reset() {
    currentIndex = 0;
    startIndex = 0;
    lineStartIndex = 0;
    lineEndIndex = _text.length;
  }
  
  get isEol => currentIndex >= lineEndIndex;
  
  get isSol => currentIndex == lineStartIndex;
  
  peek() {
    return currentIndex < lineEndIndex ? _text.codeUnitAt(currentIndex) : -1;
  }
  
  next() {
    var r = -1;
    if (currentIndex < lineEndIndex) {
      r = _text.codeUnitAt(currentIndex);
      currentIndex++;
    }
    return r;
  }

  matchCodeUnit(c, [consume = false]) {
    var r = -1, i = currentIndex;
    if (i < lineEndIndex) {
      if (c == _text.codeUnitAt(i)) {
        r = c;
        if (consume) {
          currentIndex = i + 1;
        }
      }
    }
    return r;
  }

  matchRepeatedCodeUnit(c, [consume = false]) {
    var r = -1, i = currentIndex, savei = i, len = lineEndIndex, s = _text;
    while (i < len) {
      if (c != s.codeUnitAt(i)) {
        break;
      }
      i++;
    }
    if (i > savei) {
      r = i - savei;
      if (consume) {
        currentIndex = i;
      }
    }
    return r;
  }
  
  eat(c) {
    return matchCodeUnit(c) >= 0;
  }
  
  eatWhile(c) {
    return matchRepeatedCodeUnit(c) >= 0;
  }

  eatSpace() {
    return matchSpace(true) >= 0;
  }

  eatWhileSpace() {
    return matchSpaces(true) >= 0;
  }
  
  matchSpace([consume = false]) {
    var r = -1, i = currentIndex;
    if (i < lineEndIndex) {
      var c = _text.codeUnitAt(i);
      if (c == 32 || c == 160) { // space or \u00a0
        r = c;
        if (consume) {
          currentIndex = i + 1;
        }
      }
    }
    return r;
  }

  matchSpaces([consume = false]) {
    var r = -1, i = currentIndex, savei = i, len = lineEndIndex, c, s = _text;
    while (i < len) {
      c = s.codeUnitAt(i);
      if (c != 32 && c != 160) {
        break;
      }
      i++;
    }
    if (i > savei) {
      r = i - savei;
      if (consume) {
        currentIndex = i;
      }
    }
    return r;
  }
  
  skipToEnd() {
    currentIndex = lineEndIndex;
  }

  skipTo(c) {
    var r = Str.indexOfCodeUnit(_text, c, currentIndex);
    if (r >= lineStartIndex && r < lineEndIndex) {
      currentIndex = r;
    }
    return r;
  }
  
  backUp(n) {
    currentIndex -= n;
  }
  
  keepMilestoneIfNot(fn()) {
    var r = fn();
    if (!r) {
      milestoneIndex = currentIndex + 1;
    }
    return r;
  }

  yankMilestoneIfNot(fn()) {
    if (!fn()) {
      milestoneIndex = currentIndex + 1;
    }
    return false;
  }
  
  seekContext(fn(c)) {
    var r = -1, i = currentIndex, len = lineEndIndex, s = _text, c;
    while (i < len) {
      c = s.codeUnitAt(i);
      if (fn(c) >= 0) {
        r = c;
        currentIndex = i;
        startIndex = i;
        break;
      }
      i++;
    }
    return r;
  }
  
  maybeEat(fn(ctx)) {
    return maybeMatch(fn) >= 0;
  }
  
  maybeMatch(fn(ctx)) {
    var r = -1, savei = currentIndex;
    if (fn(this)) {
      r = currentIndex - savei;
    } else if (milestoneIndex > 0) {
      currentIndex = milestoneIndex;
      milestoneIndex = 0;
    } else {
      currentIndex = savei;
    }
    return r;
  }

  nestMatch(fn(ctx)) {
    var ctx = _cloneFromPool(this), r = -1, savei = currentIndex;
    if (fn(ctx)) {
      currentIndex = ctx.currentIndex;
      r = currentIndex - savei;
    } else if (ctx.milestoneIndex > 0) {
      currentIndex = ctx.milestoneIndex;
      ctx.milestoneIndex = 0;
    }
    _returnToPool(ctx);
    return r;
  }
  
  collectTokenString() {
    var s = currentTokenString;
    startIndex = currentIndex;
    return s;
  }
  
  static var _pool;
  
  static _returnToPool(o) {
    _pool.add(o);
  }
  
  static _cloneFromPool(po) {
    var o, a = _pool;
    if (a == null) {
      a = [];
      _pool = a;
    }
    if (a.length > 0) {
      o = a.removeLast();
      o._text = po._text;
      o.startIndex = po.startIndex;
      o.lineStartIndex = po.lineStartIndex;
      o.lineEndIndex = po.lineEndIndex;
      o.currentIndex = po.currentIndex;
    } else {
      o = new CodeUnitStream(text: po._text, startIndex: po.startIndex,
          lineStartIndex: po.lineStartIndex, lineEndIndex: po.lineEndIndex);
      o.currentIndex = po.currentIndex;
    }
    return o;
  }
  
  clone() {
    var o = new CodeUnitStream(text: _text, startIndex: startIndex,
      lineStartIndex: lineStartIndex, lineEndIndex: lineEndIndex);
    o.currentIndex = currentIndex;
    return o;
  }

  match(sequence, [consume = false]) {
    var r = false, seqLen = sequence, i = currentIndex, lasti = i + seqLen;
    if (lasti < lineEndIndex) {
      var s = _text, si = 0;
      r = true;
      for (; i <= lasti; i++) {
        if (s.codeUnitAt(i) != sequence[si]) {
          r = false;
          break;
        }
        si++;
      }
      if (r && consume) {
        currentIndex += seqLen;
      }
    }
    return r;
  }
  
  eatOnEitherSequence(list1, list2) {
    return matchOnEitherSequence(list1, list2, true) >= 0;
  }

  // Used for case insensitive matching
  matchOnEitherSequence(list1, list2, [consume = false]) {
    var r = -1, seqLen = list1.length, i = currentIndex;
    if (i + seqLen < lineEndIndex) {
      var s = _text, c, j;
      for (j = 0; j < seqLen; j++) {
        c = s.codeUnitAt(i + j);
        if (c != list1[j] && c != list2[j]) {
          break;
        }
      }
      if (j >= seqLen) {
        r = seqLen;
        if (consume) {
          currentIndex += seqLen;
        }
      }
    }
    return r;
  }

  eatWhileNotSequence(list) {
    return matchWhileNotSequence(list, true) >= 0;
  }
  
  matchWhileNotSequence(list, [consume = false]) {
    var r = -1, i = currentIndex, savei = i, seqLen = list.length,
      len = lineEndIndex - seqLen + 1, c, s = text, sfc = list[0], j;
    while (i < len) {
      c = s.codeUnitAt(i);
      if (c == sfc) {
        for (j = 1; j < seqLen; j++) {
          if (s.codeUnitAt(i + j) != list[j]) {
            i += j - 1;
            break;
          }
        }
        if (j >= seqLen) {
          break;
        }
      }
      i++;
    }
    if (i >= len) {
      i = lineEndIndex;
    }
    if (i > savei) {
      r = i - savei;
      if (consume) {
        currentIndex = i;
      }
    }
    return r;
  }
  
  eatWhileNot(c) {
    return matchWhileNot(c, true) >= 0;
  }
  
  matchWhileNot(mc, [consume = false]) {
    var r = -1, i = currentIndex, savei = i, len = lineEndIndex, c, s = text;
    while (i < len) {
      c = s.codeUnitAt(i);
      if (c == mc) {
        break;
      }
      i++;
    }
    if (i > savei) {
      r = i - savei;
      if (consume) {
        currentIndex = i;
      }
    }
    return r;
  }
  
  eatWhileNeitherTwo(c1, c2) {
    return matchWhileNeitherTwo(c1, c2, true) >= 0;
  }
  
  matchWhileNeitherTwo(c1, c2, [consume = false]) {
    var r = -1, i = currentIndex, savei = i, len = lineEndIndex, c, s = text;
    while (i < len) {
      c = s.codeUnitAt(i);
      if (c == c1 || c == c2) {
        break;
      }
      i++;
    }
    if (i > savei) {
      r = i - savei;
      if (consume) {
        currentIndex = i;
      }
    }
    return r;
  }
  
  eatWhileNeitherThree(c1, c2, c3) {
    return matchWhileNeitherThree(c1, c2, c3, true) >= 0;
  }
  
  matchWhileNeitherThree(c1, c2, c3, [consume = false]) {
    var r = -1, i = currentIndex, savei = i, len = lineEndIndex, c, s = text;
    while (i < len) {
      c = s.codeUnitAt(i);
      if (c == c1 || c == c2 || c == c3) {
        break;
      }
      i++;
    }
    if (i > savei) {
      r = i - savei;
      if (consume) {
        currentIndex = i;
      }
    }
    return r;
  }

  eatWhileNeitherFour(c1, c2, c3, c4) {
    return matchWhileNeitherFour(c1, c2, c3, c4, true) >= 0;
  }
  
  matchWhileNeitherFour(c1, c2, c3, c4, [consume = false]) {
    var r = -1, i = currentIndex, savei = i, len = lineEndIndex, c, s = text;
    while (i < len) {
      c = s.codeUnitAt(i);
      if (c == c1 || c == c2 || c == c3 || c == c4) {
        break;
      }
      i++;
    }
    if (i > savei) {
      r = i - savei;
      if (consume) {
        currentIndex = i;
      }
    }
    return r;
  }
  
  get currentToken => text.substring(startIndex, currentIndex).codeUnits;

  get currentTokenString => text.substring(startIndex, currentIndex);
  
  // More specialization

  eatDigit() {
    return matchDigit(true) >= 0;
  }
  
  eatWhileDigit() {
    return matchWhileDigit(true) >= 0;
  }

  matchDigit([consume = false]) {
    var r = -1, i = currentIndex;
    if (i < lineEndIndex) {
      var c = text.codeUnitAt(i);
      if (c >= 48 && c <= 57) {
        r = c;
        if (consume) {
          currentIndex = i + 1;
        }
      }
    }
    return r;
  }

  matchWhileDigit([consume = false]) {
    var r = -1, i = currentIndex, savei = i, len = lineEndIndex, c, s = text;
    while (i < len) {
      c = s.codeUnitAt(i);
      if (c < 48 || c > 57) {
        break;
      }
      i++;
    }
    if (i > savei) {
      r = i - savei;
      if (consume) {
        currentIndex = i;
      }
    }
    return r;
  }

  eatLowerCase() {
    return matchLowerCase(true) >= 0;
  }
  
  eatLowerCases() {
    return matchWhileLowerCase(true) >= 0;
  }
  
  // a-z
  matchLowerCase([consume = false]) {
    var r = -1, i = currentIndex;
    if (i < lineEndIndex) {
      var c = text.codeUnitAt(i); 
      if (c >= 97 && c <= 122) { // a-z
        r = c;
        if (consume) {
          currentIndex = i + 1;
        }
      }
    }
    return r;
  }

  matchWhileLowerCase([consume = false]) {
    var r = -1, i = currentIndex, savei = i, len = lineEndIndex, c, s = text;
    while (i < len) {
      c = s.codeUnitAt(i);
      if (c < 97 || c > 122) {
        break;
      }
      i++;
    }
    if (i > savei) {
      r = i - savei;
      if (consume) {
        currentIndex = i;
      }
    }
    return r;
  }

  eatUpperCase() {
    return matchUpperCase(true) >= 0;
  }
  
  eatWhileUpperCase() {
    return matchWhileUpperCase(true) >= 0;
  }
  
  // A-Z
  matchUpperCase([consume = false]) {
    var r = -1, i = currentIndex;
    if (i < lineEndIndex) {
      var c = text.codeUnitAt(i); 
      if (c >= 65 && c <= 90) { // A-Z
        r = c;
        if (consume) {
          currentIndex = i + 1;
        }
      }
    }
    return r;
  }

  matchWhileUpperCase([consume = false]) {
    var r = -1, i = currentIndex, savei = i, len = lineEndIndex, c, s = text;
    while (i < len) {
      c = s.codeUnitAt(i);
      if (c < 65 || c > 90) {
        break;
      }
      i++;
    }
    if (i > savei) {
      r = i - savei;
      if (consume) {
        currentIndex = i;
      }
    }
    return r;
  }

  eatAlpha() {
    return matchAlpha(true) >= 0;
  }
  
  eatWhileAlpha() {
    return matchWhileAlpha(true) >= 0;
  }
  
  // A-Z a-z
  matchAlpha([consume = false]) {
    var r = -1, i = currentIndex;
    if (i < lineEndIndex) {
      var c = text.codeUnitAt(i); 
      if ((c >= 65 && c <= 90) || (c >= 97 && c <= 122)) { // A-Z a-z
        r = c;
        if (consume) {
          currentIndex = i + 1;
        }
      }
    }
    return r;
  }
  
  matchWhileAlpha([consume = false]) {
    var r = -1, i = currentIndex, savei = i, len = lineEndIndex, c, s = text;
    while (i < len) {
      c = s.codeUnitAt(i);
      if ((c >= 65 && c <= 90) || (c >= 97 && c <= 122)) {
        // ignore
      } else {
        break;
      }
      i++;
    }
    if (i > savei) {
      r = i - savei;
      if (consume) {
        currentIndex = i;
      }
    }
    return r;
  }

  eatAlphaUnderline() {
    return matchAlphaUnderline(true) >= 0;
  }
  
  eatWhileAlphaUnderline() {
    return matchWhileAlphaUnderline(true) >= 0;
  }
  
  // A-Z a-z _
  matchAlphaUnderline([consume = false]) {
    var r = -1, i = currentIndex;
    if (i < lineEndIndex) {
      var c = _text.codeUnitAt(i); // A-Z a-z _
      if ((c >= 65 && c <= 90) || (c >= 97 && c <= 122) || c == 95) {
        r = c;
        if (consume) {
          currentIndex = i + 1;
        }
      }
    }
    return r;
  }
  
  matchWhileAlphaUnderline([consume = false]) {
    var r = -1, i = currentIndex, savei = i, len = lineEndIndex, c, s = _text;
    while (i < len) {
      c = s.codeUnitAt(i);
      if ((c >= 65 && c <= 90) || (c >= 97 && c <= 122) || c == 95) {
        // ignore
      } else {
        break;
      }
      i++;
    }
    if (i > savei) {
      r = i - savei;
      if (consume) {
        currentIndex = i;
      }
    }
    return r;
  }

  eatAlphaUnderlineDigit() {
    return matchAlphaUnderlineDigit(true) >= 0;
  }
  
  eatWhileAlphaUnderlineDigit() {
    return matchWhileAlphaUnderlineDigit(true) >= 0;
  }
  
  // A-Z a-z _ 0-9
  matchAlphaUnderlineDigit([consume = false]) {
    var r = -1, i = currentIndex;
    if (i < lineEndIndex) {
      var c = _text.codeUnitAt(i); // A-Z a-z _ 0-9
      if ((c >= 65 && c <= 90) || (c >= 97 && c <= 122) || c == 95 ||
          (c >= 48 && c <= 57)) {
        r = c;
        if (consume) {
          currentIndex = i + 1;
        }
      }
    }
    return r;
  }
  
  matchWhileAlphaUnderlineDigit([consume = false]) {
    var r = -1, i = currentIndex, savei = i, len = lineEndIndex, c, s = _text;
    while (i < len) {
      c = s.codeUnitAt(i);
      if ((c >= 65 && c <= 90) || (c >= 97 && c <= 122) || c == 95 ||
          (c >= 48 && c <= 57)) {
        // ignore
      } else {
        break;
      }
      i++;
    }
    if (i > savei) {
      r = i - savei;
      if (consume) {
        currentIndex = i;
      }
    }
    return r;
  }

  eatAlphaDigit() {
    return matchAlphaDigit(true) >= 0;
  }
  
  eatWhileAlphaDigit() {
    return matchWhileAlphaDigit(true) >= 0;
  }
  
  // A-Z a-z 0-9
  matchAlphaDigit([consume = false]) {
    var r = -1, i = currentIndex;
    if (i < lineEndIndex) {
      var c = _text.codeUnitAt(i); // A-Z a-z 0-9
      if ((c >= 65 && c <= 90) || (c >= 97 && c <= 122) ||
          (c >= 48 && c <= 57)) {
        r = c;
        if (consume) {
          currentIndex = i + 1;
        }
      }
    }
    return r;
  }
  
  matchWhileAlphaDigit([consume = false]) {
    var r = -1, i = currentIndex, savei = i, len = lineEndIndex, c, s = _text;
    while (i < len) {
      c = s.codeUnitAt(i);
      if ((c >= 65 && c <= 90) || (c >= 97 && c <= 122) ||
          (c >= 48 && c <= 57)) {
        // ignore
      } else {
        break;
      }
      i++;
    }
    if (i > savei) {
      r = i - savei;
      if (consume) {
        currentIndex = i;
      }
    }
    return r;
  }

  eatHexDigit() {
    return matchHexDigit(true) >= 0;
  }
  
  eatWhileHexDigit() {
    return matchWhileHexDigit(true) >= 0;
  }
  
  // A-F a-f 0-9
  matchHexDigit([consume = false]) {
    var r = -1, i = currentIndex;
    if (i < lineEndIndex) {
      var c = _text.codeUnitAt(i); // A-F a-f 0-9
      if ((c >= 65 && c <= 70) || (c >= 97 && c <= 102) ||
          (c >= 48 && c <= 57)) {
        r = c;
        if (consume) {
          currentIndex = i + 1;
        }
      }
    }
    return r;
  }
  
  matchWhileHexDigit([consume = false]) {
    var r = -1, i = currentIndex, savei = i, len = lineEndIndex, c, s = _text;
    while (i < len) {
      c = s.codeUnitAt(i);
      if ((c >= 65 && c <= 70) || (c >= 97 && c <= 102) ||
          (c >= 48 && c <= 57)) {
        // ignore
      } else {
        break;
      }
      i++;
    }
    if (i > savei) {
      r = i - savei;
      if (consume) {
        currentIndex = i;
      }
    }
    return r;
  }

  // One-off symbols

  eatOpenParen() {
    return matchOpenParen(true) >= 0;
  }
  
  // (
  matchOpenParen([consume = false]) {
    return matchCodeUnit(40, consume); // (
  }

  eatCloseParen() {
    return matchCloseParen(true) >= 0;
  }
  
  // )
  matchCloseParen([consume = false]) {
    return matchCodeUnit(41, consume); // )
  }

  eatLessThan() {
    return matchLessThan(true) >= 0;
  }
  
  // <
  matchLessThan([consume = false]) {
    return matchCodeUnit(60, consume); // <
  }

  eatGreaterThan() {
    return matchGreaterThan(true) >= 0;
  }
  
  // >
  matchGreaterThan([consume = false]) {
    return matchCodeUnit(62, consume); // >
  }

  eatOpenBracket() {
    return matchOpenBracket(true) >= 0;
  }
  
  // [
  matchOpenBracket([consume = false]) {
    return matchCodeUnit(91, consume); // [
  }

  eatCloseBracket() {
    return matchCloseBracket(true) >= 0;
  }
  
  // ]
  matchCloseBracket([consume = false]) {
    return matchCodeUnit(93, consume); // ]
  }

  eatOpenBrace() {
    return matchOpenBrace(true) >= 0;
  }
  
  // {
  matchOpenBrace([consume = false]) {
    return matchCodeUnit(123, consume); // {
  }

  eatCloseBrace() {
    return matchCloseBrace(true) >= 0;
  }
  
  // }
  matchCloseBrace([consume = false]) {
    return matchCodeUnit(125, consume); // }
  }

  eatEqual() {
    return matchEqual(true) >= 0;
  }
  
  // =
  matchEqual([consume = false]) {
    return matchCodeUnit(61, consume); // =
  }
  
  eatPlus() {
    return matchPlus(true) >= 0;
  }
  
  // +
  matchPlus([consume = false]) {
    return matchCodeUnit(43, consume); // +
  }
  
  eatMinus() {
    return matchMinus(true) >= 0;
  }
  
  // -
  matchMinus([consume = false]) {
    return matchCodeUnit(45, consume); // -
  }
  
  eatExclamation() {
    return matchExclamation(true) >= 0;
  }
  
  // !
  matchExclamation([consume = false]) {
    return matchCodeUnit(33, consume); // !
  }
  
  eatQuotation() {
    return matchQuotation(true) >= 0;
  }
  
  // ?
  matchQuotation([consume = false]) {
    return matchCodeUnit(63, consume); // ?
  }
  
  eatAmpersand() {
    return matchAmpersand(true) >= 0;
  }
  
  // &
  matchAmpersand([consume = false]) {
    return matchCodeUnit(38, consume); // &
  }
  
  eatSemicolon() {
    return matchSemicolon(true) >= 0;
  }
  
  // ;
  matchSemicolon([consume = false]) {
    return matchCodeUnit(59, consume); // ;
  }
  
  eatColon() {
    return matchColon(true) >= 0;
  }
  
  // :
  matchColon([consume = false]) {
    return matchCodeUnit(58, consume); // :
  }
  
  eatPoint() {
    return matchPoint(true) >= 0;
  }
  
  // .
  matchPoint([consume = false]) {
    return matchCodeUnit(46, consume); // .
  }
  
  eatComma() {
    return matchComma(true) >= 0;
  }
  
  // ,
  matchComma([consume = false]) {
    return matchCodeUnit(44, consume); // ,
  }
  
  eatAsterisk() {
    return matchAsterisk(true) >= 0;
  }
  
  // *
  matchAsterisk([consume = false]) {
    return matchCodeUnit(42, consume); // *
  }
  
  eatSlash() {
    return matchSlash(true) >= 0;
  }
  
  // /
  matchSlash([consume = false]) {
    return matchCodeUnit(47, consume); // /
  }
  
  eatBackslash() {
    return matchBackslash(true) >= 0;
  }
  
  // \
  matchBackslash([consume = false]) {
    return matchCodeUnit(92, consume); // \
  }
  
  eatAt() {
    return matchAt(true) >= 0;
  }
  
  // @
  matchAt([consume = false]) {
    return matchCodeUnit(64, consume); // @
  }
  
  eatTilde() {
    return matchTilde(true) >= 0;
  }
  
  // ~
  matchTilde([consume = false]) {
    return matchCodeUnit(126, consume); // ~
  }
  
  eatUnderline() {
    return matchUnderline(true) >= 0;
  }
  
  // _
  matchUnderline([consume = false]) {
    return matchCodeUnit(95, consume); // _
  }
  
  eatPercent() {
    return matchPercent(true) >= 0;
  }
  
  // %
  matchPercent([consume = false]) {
    return matchCodeUnit(37, consume); // %
  }
  
  eatDollar() {
    return matchDollar(true) >= 0;
  }
  
  // $
  matchDollar([consume = false]) {
    return matchCodeUnit(36, consume); // $
  }
  
  eatSingleQuote() {
    return matchSingleQuote(true) >= 0;
  }
  
  // '
  matchSingleQuote([consume = false]) {
    return matchCodeUnit(39, consume); // '
  }
  
  eatDoubleQuote() {
    return matchDoubleQuote(true) >= 0;
  }
  
  // "
  matchDoubleQuote([consume = false]) {
    return matchCodeUnit(34, consume); // "
  }
  
  eatHash() {
    return matchHash(true) >= 0;
  }
  
  // #
  matchHash([consume = false]) {
    return matchCodeUnit(35, consume); // #
  }
  
  eatPipe() {
    return matchPipe(true) >= 0;
  }
  
  // |
  matchPipe([consume = false]) {
    return matchCodeUnit(124, consume); // |
  }
  
  toString() {
    return "CodeUnitStream(currentIndex: ${currentIndex}, "
      "startIndex: ${startIndex}, text: ${_text}, "
      "lineStartIndex: ${lineStartIndex}, lineEndIndex: ${lineEndIndex})";
  }
  
}





