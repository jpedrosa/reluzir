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



