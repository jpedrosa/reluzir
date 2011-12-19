#library("parsedict");
// Copyright (c) 2012 Joao Pedrosa


class ParseDict {

  static parse(s) {
    var dict = {}, i = -1, mirror = s.charCodes(), len = mirror.length, c, k,
      lookingFor = 0, tokenType = 50, token, lineCount = 1, lineMark = 0;
    invalidInput() {
      var j = lineMark + 1,
        line = j <= i ?
        new String.fromCharCodes(mirror.getRange(
          j, i - j + 1)) : '',
        llen = line.length,
        lastChars = llen > 5 ? line.substring(llen - 5, llen) : line;
      throw "Exception: Invalid input. Stopped at line# ${lineCount} and " +
        "at char# ${llen}: => ${lastChars}";
    }
    while (true) {
      if (c === null) {
        i += 1;
        if (i < len) {
          c = mirror[i];
        } else if (tokenType == 100) {
          break;
        } else {
          invalidInput();
        }
      }
      switch (lookingFor) {
      case 0: // spaces
        switch (c) {
        case 32: // space
        case 9: // \t
        case 10: // \n
        case 13: // \r
          if (c == 10) {
            lineCount += 1;
            lineMark = i;
          }
          c = null;
          break;
        default:
          lookingFor = tokenType; 
        }
        break;
      case 1: // not '
        switch (c) {
        case 39: // '
          lookingFor = tokenType; 
          break;
        case 92: // \
          if (i + 1 < len) {
            token.add(mirror[i + 1]);
            i += 1;
            c = null;
          } else {
            invalidInput();
          }
          break;
        default:
          token.add(c);
          c = null; 
        }
        break;
      case 50:
        if (c == 123) { // {
          tokenType = 51;
          lookingFor = 0;
          c = null;
        } else {
          invalidInput();
        } 
        break;
      case 51:
        if (c == 39) { // '
          tokenType = 52;
          lookingFor = 1;
          c = null;
          token = [];
        } else {
          invalidInput();
        } 
        break;
      case 52: // close string with a '
        k = token;
        tokenType = 53;
        lookingFor = 0;
        c = null;
        break;
      case 53:
        if (c == 58) { // :
          tokenType = 54;
          lookingFor = 0;
          c = null;
        } else {
          invalidInput();
        } 
        break;
      case 54:
        if (c == 39) { // '
          token = [];
          tokenType = 55;
          lookingFor = 1;
          c = null;
        } else {
          invalidInput();
        } 
        break;
      case 55: // close string with a '
        dict[new String.fromCharCodes(k)] = new String.fromCharCodes(token);
        tokenType = 56;
        lookingFor = 0;
        c = null;
        break;
      case 56: 
        switch (c) {
        case 44: // ,
          tokenType = 51;
          lookingFor = 0;
          c = null;
          break;
        case 125: // }
          tokenType = 100;
          lookingFor = 0;
          c = null;
          break;
        default:
          invalidInput();
        }
        break;
      case 100:
        invalidInput();
      }
    }
    return dict;
  }

}








