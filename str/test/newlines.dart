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
