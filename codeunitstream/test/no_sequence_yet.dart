import "../../lang/lib/lang.dart";
import "../lib/codeunitstream.dart";


genStream(sample) {
  return new CodeUnitStream(text: sample);
}

main() {
  // bc - 98, 99
  p(genStream("abcdef").matchWhileNotSequence([98, 99]));
  
  // bcdef - 98, 99, 100, 101, 102
  p(genStream("abcdef").matchWhileNotSequence([98, 99, 100, 101, 102]));
  p(genStream("bcabcdef").matchWhileNotSequence([98, 99, 100, 101, 102]));
  p(genStream("bcdeabcdef").matchWhileNotSequence([98, 99, 100, 101, 102]));
}



