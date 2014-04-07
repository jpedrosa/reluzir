FilePath
========

FilePath is a library that provides some handy methods for working with file paths. The inspiration comes from Ruby.

I tried to copy the behavior of Ruby as much as possible. But I deviated a little in the expandPath method from some of what Ruby was showing for trailing dots ("c:/t_/..." or "c:/t_..."), since I didn't quite get why Ruby was skipping some of those.

Another difference to Ruby is that in FilePath I tried to keep the code independent from I/O libraries so it could be used in browser code that doesn't have access to such libraries. If a feature depended on having access to I/O library it did not get implemented, say expanding home directories like "~". To do this we would need to access the environment variable "HOME", for instance.

You can refer to the Ruby documentation on such methods if you wish: http://ruby-doc.org/core-2.0.0/File.html

Of note is that using the expandPath can help to normalize a file path for matching patterns against it.

=========

The following direct test shows just what is available:

```dart
import "../../lib/filepath.dart";
import "../../../lang/lib/lang.dart";


main() {
  var fp = new FilePath(windows: true);
  p(fp.ensureWindowsPath("../publish/web/"));
  p(fp.ensureLinuxPath("..\\publish\\web/"));
  p(fp.baseName("../publish/web.oba/"));
  p(fp.baseName("../publish/web.oba/", ".oba"));
  p(fp.dirName("c:/t_/sophia/afile.txt"));
  p(fp.extName("c:/t_/afile.txt"));
  p(fp.join("c:/apps", "dart/dart-sdk"));
  p(fp.expandPath("c:/t_/../apps/dart"));
}
}
```

When the code above is run, the output is the following:

```
"..\\publish\\web\\"
"../publish/web/"
"web.oba"
"web"
"c:/t_/sophia"
".txt"
"c:/apps/dart/dart-sdk"
"c:/apps/dart"
```

======

I hope you will enjoy it!

Thanks to Ruby for showing us such a treat in the first place.









