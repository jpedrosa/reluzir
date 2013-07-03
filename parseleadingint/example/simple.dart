import "../lib/parseleadingint.dart";


main() {
  print(ParseLeadingInt.parse("34px"));
  print(ParseLeadingInt.parse("-", orZero: true));
}



