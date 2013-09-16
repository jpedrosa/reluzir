import "../../lang/lib/lang.dart";
import "../lib/io.dart";
import "../lib/file.dart";


main() {
  var af, fruits = ["Banana\n", "Grapes\n", "Watermelon"];
//File.open("c:/t_/d2.txt", "w") {|f| f.puts fruits } Ruby version
  af = File.open("fruits_sample.txt", "w", (f) => f.puts(fruits));
  /*af = File.open("fruits_sample.txt", "a", (f) { // "a" mode for appending.
    f << "Banana\n" << "Grapes\n" << "Watermelon\n";
  });
  af = File.open("fruits_sample.txt", "w", (f) {
    f << "Banana\n" << "Grapes\n" << "Watermelon\n";
  });*/
  p("File path: ${af.path}");
  var a = IO.readLines("fruits_sample.txt"), e;
  p(a.length);
  for (e in a) {
    p(e);
  }
  a = IO.readLines("stored_fruits_sample.txt");
  p(a.length);
  for (e in a) {
    p(e);
  }
}





