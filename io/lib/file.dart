library File;

import "io.dart";
import "../../lang/lib/lang.dart";
import "../../str/lib/str.dart";


class File {
  
  var _f;
  
  File(filePath, [mode = 'r']) {
    _f = IO.openRandomAccessFile(filePath, mode);
  }
  
  static const NEW_LINE = "\n";
  static const WINDOWS_NEW_LINE = "\r\n";
  
  puts(v) {
    var f = _f;
    if (v is List) {
      var i, len = v.length;
      for (i = 0; i < len; i++) {
        putStringEnsureNewLine(f, v[i]);
      }
    } else if (v is Iterable) {
      for (var e in v) {
        putStringEnsureNewLine(f, e);
      }
    } else {
      f.writeStringSync(v is String ? v : v.toString());
    }
  }
  
  putStringEnsureNewLine(f, s) {
    if (s is! String) {
      s = s.toString();
    }
    Str.withNewLinePreference(s, IO.isWindows, (s, newLineStr) {
      f.writeStringSync(s);
      if (newLineStr != null) {
        f.writeStringSync(newLineStr);
      }
      });
  }

  operator << (string) {
    _f.writeStringSync(string);
    return this;
  }

  print(v) {
    _f.writeStringSync(v is String ? v : v.toString());
  }
  
  readBytes(length) => _f.readSync(length);

  readByte() => _f.readByteSync();
  
  write(string) {
    _f.writeStringSync(string);
  }
  
  writeBytes(List<int> bytes, [startIndex, endIndex]) {
    _f.writeFromSync(bytes, startIndex, endIndex);
  }
  
  flush() {
    _f.flushSync();
  }

  close() {
    _f.closeSync();
  }
  
  truncate(length) {
    _f.truncateSync(length);
  }
  
  get length => _f.lengthSync;

  get position => _f.positionSync;
  
  set position(v) {
    _f.setPositionSync(v);
  }

  get path => _f.path;
  
  static open(filePath, [mode = 'r', fn(f)]) {
    var f = new File(filePath, mode);
    if (fn != null) {
      fn(f);
      f.close();
    }
    return f;
  }
  
}



