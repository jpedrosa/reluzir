import "../../lang/lib/lang.dart";
import "../lib/codeunitstream.dart";


parseLeadingInt(stream) {
  var n;
  if (stream.eatWhileDigit() || (stream.eatMinus() && stream.eatWhileDigit())) {
    n = int.parse(stream.collectTokenString());
  }
  return n;
}

main() {
  p(parseLeadingInt(new CodeUnitStream(text: "78px")));
  p(parseLeadingInt(new CodeUnitStream(text: "-54px")));
}



