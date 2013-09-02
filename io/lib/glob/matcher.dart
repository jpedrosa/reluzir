library GlobMatcher;

import "../dir.dart";
import "dart:io" as DIO;
import "../../../lang/lib/lang.dart";
import '../../../codeunitstream/lib/codeunitmatcher.dart';


class GlobMatcher {
  
  var root = null, parts, openParts, baseDir, isWin, matchers, ignoreCase,
    pathSep, _d, setParts, skipDotFiles = false, prepared = false;
  
  GlobMatcher() {
    parts = [];
    matchers = [];
    isWin = Dir.isWindows;
    ignoreCase = isWin;
    pathSep = Dir.pathSeparator;
  }
  
  // Parts
  static const TEXT = 0;
  static const SEPARATOR = 1;
  static const RECURSE = 2;
  static const ANY = 3;
  static const ONE = 4;
  static const OPTIONAL_NAME = 5;
  static const SET = 6;
  static const NEGATION_SET = 7;
  static const SET_RANGE = 8;
  
  // Matcher type
  static const MATCHER = 20;
  static const ENDSWITH = 21;
  static const NAME = 22;
  static const ALL = 23;
  
  list() {
    if (!prepared) {
      prepare();
    }
    var r = [], len = matchers.length, d = _d;
    if (Dir.isDirectory(d.path) && len > 0) {
      doList(d, matchers, 0, len - 1, _d.path.length, ignoreCase, 
          skipDotFiles, r);
    }
    if (r.length == 0) {
      r.add(_d);
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
      r = d.listSync(followLinks: false);
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

  prepare() {
    prepared = true;
    var a = parts, i, len = a.length, b, sb = new StringBuffer(), k, s,
      sep = pathSep;
    if (root != null) {
      sb.write(root);
    }
    for (i = 0; i < len; i++) {
      b = a[i];
      k = b[0];
      if (k == TEXT && b.length == 2) {
        sb.write(b[1]);
      } else if (k == SEPARATOR) {
        sb.write(sep);
      } else {
        break;
      }
    }
    s = sb.toString();
    baseDir = s;
    _d = s.length > 0 ? Dir.openDirectory(s) : Dir.currentDir;
    compileMatchers(i);
  }
  
  compileMatchers(i) {
    var a = parts, len = a.length, b, k, mm = matchers, ic = ignoreCase;
    for (; i < len; i++) {
      b = a[i];
      k = b[0];
      if (k == RECURSE) {
        mm.add([RECURSE]);
      } else if (k == SEPARATOR) {
        // ignore
      } else { // ANY ONE TEXT
        mm.add(compilePart(k, b));
      }
    }
  }
  
  compilePart(k, b) {
    var r, ic = ignoreCase;
    if (k == TEXT && b.length == 2) {
      r = [NAME, "${pathSep}${b[1]}"];
    } else if (k == ANY && b.length == 2) {
      r = [ALL, b[1]];
    } else if (k == ANY && b.length == 4 && b[2] == TEXT) {
      r = [ENDSWITH, b[b.length - 1]];
    } else {
      r = [MATCHER, assembleMatcher(k, b)];
    }
    return r;
  }

  assembleMatcher(k, b) {
    var ic = ignoreCase, m = new CodeUnitMatcher(), lastk, j, z, 
      addedRetry = false, jlen = b.length;
    for (j = 0; j < jlen; j += 2) {
      k = b[j];
      switch (k) {
        case ANY:
          if (!addedRetry) {
            addedRetry = true;
            m.retryAtPartialSuccess();
          }
          break;
        case ONE:
          m.next();
          break;
        case TEXT:
          z = b[j + 1];
          if (ic) {
            z = z.toLowerCase();
          }
          if (lastk == ANY) {
            m.eatUntilIncludingString(z);
          } else {
            m.eatString(z);
          }
          break;
        case OPTIONAL_NAME:
          var zz = b[j + 1], zi, zlen = zz.length;
          if (ic) {
            zz = zz.toList();
            for (zi = 0; zi < zlen; zi++) {
              zz[zi] = zz[zi].toLowerCase();
            }
          }
          if (lastk == ANY) {
            m.eatUntilIncludingStringFromList(zz);
          } else {
            m.eatStringFromList(zz);
          }
          break;
        case SET: case NEGATION_SET:
          var sp = b[j + 1], spi, splen = sp.length, zz = [], z, ri, rp, rlen,
            ra, rb;
            for (spi = 0; spi < splen; spi += 2) {
              if (sp[spi] == TEXT) {
                z = sp[spi + 1];
                if (ic) {
                  z = z.toLowerCase();
                }
                zz.add(z);
              } else { // SET_RANGE
                rp = sp[spi + 1];
                ra = rp[0];
                rb = rp[1];
                if (ic) {
                  ra = ra.toLowerCase();
                  rb = rb.toLowerCase();
                }
                zz.add(ra);
                rlen = rb.codeUnitAt(0);
                for (ri = ra.codeUnitAt(0) + 1; ri < rlen; ri++) {
                  zz.add(new String.fromCharCode(ri));
                }
                zz.add(rb);
              }
            }
          if (lastk == ANY) {
            if (k == NEGATION_SET) {
              m.eatWhileStringFromList(zz, true);
              m.eatWhileNotStringFromList(zz);
            } else {
              m.eatUntilIncludingStringFromList(zz);
            }
          } else {
            if (k == NEGATION_SET) {
              m.eatIfNotStringFromList(zz);
            } else {
              m.eatStringFromList(zz);
            }
          }
      }
      lastk = k;
    }
    if (lastk == ANY) {
      m.skipToEnd();
    }
    m.matchEos();
    //p(m);
    return m;
  }
  
  ensureOpenParts() {
    if (openParts == null) {
      openParts = [];
      parts.add(openParts);
    }
  }
  
  add(partType, text) {
    ensureOpenParts();
    openParts.add(partType);
    openParts.add(text);
  }

  addOptionalName(text) {
    ensureOpenParts();
    var pp = openParts, len = pp.length;
    if (len == 0 || pp[len - 2] != OPTIONAL_NAME) {
      pp.add(OPTIONAL_NAME);
      pp.add([text]);
    } else {
      pp[len - 1].add(text);
    }
  }
  
  addRecurse(text) {
    var a = parts, len = a.length;
    if (len == 0 || a[len - 1][0] != RECURSE) {
      if (openParts != null) {
        openParts = null;
      }
      a.add([RECURSE, text]);
    }
  }
  
  addSeparator(text) {
    if (openParts != null) {
      openParts = null;
    }
    parts.add([SEPARATOR, text]);
  }
  
  addSet(text) {
    setParts.add(TEXT);
    setParts.add(text);
  }

  addSetRange(a, b) {
    setParts.add(SET_RANGE);
    setParts.add([a, b]);
  }
  
  openSet() {
    ensureOpenParts();
    setParts = [];
    openParts.add(SET);
    openParts.add(setParts);
  }

  openNegationSet() {
    ensureOpenParts();
    setParts = [];
    openParts.add(NEGATION_SET);
    openParts.add(setParts);
  }
  
  closeSet() {
    setParts = null;
  }
  
  toString() {
    return "GlobMatcher(root: ${root}, "
      "parts: ${inspect(parts)}, matchers: ${inspect(matchers)})";
  }
  
}





