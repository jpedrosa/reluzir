library IO;

import "dart:io" as DIO;


class IOImpl {
  
  var _f, isWindows;
  
  IOImpl() {
    isWindows = DIO.Platform.isWindows;
  }
  
  read(filePath) => openFile(filePath).readAsStringSync();
  
  readLines(filePath) => openFile(filePath).readAsLinesSync();

  readBytes(filePath) => openFile(filePath).readAsBytesSync();
  
  write(filePath, string) {
    openFile(filePath).writeAsStringSync(string);
  }
  
  writeBytes(filePath, List<int> bytes) {
    openFile(filePath).writeAsBytesSync(bytes);
  }
  
  openFile(filePath) => new DIO.File(filePath);

  openRandomAccessFile(filePath, [mode = 'r']) =>
      new DIO.File(filePath).openSync(mode: parseStringMode(mode));
  
  parseStringMode(s) {
    var r;
    if (s == 'r') {
      r = DIO.FileMode.READ;
    } else if (s == 'w') {
      r = DIO.FileMode.WRITE;
    } else if (s == 'a') {
      r = DIO.FileMode.APPEND;
    } else {
      throw "Unexpected file mode: ${s}";
    }
    return r;
  }
  
}


var _oneIO;

get IO {
  if (_oneIO == null) {
    _oneIO = new IOImpl();
  }
  return _oneIO;
}




