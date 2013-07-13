import "../lib/lang.dart";


main() {
  var s = "   ", a = ["   ", "bee", "   "]; // Only spaces
  print("'s' using just the print command: ${s}");
  print("'s' using inspect within the print command: ${inspect(s)}");
  print("'a' using just the print command:");
  print(a);
  print("'a' using the p (printInspect) command:");
  p(a);
}

