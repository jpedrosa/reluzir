import "../../lang/lib/lang.dart";
import "../lib/codeunitstream.dart";


genStream(sample) {
  return new CodeUnitStream(text: sample);
}

main() {
  p(genStream("abcdef").matchWhileNotString("bc"));
  p(genStream("abcdef").matchWhileNotString("bcdef"));
  p(genStream("bcabcdef").matchWhileNotString("bcdef"));
  p(genStream("bcdeabcdef").matchWhileNotString("bcdef"));
}



