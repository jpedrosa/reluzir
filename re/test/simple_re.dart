import "../lib/re.dart";
import "../../lang/lib/lang.dart";


main() {
  p(RE);
  p(RE[r"\s"]);
  p(RE[r"\s"].match("s s"));
  p(REi[r"a((b)(c))"].test("zABCz"));
  p(REi[r"a((b)(c))"].match("zABCz"));
  p(REi[r"a((b)(c))"].firstMatch("=-yt"));
  p(RE[r".(.)"].matchAll("zABCz"));
  p(RE[r".(.)"].exec("zABCz"));
  p(RE[r".(.)"].matchAt("zABCz", 1));
  p(REm[r"^\w\w"].matchAll("""
zABCz
zDEFz
zGHIz
"""));
  p(REmi[r"^[a-z]([a-z])"].matchAll("""
zABCz
zDEFz
zGHIz
"""));
  p(REi[r"^[a-z]([a-z])"].matchAll("""
zABCz
zDEFz
zGHIz
"""));
}

