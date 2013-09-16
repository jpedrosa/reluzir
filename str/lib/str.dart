library Str;


class StrImpl {
  
  insert(hostString, token, index) {
    var s = hostString, len = s.length;
    if (index >= len) {
      s = "${s}${token}";
    } else if (index == 0) {
      s = "${token}${s}";
    } else {
      s = "${s.substring(0, index)}${token}${s.substring(index, len)}";
    }
    return s;
  }

  removeAt(string, startIndex, endIndex) {
    var z = "", s = string, len = s.length;
    if (endIndex >= len) {
      if (startIndex > 0) {
        z = s.substring(0, startIndex);
      }
    } else if (startIndex <= 0) {
      z = s.substring(endIndex, len);
    } else {
      z = "${s.substring(0, startIndex)}${s.substring(endIndex, len)}";
    }
    return z;
  }

  indexOfCodeUnit(string, codeUnit, [index = 0]) {
    var len = string.length, lim = len - 2, i = index, r = -1;
    for (; i < lim; i += 3) {
      if (string.codeUnitAt(i) == codeUnit ||
          string.codeUnitAt(i + 1) == codeUnit ||
          string.codeUnitAt(i + 2) == codeUnit) {
        break;
      }
    }
    for (; i < len; i++) {
      if (string.codeUnitAt(i) == codeUnit) {
        r = i;
        break;
      }
    }
    return r;
  }

  indexOfNewLine(string, [index = 0]) {
    var len = string.length, lim = len - 2, i = index, r = -1;
    for (; i < lim; i += 3) {
      if (string.codeUnitAt(i) == 10 ||
          string.codeUnitAt(i + 1) == 10 ||
          string.codeUnitAt(i + 2) == 10) {
        break;
      }
    }
    for (; i < len; i++) {
      if (string.codeUnitAt(i) == 10) {
        r = i;
        break;
      }
    }
    return r;
  }

  static const NEW_LINE = "\n";
  static const WINDOWS_NEW_LINE = "\r\n";
  
  withNewLinePreference(s, needCrlf, fn(s, newLineStr)) {
    var len = s.length, cr = -1, cn = -1, nStr;
    if (len > 1) {
      cn = s.codeUnitAt(len - 1);
      cr = s.codeUnitAt(len - 2);
      if (needCrlf) {
        if (cn == 10) { // new line
          if (cr != 13) { // Windows carriage return
            s = s.substring(0, len - 1);
            nStr = WINDOWS_NEW_LINE;
          }
        } else if (cn == 13) {
          nStr = NEW_LINE;
        } else {
          nStr = WINDOWS_NEW_LINE;
        }
      } else {
        if (cn == 10) {
          if (cr == 13) {
            s = s.substring(0, len - 2);
            nStr = NEW_LINE;
          }
        } else if (cn == 13) {
          s = s.substring(0, len - 1);
          nStr = NEW_LINE;
        } else {
          nStr = NEW_LINE;
        }
      }
    } else if (len > 0) {
      cn = s.codeUnitAt(len - 1); // new line
      if (needCrlf) {
        if (cn == 10) {
          s = "";
          nStr = WINDOWS_NEW_LINE;
        } else if (cn == 13) {
          nStr = NEW_LINE;
        } else {
          nStr = WINDOWS_NEW_LINE;
        }
      } else {
        if (cn == 10) {
          // ignore
        } else if (cn == 13) {
          s = "";
          nStr = NEW_LINE;
        } else {
          nStr = NEW_LINE;
        }
      }
    }
    fn(s, nStr);
  }
  
}


var _oneStr;

get Str {
  if (_oneStr == null) {
    _oneStr = new StrImpl();
  }
  return _oneStr;
}


