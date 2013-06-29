library run_bench;
import "../lib/parsedict.dart";
source "sample.dart";


main() {
  var sample = ParseDictBench.loadSample();
  var k, dict = ParseDict.parse(sample);
  for (k in dict.keys) {
    print("${k}:${dict[k]}");
  }
}

