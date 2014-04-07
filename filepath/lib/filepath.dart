library filepath;

import "../../lang/lib/lang.dart";


class FilePath {
  
  var _win;
  
  FilePath({windows: false}) {
    _win = windows;
  }
  
  ensureWindowsPath(path) {
    return new String.fromCharCodes(doEnsureWindowsPath(path.codeUnits));
  }

  ensureLinuxPath(path) {
    return new String.fromCharCodes(doEnsureLinuxPath(path.codeUnits));
  }
  
  ensureOsPath(path) {
    var r;
    if (_win) {
      r = ensureWindowsPath(path);
    } else {
      r = ensureLinuxPath(path);
    }
    return r;
  }

  doEnsureWindowsPath(codeUnits) {
    var i, len = codeUnits.length, r = new List(len), c;
    for (i = 0; i < len; i++) {
      c = codeUnits[i];
      if (c == 47) { // /
        r[i] = 92; // \
      } else {
        r[i] = c; 
      }
    }
    return r;
  }

  doEnsureLinuxPath(codeUnits) {
    var i, len = codeUnits.length, r = new List(len), c;
    for (i = 0; i < len; i++) {
      c = codeUnits[i];
      if (c == 92) { // \
        r[i] = 47; // /
      } else {
        r[i] = c; 
      }
    }
    return r;
  }
  
  join(firstPath, secondPath) {
    var fpa = firstPath.codeUnits, r, 
      i = skipTrailingSlashes(fpa, fpa.length - 1), c;
    if (secondPath.length > 0) {
      c = secondPath.codeUnitAt(0);
      if (c == 47 || c == 92) { // / \
        r = "${new String.fromCharCodes(fpa.sublist(0, i + 1))}${secondPath}";
      } else {
        r = "${new String.fromCharCodes(fpa.sublist(0, i + 1))}/${secondPath}";
      }
    } else {
      r = "${new String.fromCharCodes(fpa.sublist(0, i + 1))}/";
    }
    return r;
  }
  
  skipTrailingSlashes(codeUnits, i) {
    var c;
    for (; i >= 0; i--) {
      c = codeUnits[i];
      if (c != 47 && c != 92) { // / \
        break;
      }
    }
    return i;
  }

  skipTrailingChars(codeUnits, i) {
    var c;
    for (; i >= 0; i--) {
      c = codeUnits[i];
      if (c == 47 || c == 92) { // / \
        break;
      }
    }
    return i;
  }
  
  baseName(path, [suffix]) {
    var codeUnits = path.codeUnits, len = codeUnits.length, r = "",
      i = skipTrailingSlashes(codeUnits, len - 1);
    if (i >= 0) { // Got something. Keep trailing chars and break at / \.
      if (i > 0) {
        var ei = i;
        i = skipTrailingChars(codeUnits, i - 1);
        r = new String.fromCharCodes(codeUnits.sublist(i + 1, ei + 1));
      } else {
        r = new String.fromCharCodes(codeUnits.sublist(0, i + 1)); 
      }
      if (suffix != null && r.endsWith(suffix)) {
        r = r.substring(0, r.length - suffix.length);
      }
    } else if (len > 0) {
      r = "/";
    }
    return r;
  }

  dirName(path) {
    var codeUnits = path.codeUnits, len = codeUnits.length, r = ".",
      i = skipTrailingSlashes(codeUnits, len - 1);
    if (i > 0) { // Got something. Keep trailing chars and break at / \.
      var ei = i, ci, c = codeUnits[0];
      if (i == 1 && codeUnits[1] == 58 && // : 
          ((c >= 65 && c <= 90) || (c >= 97 && c <= 122))) { // a-z A-Z
        if (len > 2) {
          r = new String.fromCharCodes(codeUnits.sublist(0, 3));
        } else {
          r = "${path}."; // c:.
        }
      } else {
        i = skipTrailingChars(codeUnits, i - 1);
        ci = i;
        i = skipTrailingSlashes(codeUnits, i - 1);
        if (i >= 0) {
          r = new String.fromCharCodes(codeUnits.sublist(0, i + 1)); 
        } else if (ci > 0) {
          r = new String.fromCharCodes(codeUnits.sublist(ci - 1, len)); 
        } else if (ci == 0) {
          r = path; 
        }
      }
    } else if (i == 0) {
      // Ignore.
    } else {
      r = new String.fromCharCodes(codeUnits.sublist(
          len - (len > 1 ? 2 : 1), len)); 
    }
    return r;
  }
  
  extName(path) {
    path = baseName(path);
    var r = "", codeUnits = path.codeUnits, i = codeUnits.length - 1, c;
    for (; i >= 0; i--) { // Skip trailing dots.
      if (codeUnits[i] != 46) { // .
        break;
      }
    }
    if (i > 0) {
      var ei = i;
      i--;
      for (; i >= 0; i--) { // Skip trailing chars.
        if (codeUnits[i] == 46) { // .
          break;
        }
      }
      if (i > 0) {
        r = new String.fromCharCodes(codeUnits.sublist(i, ei + 1));
      }
    } else if (i == 0) {
      r = path[0];
    }
    return r;
  }
  
  skipSlashes(codeUnits, len, i) {
    var c;
    for (; i < len; i++) {
      c = codeUnits[i];
      if (c != 47 && c != 92) { // / \
        break;
      }
    }
    return i;
  }
  
  skipChars(codeUnits, len, i) {
    var c;
    for (; i < len; i++) {
      c = codeUnits[i];
      if (c == 47 || c == 92) { // / \
        break;
      }
    }
    return i;
  }
  
  expandPath(path) {
    var codeUnits = path.codeUnits, len = codeUnits.length, i = 0,
      a = [], ai = -1, sb = new StringBuffer();
    add() {
      var si = i, s;
      i = skipChars(codeUnits, len, i + 1);
      ai++;
      s = new String.fromCharCodes(codeUnits.sublist(si, i));
      if (ai < a.length) {
        a[ai] = s;
      } else {
        a.add(s);
      }
      i = skipSlashes(codeUnits, len, i + 1);
    }
    stepBack() {
      if (ai >= 0) {
        ai--;
      }
      i = skipSlashes(codeUnits, len, i + 2);
    }
    if (len > 0) {
      var lasti = len - 1, c = codeUnits[0], slash = false;
      if (c == 47 || c == 92) { // / \
        sb.write("/");
        i = skipSlashes(codeUnits, len, 1);
      } else if (len > 1 && 
          ((c >= 65 && c <= 90) || (c >= 97 && c <= 122)) && // A-Z a-z
          codeUnits[1] == 58) { // :
        sb.write(path.substring(0, 2));
        sb.write("/");
        i = skipSlashes(codeUnits, len, 2);
      }
      while (i < len) {
        c = codeUnits[i];
        if (c == 46) { // .
          if (i < lasti) {
            c = codeUnits[i + 1];
            if (c == 46) { // ..
              if (i < lasti - 1) {
                c = codeUnits[i + 2];
                if (c == 47 || c == 92) { // / \
                  stepBack();
                } else {
                  add();
                }
              } else {
                stepBack();
              }
            } else if (c == 47 || c == 92) { // / \
              i = skipSlashes(codeUnits, len, i + 2);
            } else {
              add();
            }
          } else {
            break;
          }
        } else {
          add();
        }
      }
      for (i = 0; i <= ai; i++) {
        if (slash) {
          sb.write("/");
        }
        sb.write(a[i]);
        slash = true;
      }
    }
    return sb.toString();
  }
  
}


