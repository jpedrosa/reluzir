import "../../lang/lib/lang.dart";
import "../lib/codeunitstream.dart";


genSample1() => "378px 655c 179degrees";
genSample2() => "year 1";
genSample3() => "despite";

scanForDigits(cus) {
  while (!cus.isEol) {
    p(cus);
    if (cus.seekContext((c) => (c >= 48 && c <= 57) ? c : -1) &&
        cus.eatWhileDigit()) {
      p(cus.collectTokenString());
    } else {
      break;
    }
  }
}

main() {
  var sample = genSample1();
  scanForDigits(new CodeUnitStream(text: sample));
}



