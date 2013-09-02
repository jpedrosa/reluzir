library GlobParser;

import 'lexer.dart';
import '../../../codeunitstream/lib/codeunitstream.dart';
import '../../../parser/lib/tokenstream.dart';
import '../../../parser/lib/common.dart';
import "../../../lang/lib/lang.dart";
import 'matcher.dart';


class GlobParserStatus extends ParserStatus {
  
  var matcher;
  
  GlobParserStatus({parser, this.matcher}) : super(parser: parser);
  
  get hashCode => "GlobParserStatus(parser: ${parser}, "
      "spaceParser: ${spaceParser}, "
      "commentParser: ${commentParser}, "
      "stored: ${stored.toString()}, "
      "matcher: ${matcher.toString()})".hashCode;
  
  toString() {
    return "GlobParserStatus(parser: ${parser}, "
        "spaceParser: ${spaceParser}, "
        "commentParser: ${commentParser}, "
        "stored: ${inspect(stored)}, "
        "matcher: ${inspect(matcher)})";
  }
  
}


class GlobParser {
  
  var lexer;
  
  GlobParser() {
    lexer = new GlobLexer();
  }

  static const TEXT = GlobLexer.TEXT;
  static const SEPARATOR = GlobLexer.SEPARATOR;
  static const NAME = GlobLexer.NAME;
  static const SYMBOL = GlobLexer.SYMBOL;
   
  static const RECURSE_STR = '**';
  static const ANY_STR = '*';
  static const ONE_STR = '?';
  static const OPEN_BRACE_STR = '{';
  static const CLOSE_BRACE_STR = '}';
  static const COMMA_STR = ',';
  static const OPEN_BRACKET_STR = '[';
  static const CLOSE_BRACKET_STR = ']';
  static const CIRCUMFLEX_STR = '^';
  static const MINUS_STR = '-';
  
  parse(s) {
    var m = new GlobMatcher(), types = [], startIndexes = [],
      strings = [],
      endIndexes = [], len, stream = new CodeUnitStream(text: s);
    lexer.parse(stream, lexer.spawnStatus(),
        (tt) { 
          types.add(tt);
          startIndexes.add(stream.startIndex); 
          endIndexes.add(stream.currentIndex);
          strings.add(stream.currentTokenString);
        });
    len = types.length;
    if (len > 0 && types[len - 1] != TEXT) {
      m = doParse(new TokenStream(types: types, strings: strings, 
        startIndexes: startIndexes, endIndexes: endIndexes));
    }
    return m;
  }
  
  doParse(stream) {
    var m = new GlobMatcher(),
      status = new GlobParserStatus(parser: inRoot, matcher: m);
    status.parser = inRoot;
    try {
      while (!stream.isEos) {
        status.parser(stream, status);
        stream.startIndex = stream.currentIndex;
        stream.currentIndex++;
      }
      if (status.stored.length > 0) {
        m = new GlobMatcher();
        //throw "Expected zero length stored status. "
        //    "Got: ${inspect(status.stored)}";
      }
    } catch (e) {
      m = new GlobMatcher();
    }
    return m;
  }

  inOptionalNameComma(stream, status) {
    if (stream.matchString(COMMA_STR)) {
      status.parser = inOptionalName;
    } else if (stream.matchString(CLOSE_BRACE_STR)) {
      status.parser = status.pop();
    } else {
      err(stream, status, "comma or close brace");
    }
  }
  
  inOptionalName(stream, status) {
    if (stream.match(NAME)) {
      status.matcher.addOptionalName(stream.tokenString);
      status.parser = inOptionalNameComma;
    } else {
      err(stream, status, "optional name");
    }
  }
  
  inOptionalNameMaybeEmpty(stream, status) {
    if (stream.matchString(CLOSE_BRACE_STR)) {
      status.parser = status.pop();
    } else {
      inOptionalName(stream, status);
    }
  }
  
  matchSetRangeMinus(o) {
    return o.match(SYMBOL) && o.matchString(MINUS_STR); 
  }
  
  inSet(stream, status) {
    status.parser = inSet;
    if (stream.match(SYMBOL) && stream.matchString(CLOSE_BRACKET_STR)) {
      status.matcher.closeSet();
      status.parser = status.pop();
    } else if (stream.match(NAME)) {
      if (stream.matchRight(matchSetRangeMinus)) {
        var sa = stream.tokenString, i = stream.currentIndex;
        stream.currentIndex = i + 2;
        status.matcher.addSetRange(sa, stream.tokenString);
      } else {
        status.matcher.addSet(stream.tokenString);
      }
    } else {
      err(stream, status, "set text or close bracket");
    }
  }

  inSetNegation(stream, status) {
    if (stream.match(SYMBOL)) { // ^
      status.matcher.openNegationSet();
      status.parser = inSet;
    } else {
      status.matcher.openSet();
      inSet(stream, status);
    }
  }
  
  inBody(stream, status) {
    if (stream.matchString(RECURSE_STR)) {
      if (stream.isBos || stream.matchLeft((o) => o.match(SEPARATOR)) &&
          (stream.matchRight((o) => o.match(SEPARATOR)))) {
        status.matcher.addRecurse(stream.tokenString);
        stream.currentIndex++;
      } else {
        status.matcher.add(GlobMatcher.ANY, stream.tokenString);
      }
    } else if (stream.matchString(ANY_STR)) {
      status.matcher.add(GlobMatcher.ANY, stream.tokenString);
    } else if (stream.matchString(ONE_STR)) {
      status.matcher.add(GlobMatcher.ONE, stream.tokenString);
    } else if (stream.match(SEPARATOR)) {
      status.matcher.addSeparator(stream.tokenString);
    } else if (stream.matchString(OPEN_BRACE_STR)) {
      status.push(inBody);
      status.parser = inOptionalNameMaybeEmpty;
    } else if (stream.matchString(OPEN_BRACKET_STR)) {
      status.push(inBody);
      status.parser = inSetNegation;
    } else {
      status.matcher.add(GlobMatcher.TEXT, stream.tokenString);
    }
  }
  
  inRoot(stream, status) {
    status.parser = inBody;
    if (stream.match(SEPARATOR)) {
      status.matcher.root = stream.tokenString;
    } else {
      inBody(stream, status);
    }
  }
  
  err(stream, status, s) {
    throw "Expected ${s}. Got: ${stream.tokenString}";
  }
  
  toString() => "GlobParser()";
  
}



