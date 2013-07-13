library RE;

import "../../lang/lib/lang.dart";


class DRRegExp extends Pattern {
  
  final RegExp re;

  DRRegExp(RegExp this.re);

  // alias: Ruby name
  Match match(String string) {
    return re.firstMatch(string);
  }
  
  Match firstMatch(String string) {
    return re.firstMatch(string);
  }

  // alias: JavaScript name
  Match exec(String string) {
    return re.firstMatch(string);
  }
  
  bool hasMatch(String string) {
    return re.hasMatch(string);
  }
  
  // alias: JavaScript name
  bool test(String string) {
    return re.hasMatch(string);
  }
  
  Iterable<Match> allMatches(String s) {
    return re.allMatches(s);
  }
  
  // alias: new idea
  Iterable<Match> matchAll(String s) {
    return re.allMatches(s);
  }
  
  Match matchAsPrefix(String string, [int start = 0]) {
    return re.matchAsPrefix(string, start);
  }

  // alias: new idea
  Match matchAt(String string, int start) {
    return re.matchAsPrefix(string, start);
  }
  
  String stringMatch(String string) {
    return re.stringMatch(string);
  }

  bool get isCaseSensitive => re.isCaseSensitive;

  bool get isMultiLine => re.isMultiLine;

  String get pattern => re.pattern;

  // alias: Ruby and JavaScript name
  String get source => re.pattern;
  
  String toString() {
    return "DRRegExp(pattern: ${inspect(pattern)}, "
       "caseSensitive: ${isCaseSensitive}, "
       "multiLine: ${isMultiLine})";
  }
  
}


class DRRECache {

  var _cache, _multiLine, _caseSensitive;
  
  DRRECache({multiLine: false, caseSensitive: true}) {
    _cache = {};
    _multiLine = multiLine;
    _caseSensitive = caseSensitive;
  }
  
  DRRegExp operator [](String patternString) {
    var re = _cache[patternString];
    if (re == null) {
      re = new DRRegExp(new RegExp(patternString, multiLine: _multiLine,
          caseSensitive: _caseSensitive));
      _cache[patternString] = re;
    }
    return re;
  }
  
}


var _oneRE;

DRRECache get RE {
  if (_oneRE == null) {
    _oneRE = new DRRECache();
  }
  return _oneRE;
}

var _oneREm;

DRRECache get REm {
  if (_oneREm == null) {
    _oneREm = new DRRECache(multiLine: true);
  }
  return _oneREm;
}

var _oneREi;

DRRECache get REi {
  if (_oneREi == null) {
    _oneREi = new DRRECache(caseSensitive: false);
  }
  return _oneREi;
}

var _oneREim;

DRRECache get REim {
  if (_oneREim == null) {
    _oneREim = new DRRECache(multiLine: true, caseSensitive: false);
  }
  return _oneREim;
}

DRRECache get REmi {
  if (_oneREim == null) {
    _oneREim = new DRRECache(multiLine: true, caseSensitive: false);
  }
  return _oneREim;
} 







