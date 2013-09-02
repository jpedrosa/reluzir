import "../../lang/lib/lang.dart";
import "../lib/dir.dart";

genSample1() => "**/*.dart";

genSample10() => "c:/t_/*";

genSample20() => "c:/t_/**/";

genSample30() => "c:/t_/**/*.dart";

genSample40() => "c:/t_/**/*dm";

genSample50() => "c:/t_/**/web";

genSample60() => "c:/t_/**/*dm*";

genSample70() => "c:/t_/ruby-1.9.3-rc1/**/*.rb";

genSample80() => "c:/t_/ruby-1.9.3-rc1/**/tool*";

genSample90() => "c:/t_/ruby-1.9.3-rc1/**/*.?";

genSample100() => "c:/t_/ruby-1.9.3-rc1/**/?????";

genSample110() => "c:/t_/r*";

genSample120() => "c:/t_/r*/r*";

genSample130() => "c:/t_/r*/r*/**/";

genSample140() => "c:/t_/r*/r*/**/r*";

genSample150() => "c:/t_/r*/r*/**/r*/r*";

genSample160() => "c:/t_/**/*.rb";

genSample170() => "c:/t_/r*/r*/**/s*/r*";

genSample180() => "c:/t_/r*/r*/**/s*/**/r*";

genSample190() => "c:/t_/**/r*/s*/**/r*";

genSample200() => "c:/t_/**/r*/**/s*/**/r*";

genSample210() => "c:/t_/**/*.{dart,html}";

genSample220() => "c:/t_/**/*_{en,ja}*";

genSample230() => "c:/t_/**/*.[ch]";

genSample240() => "c:/t_/**/*.{c,h}";

genSample250() => "c:/t_/**/*.[a-z]";

genSample260() => "c:/t_/**/*.[0-9]";

genSample270() => "c:/t_/**/*.[^0-9]";

genSample280() => "c:/t_/**/*.[^a-z]";

genSample290() => "c:/t_/**/*[0-9]";

genSample300() => "c:/t_/**/image*[0-9]";

genSample310() => "c:/t_/**/image*";

genSample320() => "c:/t_/**/image*[^0-9]";

genSample330() => "c:/t_/**/*.[a-z][a-z]";

genSample340() => "c:/t_/**/*?";

genSample350() => "c:/t_/**/*";

genSample360() => "c:/t_/**/*??????????";

genSample370() => "c:/t_/Virtual City/t1/*[0-9]";

genSample380() => "c:/t_/**/*[^0-9]";

genSample390() => "c:/t_/Virtual City/t2/*[^0-9]";

genSample400() => "c:/t_/**/??????????*";

genSample410() => "c:/t_/**/[a-z]?[a-z]";

genSample420() => "c:/t_/**/[a-z]*[a-z]";

genSample430() => "../../../**/";

genSample440() => "c:/t_/**/[^a-zA-Z0-9]*";

genSample450() => "c:/t_/**/[A-Z]*";

genSample460() => "c:/**/*";

genSample470() => "c:/Windows/**/";

genSample480() => "c:/Windows/**/*";

genSample490() => "c:/t_/*/**/*";

genSample500() => "../*";

main() {
  var a = Dir[genSample500()], e;
  p("Number of matching files: ${a.length}");
  for (e in a) {
    p(e);
    //print(e.path);
  }
}





