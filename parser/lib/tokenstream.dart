library TokenStream;

import "../../codeunitstream/lib/codeunitstream.dart";
import "../../lang/lib/lang.dart";


class TokenStream {
  
  var _stream, types, strings, startIndexes, endIndexes, currentIndex = 0,
    lastIndex = -1, startIndex = 0;
  
  TokenStream({this.types, this.strings, this.startIndexes,
      this.endIndexes, currentIndex: 0, this.lastIndex: -1, 
      this.startIndex: 0}) {
    _stream = new CodeUnitStream();
    if (lastIndex < 0) {
      lastIndex = types.length - 1;
    }
  }
  
  get isEos => currentIndex > lastIndex;

  get isBos => currentIndex == 0;
  
  get tokenType => currentIndex <= lastIndex ? types[currentIndex] : -1;

  get tokenString => currentIndex <= lastIndex ? strings[currentIndex] : null;
  
  match(n) {
    var r = false, i = currentIndex;
    if (i <= lastIndex && types[i] == n) {
      r = true;
    }
    return r;
  }

  matchString(s) {
    var r = false, i = currentIndex;
    if (i <= lastIndex && strings[i] == s) {
      r = true;
    }
    return r;
  }
  
  matchLeft(fn(ctx)) {
    var r = false, i = currentIndex;
    if (i > 0) {
      currentIndex = i - 1;
      r = fn(this);
      currentIndex = i;
    }
    return r;
  }

  matchRight(fn(ctx)) {
    var r = false, i = currentIndex;
    if (i < lastIndex) {
      currentIndex = i + 1;
      r = fn(this);
      currentIndex = i;
    }
    return r;
  }
  
  joinTokenStrings(startIndex, endIndex, [separator = ""]) {
    return strings.sublist(startIndex, endIndex).join(separator);
  }
  
  get stream {
    _stream.text = currentIndex <= lastIndex ? strings[currentIndex] : "";
    return _stream;
  }
  
  toString() {
    return "TokenStream(currentIndex: ${currentIndex}, "
      "lastIndex: ${lastIndex}, types: ${inspect(types)}, "
      "startIndexes: ${startIndexes}, endIndexes: ${inspect(endIndexes)}, "
      "startIndex: ${startIndex}, stream: ${inspect(stream)})";
  }
  
}


