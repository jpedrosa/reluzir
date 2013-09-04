library GlobListSyncMatcher;

import "../dir.dart";
import "dart:io" as DIO;
import "../../../lang/lib/lang.dart";
import "matcher.dart";


class GlobListSyncMatcher extends GlobMatcher {
  
  var _d, isWin, skipDotFiles = false, followLinks = false;
  
  GlobListSyncMatcher() {
    isWin = Dir.isWindows;
    ignoreCase = isWin;
    pathSep = Dir.pathSeparator;
  }
  
  // Parts
  static const RECURSE = 2;
  
  // Matcher type
  static const MATCHER = 20;
  static const ENDSWITH = 21;
  static const NAME = 22;
  static const ALL = 23;
  
  list() {
    if (!prepared) {
      prepare();
    }
    var d = _d, s = baseDir, r = [], len = matchers.length;
    if (d == null) {
      d = s.length > 0 ? Dir.openDirectory(s) : Dir.currentDir;
      _d = d;
    }
    if (Dir.isDirectory(d.path) && len > 0) {
      doList(d, matchers, 0, len - 1, d.path.length, ignoreCase, 
          skipDotFiles, r);
    }
    if (r.length == 0) {
      r.add(d);
    }
    return r;
  }
  
  doList(d, a, i, lasti, si, ic, skipDot, r) {
    var b = a[i], k = b[0], ff;
    if (k == RECURSE) {
      if (i >= lasti) {
        r.add(d);
        recurseAndAddDirectories(d, si, skipDot, r);
      } else if (i + 1 >= lasti) {
        b = a[i + 1];
        recurseAndMatch(d, b[0], b[1], si, ic, skipDot, r);
      } else {
        var j;
        for (j = i + 2; j <= lasti; j++) {
          if (a[j][0] == RECURSE) {
            break;
          }
        }
        if (j >= lasti) {
          recurseAndMultiLevelMatch(d, a, i, lasti, null, si, ic, 
              skipDot, r);
        } else {
          subRecurse(d, a, i, lasti, null, j - 1, si, ic, skipDot, r);
        }
      }
    } else { // MATCHER ENDSWITH NAME
      var ff = listFiles(d), jlen = ff.length, j, f,
        s, m = b[1];
      if (i < lasti) {
        for (j = 0; j < jlen; j++) {
          f = ff[j];
          if (f is DIO.Directory) {
            s = f.path;
            if (matchFileName(k, m, s, si, ic, skipDot)) {
              doList(f, a, i + 1, lasti, s.length + 1, ic, skipDot, r);
            }
          }
        }
      } else {
        for (j = 0; j < jlen; j++) {
          f = ff[j];
          if (matchFileName(k, m, f.path, si, ic, skipDot)) {
            r.add(f);
          }
        }
      }
    }
  }
  
  listFiles(d) {
    var r;
    try {
      r = d.listSync(followLinks: followLinks);
    } catch (e) {
      r = [];
    }
    return r;
  }
  
  matchFileName(k, m, s, si, ic, skipDot) {
    var r;
    if (skipDot && s.codeUnitAt(si) == 46) { // .
      r = false;
    } else if (k == ALL) {
      r = true;
    } else {
      if (ic) {
        s = s.toLowerCase();
      }
      r = (k != MATCHER && s.endsWith(m)) ||
          (k == MATCHER && m.matchAt(s, si) >= 0);
    }
    return r;
  }

  okDot(s, si, skipDot) {
    return !skipDot || s.codeUnitAt(si) != 46; // .
  }
  
  recurseAndMatch(d, k, m, si, ic, skipDot, r) {
    var ff = listFiles(d), jlen = ff.length, j, f, s;
    for (j = 0; j < jlen; j++) {
      f = ff[j];
      s = f.path;
      if (matchFileName(k, m, s, si, ic, skipDot)) {
        r.add(f);
      }
      if (f is DIO.Directory && okDot(s, si, skipDot)) {
        recurseAndMatch(f, k, m, s.length + 1, ic, skipDot, r);
      }
    }
  }

