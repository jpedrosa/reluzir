
ParseLeadingInt is useful when dealing with slightly uncertain int values stored in CSS values of the browser. E.g. "10px".

As a feature it also includes the orZero parameter that when set to true will return zero for strings that don't have a leading int. If onZero is left as false it will raise an exception for strings without a leading int instead.

==========

Test example:

```dart
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
```

Enjoy.

Cheers.

