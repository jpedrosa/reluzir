import "../lib/re.dart";


runMultipleTimes(fn()) {
  for (var i = 0; i < 10000; i++) {
    fn();
  }
}


bm(desc, fn()) {
  runMultipleTimes(fn); // Warm up some.
  var sw = new Stopwatch();
  sw.start();
  runMultipleTimes(fn);
  sw.stop();
  print("${desc}: ${sw.elapsedMilliseconds}ms");
}


runRawString(String s) {
  var i, mirror = s.codeUnits, len = s.length, mi = -1, r, c;
  for (i = 0; i < len; i++) {
    c = mirror[i];
    if (c >= 48 && c <= 57) {
      if (mi < 0) {
        mi = i;
      }
    } else if (mi >= 0) {
      break;
    }
  }
  if (mi >= 0) {
    r = s.substring(mi, i);
  }
  return r;
}


runDefaultRegExp(s) {
  return new RegExp(r"\d+").firstMatch(s);
}


var reCached = new RegExp(r"\d+");

runDefaultRegExpCached(s) {
  return reCached.firstMatch(s);
}


runDRRegExp(s) {
  return RE[r"\d+"].match(s);
}


main() {
  var sampleData = """
Lorem Ipsum is simply dummy text of the printing and typesetting industry.
Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,
when an unknown printer took a galley of type and scrambled it to make a type
specimen book. It has survived not only five centuries, but also the leap into
electronic typesetting, remaining essentially unchanged. It was popularised in
the 1960s with the release of Letraset sheets containing Lorem Ipsum passages,
and more recently with desktop publishing software like Aldus PageMaker
including versions of Lorem Ipsum.
""";
  bm("runDefaultRegExp", () => runDefaultRegExp(sampleData));
  bm("runDefaultRegExpCached", () => runDefaultRegExpCached(sampleData));
  bm("runRawString", () => runRawString(sampleData));
  bm("runDRRegExp", () => runDRRegExp(sampleData));
  var e = "1500", v1 = runDefaultRegExp(sampleData)[0],
    v2 = runDefaultRegExpCached(sampleData)[0],
    v3 = runRawString(sampleData),
    v4 = runDRRegExp(sampleData)[0];
  print("Litmus test: ${e == v1 && e == v2 && e == v3 && e == v4}");
}






