Str
===

Str is a library dedicated to generic String methods.

Here's a sample:

```dart
import "../lib/str.dart";
import "../../lang/lib/lang.dart";


main() {
  var sample = "first\nsecond\nthird", i = Str.indexOfNewLine(sample),
    lineCount = 1;
  while (i >= 0) {
    lineCount++;
    i = Str.indexOfNewLine(sample, i + 1);
  }
  p("Line count: ${lineCount}");
}
```

indexOfNewLine is a speedier newline matcher on the Dart VM. The original idea was by Alex Tatumizer of the Dart misc group.

