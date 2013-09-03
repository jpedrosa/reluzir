library Lexer;

import "../../codeunitstream/lib/codeunitstream.dart";
import "../../str/lib/str.dart";
import "../../lang/lib/lang.dart";


class LexerStatus {
  
  var tokenizer, spaceTokenizer, commentTokenizer, stored;
  
  LexerStatus({this.tokenizer, this.spaceTokenizer, this.commentTokenizer}) {
    stored = [];
  }
  
  clone() {
    var o = new LexerStatus(tokenizer: tokenizer,
      spaceTokenizer: spaceTokenizer,
      commentTokenizer: commentTokenizer),
      len = stored.length;
    if (len > 0) {
      var a = o.stored, i;
      for (i = 0; i < len; i++) {
        a.add(stored[i]);
      }
    }
    return o;
  }
  
  push(t) {
    stored.add(t);
  }
  
  pop() => stored.removeLast();
  
  unshift(e) {
    stored.insert(0, e);
  }
  
  shift() {
    var e = stored[0];
    stored.removeAt(0);
    return e;
  }
  
  operator == (other) {
    var space = spaceTokenizer, otherSpace = other.spaceTokenizer,
      comment = commentTokenizer, otherComment = other.commentTokenizer,
      a = stored, otherA = other.stored;
    return tokenizer.toString() == other.tokenizer.toString() &&
      ((space == null && otherSpace == null) || (space != null &&
      otherSpace != null && space.toString() == otherSpace.toString())) &&
      ((comment == null && otherComment == null) || (comment != null &&
      otherComment != null &&
      comment.toString() == otherComment.toString())) &&
      (a.length == otherA.length && a.toString() == otherA.toString());
  }
  
  get hashCode => "LexerStatus(tokenizer: ${tokenizer}, "
      "spaceTokenizer: ${spaceTokenizer}, "
      "commentTokenizer: ${commentTokenizer}, "
      "stored: ${stored.toString()})".hashCode;
  
  toString() {
    return "LexerStatus(tokenizer: ${tokenizer}, "
        "spaceTokenizer: ${spaceTokenizer}, "
        "commentTokenizer: ${commentTokenizer}, "
        "stored: ${inspect(stored)})";
  }
  
}


class LexerCommon {
  
  var entryTokenizer, defaultTokenizer, spaceTokenizer,
    commentTokenizer;

  parseLine(stream, status, resultFn(tokenType)) {
    var tt;
    while (!stream.isEol) {
      tt = null;
      if (status.spaceTokenizer != null) {
        tt = status.spaceTokenizer(stream, status);
      }
      if (tt == null && status.commentTokenizer != null) {
        tt = status.commentTokenizer(stream, status);
      }
      if (tt == null) {
        tt = status.tokenizer(stream, status);
        if (tt == null) {
          status.tokenizer = defaultTokenizer;
          tt = defaultTokenizer(stream, status);
        }
      }
      //p([stream.currentTokenString, status.tokenizer]);
      //p(status.stored);
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
      if (i - si > 0) {
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
    return new LexerStatus(tokenizer: this.entryTokenizer,
        spaceTokenizer: this.spaceTokenizer,
        commentTokenizer: this.commentTokenizer);
  }
  
}


