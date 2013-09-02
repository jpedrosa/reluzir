library Dir;

import "dart:io" as DIO;
import "../../lang/lib/lang.dart";
import "glob/parser.dart";


class DirImpl {
  
  var _globParser;
  
  DirImpl() {
    _globParser = new GlobParser();
  }
  
  glob(s, {skipDotFiles: true, ignoreCase}) {
    var m = _globParser.parse(s);
    m.skipDotFiles = skipDotFiles;
    if (ignoreCase != null) {
      m.ignoreCase = ignoreCase;
    }
    return m.list();
  }
  
  get pwd => currentDir.path;
  
  get currentDir => DIO.Directory.current;
  
  get isWindows => DIO.Platform.isWindows;

  get pathSeparator => DIO.Platform.pathSeparator;
  
  openDirectory(s) => new DIO.Directory(s);
  
  isDirectory(s) => openDirectory(s).existsSync();

  isFile(s) => new DIO.File(s).existsSync();
  
  operator [](s) => glob(s);
  
}


var _oneDir;

get Dir {
  if (_oneDir == null) {
    _oneDir = new DirImpl();
  }
  return _oneDir;
}


