import "../lib/parsedict.dart";


main() {
  var sample = r"""
{'abrac\'a': 'dabra','Dart':'Rocks'}
""";
  var k, dict = ParseDict.parse(sample);
  for (k in dict.keys) {
    print("${k}:${dict[k]}");
  }
}

