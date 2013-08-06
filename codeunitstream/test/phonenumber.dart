import "../../lang/lib/lang.dart";
import "../lib/codeunitstream.dart";


genSample1() => "(123)456-7890";
genSample2() => "(123)456-7890\n554-0213";
genSample3() => "123445";
genSample4() => "ass323-2445ff";
genSample5() => "(123)1456-78901\n9554-02139";
genSample6() => "(23)456-781\n94-31139";
genSample7() => "012345678901234567890";
genSample8() => "1010-2314987-07541";

leanerParsePhones(stream) {
  // 40 - open paren
  openParenOrDigit(c) => (c == 40 || (c >= 48 && c <= 57)) ? c : -1;
  localArea(o) {
    return o.eatDigit() &&
      o.eatDigit() &&
      o.eatMinus() &&
      o.eatDigit() &&
      o.eatDigit() &&
      o.eatDigit() &&
      o.eatDigit();
  }
  areaCode(o) {
    return o.eatDigit() &&
      o.eatDigit() &&
      o.eatDigit() &&
      o.eatCloseParen() &&
      o.eatDigit() && localArea(o);
  }
  while (!stream.isEol) {
    //p(stream);
    if (stream.seekContext(openParenOrDigit)) {
      if (stream.eatOpenParen()) {
        if (stream.maybeEat(areaCode)) {
          p(["namaste", stream.collectTokenString()]);
        }
      } else if (stream.eatDigit() && stream.maybeEat(localArea)) {
        p(["yat", stream.collectTokenString()]);
      }
    } else {
      break;
    }
  }
}

parsePhones(stream) {
  // 40 - open paren
  openParenOrDigit(c) => (c == 40 || (c >= 48 && c <= 57)) ? c : -1;
  localArea(o) {
    return o.keepMilestoneIfNot(o.eatDigit) &&
      o.keepMilestoneIfNot(o.eatDigit) &&
      (o.eatMinus() || o.yankMilestoneIfNot(o.eatDigit)) &&
      o.keepMilestoneIfNot(o.eatDigit) &&
      o.keepMilestoneIfNot(o.eatDigit) &&
      o.keepMilestoneIfNot(o.eatDigit) &&
      o.keepMilestoneIfNot(o.eatDigit);
  }
  areaCode(o) {
    return o.keepMilestoneIfNot(o.eatDigit) &&
      o.keepMilestoneIfNot(o.eatDigit) &&
      o.keepMilestoneIfNot(o.eatDigit) &&
      (o.eatCloseParen() || o.yankMilestoneIfNot(o.eatDigit)) &&
      o.keepMilestoneIfNot(o.eatDigit) && localArea(o);
  }
  while (!stream.isEol) {
    //p(stream);
    if (stream.seekContext(openParenOrDigit)) {
      if (stream.eatOpenParen()) {
        if (stream.maybeEat(areaCode)) {
          p(["namaste", stream.collectTokenString()]);
        }
      } else if (stream.eatDigit() && stream.maybeEat(localArea)) {
        p(["yat", stream.collectTokenString()]);
      }
    } else {
      break;
    }
  }
}

main() {
  var sample = genSample8();
  
  p("verbose");
  // keep milestone to try to optimize a little. too verbose
  parsePhones(new CodeUnitStream(text: sample));
  
  p("leaner");
  // one version that's leaner which worries less about optimization
  leanerParsePhones(new CodeUnitStream(text: sample));
}



