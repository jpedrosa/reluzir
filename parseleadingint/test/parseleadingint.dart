import "../lib/parseleadingint.dart";


main() {
  var a = ["0", 0,
    "-1", -1,
    "2px", 2,
    "-3px", -3,
    "41", 41,
    "52px", 52,
    "987", 987,
    "-654px", -654,
    ], i, e, r, len = a.length;
  for (i = 0; i < len; i += 2) {
    e = a[i + 1];
    r = ParseLeadingInt.parse(a[i]);
    print("Test for '${a[i]}' expect ${e}: ${r} (${e == r})");
  }
  ["-", "-ab", "ab", ""].forEach((s) {
    r = ParseLeadingInt.parse(s, orZero: true);
    print("Test for '${s}' expect 0: ${r} (${0 == r})");
  });
}


