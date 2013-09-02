library Parser;

import "../../lang/lib/lang.dart";


class ParserStatus {
  
  var parser, spaceParser, commentParser, stored;
  
  ParserStatus({this.parser, this.spaceParser, this.commentParser}) {
    stored = [];
  }
  
  clone() {
    var o = new ParserStatus(parser: parser,
      spaceParser: spaceParser,
      commentParser: commentParser),
      len = stored.length;
    if (len > 0) {
      var a = o.stored, i;
      for (i = 0; i < len; i++) {
        a.add(stored[i]);
      }
    }
    return o;
  }
  
  push(t) {
    stored.add(t);
  }
  
  pop() => stored.removeLast();
  
  unshift(e) {
    stored.insert(0, e);
  }
  
  shift() {
    var e = stored[0];
    stored.removeAt(0);
    return e;
  }
  
  operator == (other) {
    var space = spaceParser, otherSpace = other.spaceParser,
      comment = commentParser, otherComment = other.commentParser,
      a = stored, otherA = other.stored;
    return parser.toString() == other.parser.toString() &&
      ((space == null && otherSpace == null) || (space != null &&
      otherSpace != null && space.toString() == otherSpace.toString())) &&
      ((comment == null && otherComment == null) || (comment != null &&
      otherComment != null &&
      comment.toString() == otherComment.toString())) &&
      (a.length == otherA.length && a.toString() == otherA.toString());
  }
  
  get hashCode => "ParserStatus(parser: ${parser}, "
      "spaceParser: ${spaceParser}, "
      "commentParser: ${commentParser}, "
      "stored: ${stored.toString()})".hashCode;
  
  toString() {
    return "ParserStatus(parser: ${parser}, "
        "spaceParser: ${spaceParser}, "
        "commentParser: ${commentParser}, "
        "stored: ${inspect(stored)})";
  }
  
}


