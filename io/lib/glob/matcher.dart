library GlobMatcher;

import "../../../lang/lib/lang.dart";
import '../../../codeunitstream/lib/codeunitmatcher.dart';


class GlobMatcher {
  
  var root = null, parts, openParts, baseDir, matchers, ignoreCase = false,
    pathSep = '/', setParts, prepared = false;
  
  GlobMatcher() {
    parts = [];
    matchers = [];
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
    p(m);
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





