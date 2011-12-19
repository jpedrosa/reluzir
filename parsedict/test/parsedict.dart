#import("../lib/parsedict.dart");


main() {
  var sample = """
{'abrac\\'a': 'draba','Dart':'Rocks'}
""";
  var k, dict = ParseDict.parse(sample);
  for (k in dict.getKeys()) {
    print("${k}:${dict[k]}");
  }
}

