library CodeUnitMatcher;

import 'codeunitstream.dart';
import "../../lang/lib/lang.dart";


class CodeUnitMatcher {
  
  var stream, list, _retryAware = false, _retryAtPartialSuccess = false;
  
  CodeUnitMatcher() {
    stream = new CodeUnitStream();
    list = [];
  }
  
  match(s) {
    return matchAt(s, 0);
  }

  matchAt(s, startIndex) {
    var i, a = list, len = a.length, r = -1, retry = false, b;
    stream.text = s;
    stream.startIndex = startIndex;
    stream.currentIndex = startIndex;
    if (_retryAware) {
      _retryAtPartialSuccess = false;
      b = doMatchWithRetry();
    } else {
      b = doMatch();
    }
    if (b) {
      r = stream.currentIndex - startIndex;
    }
    return r;
  }
  
  doMatch() {
    var i, a = list, len = a.length;
    for (i = 0; i < len; i += 3) {
      if (!a[i + 1]() && !a[i + 2]) { // No success and not optional.
        break;
      }
    }
    return i >= len;
  }
  
  doMatchWithRetry() {
    var i, a = list, len = a.length, retry = false;
    for (i = 0; i < len; i += 3) {
      if (!a[i + 1]() && !a[i + 2]) { // No success and not optional.
        break;
      } else if (_retryAtPartialSuccess) {
        retry = true;
        break;
      }
    }
    if (retry) { // retryAtPartialSuccess
      i += 3;
      var savei = i, ci = -1;
      while (true) {
        for (; i < len; i += 3) {
          if (!a[i + 1]()) { // No success.
            if (!a[i + 2]) { // Not optional.
              break;
            }
          } else if (ci < 0) {
            ci = stream.currentIndex;
          }
        }
        if (i < len && ci >= 0) {
          i = savei;
          stream.currentIndex = ci;
          ci = -1;
        } else {
          break;
        }
      }
    }
    return i >= len;
  }

  add(namedClosure, anonFnWithParams, [optional = false]) {
    list.add(namedClosure);
    list.add(anonFnWithParams);
    list.add(optional);
  }
  
  eatWhileDigit([optional = false]) {
    add("eatWhileDigit", stream.eatWhileDigit, optional);
  }
  
  eatUntilString(s, [optional = false]) {
    add("eatUntilString(s: ${inspect(s)})", 
        () => stream.eatUntilString(s), optional);
  }

  eatString(s, [optional = false]) {
    add("eatString(s: ${inspect(s)})", () => stream.eatString(s), optional);
  }

  next([optional = false]) {
    add("next", () => stream.next() >= 0, optional);
  }
  
  matchEos([optional = false]) {
    add("matchEos", () => stream.currentIndex >= stream.text.length, optional);
  }

  eatOn(fn(ctx), [optional = false]) {
    add("eatOn(fn)", () => stream.maybeEat(fn), optional);
  }

  eatUntil(fn(c), [optional = false]) {
    add("eatUntil(fn)", () => stream.eatUntil(fn), optional);
  }
  
  eatWhileNeitherTwo(c1, c2, [optional = false]) {
    add("eatWhileNeitherTwo(c1: ${c1}, c2: ${c2})", 
        () => stream.eatWhileNeitherTwo(c1, c2), optional);
  }

  eat(c, [optional = false]) {
    add("eat(c: ${c})", () => stream.eat(c), optional);
  }

  eatWhileNot(c, [optional = false]) {
    add("eatWhileNot(c: ${c})", () => stream.eatWhileNot(c), optional);
  }

  eatStringFromList(strings, [optional = false]) {
    add("eatStringFromList(strings: ${inspect(strings)})",
        () => stream.eatStringFromList(strings), optional);
  }

  eatUntilIncludingStringFromList(strings, [optional = false]) {
    var a = stream.makeFirstCharTable(strings);
    add("eatUntilIncludingStringFromList(strings: ${inspect(strings)})",
        () => stream.eatUntilIncludingStringFromList(a), optional);
  }

  eatUntilIncludingString(string, [optional = false]) {
    add("eatUntilIncludingString(string: ${inspect(string)})",
        () => stream.eatUntilIncludingString(string), optional);
  }

  eatIfNotStringFromList(strings, [optional = false]) {
    add("eatIfNotStringFromList(strings: ${inspect(strings)})",
        () => stream.eatIfNotStringFromList(strings), optional);
  }

  eatWhileNotStringFromList(strings, [optional = false]) {
    var a = stream.makeFirstCharTable(strings);
    add("eatWhileNotStringFromList(strings: ${inspect(strings)})",
        () => stream.eatWhileNotStringFromList(a), optional);
  }

  eatWhileStringFromList(strings, [optional = false]) {
    var a = stream.makeFirstCharTable(strings);
    add("eatWhileStringFromList(strings: ${inspect(strings)})",
        () => stream.eatWhileStringFromList(a), optional);
  }
  
  skipToEnd() {
    add("skipToEnd", stream.skipToEnd);
  }

  retryAtPartialSuccess() {
    add("retryAtPartialSuccess", () => _retryAtPartialSuccess = true);
    _retryAware = true;
  }
  
  runBatch(a) {
    var i, len = a.length, savei = stream.currentIndex;
    for (i = 0; i < len; i += 3) {
      if (!a[i + 1]() && !a[i + 2]) { // No success and not optional.
        stream.currentIndex = savei;
        break;
      }
    }
    return i >= len;
  }
  
  withBatch(fn(matcher), [optional = false]) {
    var batchList = [], saveList = list;
    list = batchList;
    fn(this);
    list = saveList;
    add("withBatch(list: ${inspect(batchList)})", () => runBatch(batchList),
        optional);
  }
  
  toString() {
    return "CodeUnitMatcher(list: ${list}, retryAware: ${_retryAware}, "
        "stream: ${stream})";
  }
  
}