  recurseAndMultiLevelMatch(d, a, i, lasti, mil, si, ic, skipDot, r) {
    var ff = listFiles(d), jlen = ff.length, j, f, s, b,
      firstMatcher = a[i + 1], sureMatch, mi, n, freshMil,
      sureMil = mil != null, milen = sureMil ? mil.length : 0,
      finalMatcher, sureFinalMatcher = false;
    if (sureMil) {
      for (mi = 0; mi < milen; mi++) {
        n = mil[mi];
        if (n == lasti) {
          finalMatcher = a[n];
          sureFinalMatcher = true;
          break;
        }
      }
      if (sureFinalMatcher) {
        if (milen == 1) {
          mi = null;
          sureMil = false;
        } else {
          mil.removeAt(mi);
          milen--;
        }
      }
    }
    for (j = 0; j < jlen; j++) {
      f = ff[j];
      s = f.path;
      if (sureFinalMatcher && 
          matchFileName(finalMatcher[0], finalMatcher[1], s, si, ic, 
              skipDot)) {
        r.add(f);
      }
      if (f is DIO.Directory && okDot(s, si, skipDot)) {
        sureMatch = matchFileName(firstMatcher[0], firstMatcher[1], s, si, 
            ic, skipDot);
        freshMil = null;
        if (sureMil) {
          freshMil = [];
          for (mi = 0; mi < milen; mi++) {
            n = mil[mi];
            b = a[n];
            if (matchFileName(b[0], b[1], s, si, ic, skipDot)) {
              freshMil.add(n + 1);
            }
          }
          if (sureMatch) {
            freshMil.add(i + 2);
          } else if (freshMil.length == 0) {
            freshMil = null;
          }
        } else if (sureMatch) {
          freshMil = [i + 2];
        }
        recurseAndMultiLevelMatch(f, a, i, lasti, freshMil, s.length + 1, 
            ic, skipDot, r);
      }
    }
  }

  subRecurse(d, a, i, lasti, mil, lastmi, si, ic, skipDot, r) {
    var ff = listFiles(d), jlen = ff.length, j, f, s, b,
      firstMatcher = a[i + 1], sureMatch, mi, n, freshMil,
      sureMil = mil != null, milen = sureMil ? mil.length : 0,
      finalMatcher, sureFinalMatcher = false;
    if (sureMil) {
      for (mi = 0; mi < milen; mi++) {
        n = mil[mi];
        if (n == lastmi) {
          finalMatcher = a[n];
          sureFinalMatcher = true;
          break;
        }
      }
      if (sureFinalMatcher) {
        if (milen == 1) {
          mi = null;
          sureMil = false;
        } else {
          mil.removeAt(mi);
          milen--;
        }
      }
    }
    for (j = 0; j < jlen; j++) {
      f = ff[j];
      s = f.path;
      if (f is DIO.Directory && okDot(s, si, skipDot)) {
        sureMatch = matchFileName(firstMatcher[0], firstMatcher[1], s, si, 
            ic, skipDot);
        if ((sureMatch && i + 1 == lastmi) || (sureFinalMatcher && 
            matchFileName(finalMatcher[0], finalMatcher[1], s, si, ic,
                skipDot))) {
          doList(f, a, lastmi + 1, lasti, s.length + 1, ic, skipDot, r);
        } else {
          freshMil = null;
          if (sureMil) {
            freshMil = [];
            for (mi = 0; mi < milen; mi++) {
              n = mil[mi];
              b = a[n];
              if (matchFileName(b[0], b[1], s, si, ic, skipDot)) {
                freshMil.add(n + 1);
              }
            }
            if (sureMatch) {
              freshMil.add(i + 2);
            } else if (freshMil.length == 0) {
              freshMil = null;
            }
          } else if (sureMatch) {
            freshMil = [i + 2];
          }
          subRecurse(f, a, i, lasti, freshMil, lastmi, s.length + 1, ic, 
              skipDot, r);
        }
      }
    }
  }
  
  recurseAndAddDirectories(d, si, skipDot, r) {
    var ff = listFiles(d), len = ff.length, i, f, s; 
    for (i = 0; i < len; i++) {
      f = ff[i];
      s = f.path;
      if (f is DIO.Directory && okDot(s, si, skipDot)) {
        r.add(f);
        recurseAndAddDirectories(f, s.length + 1, skipDot, r);
      }
    }
  }
  
  toString() {
    return "GlobListSyncMatcher(root: ${root}, "
      "parts: ${inspect(parts)}, matchers: ${inspect(matchers)})";
  }
  
}





