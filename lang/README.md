Lang is a small library that adds some core language extensions to Dart.

It's more of a language extension because the methods are important for development purposes across libraries and also because the methods are added to the outer scope.

==============

The inspect method was inspired by Ruby's own version of it. The main idea is that the String returned by it is more detailed. The String wraps content into their appropriate formats so they help to tell a more complete story about their actual content. Say if the String has just spaces, but if it comes between delimiters, we can tell where the spaces are, otherwise we'd have to try to guess.

```dart
String inspect(v)

void printInspect(v)

void p(v)
```

A simple test for them:


```dart
import "../lib/lang.dart";


main() {
  var s = "   ", a = ["   ", "bee", "   "]; // Only spaces
  print("'s' using just the print command: ${s}");
  print("'s' using inspect within the print command: ${inspect(s)}");
  print("'a' using just the print command:");
  print(a);
  print("'a' using the p (printInspect) command:");
  p(a);
}
```

It prints this once run:

```
's' using just the print command:    
's' using inspect within the print command: "   "
'a' using just the print command:
[   , bee,    ]
'a' using the p (printInspect) command:
["   ", "bee", "   "]
```

One anecdote about the "p" command in Ruby is that some core Ruby developer said he was hooked into Ruby because of it.

In Ruby "p" also prints inspect details about instances and so on without us having to give them proper "toString()" support. In Dart it's less straightforward.

RespondTo was born from a need to check whether some instance had some method when I converted a library of mine from JavaScript to Dart. In JavaScript that kind of checking doesn't result in an exception.

```dart
bool respondTo(fn())
```

A test with respondTo:

```dart
import "../lib/lang.dart";


class A {
  
  var names, moreInfo;
  
  A() {
    names = ["Ella", "Junior"];
    moreInfo = {"Ella": {"email": "foo@gmail.com"},
      "Junior": {"email": "bar@gmail.com"}};
  }
  
}


main() {
  var a = new A();
  p("Respond to moreInfo? ${respondTo(() => a.moreInfo)}");
  p("Respond to muchMoreInfo? ${respondTo(() => a.muchMoreInfo)}");
  p(a.names);
  p(a.moreInfo);
}
```

Once run it prints:

```
"Respond to moreInfo? true"
"Respond to muchMoreInfo? false"
["Ella", "Junior"]
{"Ella": {"email": "foo@gmail.com"}, "Junior": {"email": "bar@gmail.com"}}
```

As Dart doesn't have support for undefined number of arguments, one trick is to create a literal list or array yourself for the arguments. Like so:

```dart
p(["description", vFoo, sBar]);
```

I often use this trick when debugging. But I also use a higher level version of "p" that prints content on the web page in a debugging window created with a div. This other method is short enough called "DR.p", though it's not part of this Lang library as it's more dependent on the browser.

The Lang library is useful for either browser or command-line programming.
