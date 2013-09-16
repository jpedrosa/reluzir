import "../../lang/lib/lang.dart";
import "../lib/io.dart";


main() {
  var a = IO.readLines("fruits_sample.txt"), e;
  p(a.length);
  for (e in a) {
    p(e);
  }
  p(IO.read("fruits_sample.txt"));
}





