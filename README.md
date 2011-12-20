
Reluzir is an umbrella project for several Dart libraries.

Motivation: Dart is a young language with a bright future. So why not use it
more?

=======

ParseDict is a library for parsing Python Dict-like structures. The first
version only covers String keys to String values.

Example:

    #import("../lib/parsedict.dart");

    main() {
      var sample = @"""
    {'abrac\'a': 'dabra','Dart':'Rocks'}
    """;
      var k, dict = ParseDict.parse(sample);
      for (k in dict.getKeys()) {
        print("${k}:${dict[k]}");
      }
    }

=======

LICENSE

Pick one of the three. MIT LICENSE, BSD LICENSE or GPL LICENSE.

=======

About the name.

Reluzir is a Portuguese word that means to sparkle.

The author has seen a comment before mentioning how much easier it can be to
pick a name in a foreign language such as Portuguese for a project. Picking a 
unique English name can be a lot of trouble. So let's go Portuguese! :-)

=======

Author: Joao Pedrosa - joaopedrosa at gmail dot com



