

class ParseLeadingInt {
  
  static parse(s, {orZero: false}) {
    var i = 0, negative = false, c, cc = s.codeUnits, len = cc.length, n = 0;
    if (len > 0) {
      if (cc[0] == 45) { // -
        negative = true;
        i++;
      }
      for (; i < len; i++) {
        c = cc[i];
        if (c < 48 || c > 57) { // 0-9
          break;
        }
      }
      if (negative && i == 1) {
        if (!orZero) {
          throw "Cannot parse the leading int for '-'";
        }
      } else if (i == len) {
        n = int.parse(s);
      } else if (i > 0) {
        n = int.parse(s.substring(0, i));
      } else if (!orZero) {
        throw "Cannot parse the leading int for '${s}'";
      }
    } else if (!orZero) {
      throw "Cannot parse the leading int for empty string ('')";
    }
    return n;
  }
  
}




