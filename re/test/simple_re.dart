import "../lib/re.dart";
import "../../lang/lib/lang.dart";


main() {
  p(RE);
  p(RE[r"\s"]);
  p(RE[r"\s"].match("s s"));
  p(REi["a((b)(c))"].test("zABCz"));
  p(REi["a((b)(c))"].match("zABCz"));
  p(REi["a((b)(c))"].firstMatch("=-yt"));
  p(RE[".(.)"].matchAll("zABCz"));
  p(RE[".(.)"].exec("zABCz"));
  p(RE[".(.)"].matchAt("zABCz", 1));
  p(REm[r"^\w\w"].matchAll("""
zABCz
zDEFz
zGHIz
"""));
  p(REmi["^[a-z]([a-z])"].matchAll("""
zABCz
zDEFz
zGHIz
"""));
  p(REim["^[a-z]([a-z])"].matchAll("""
zABCz
zDEFz
zGHIz
"""));
  p(REi["^[a-z]([a-z])"].matchAll("""
zABCz
zDEFz
zGHIz
"""));
}

