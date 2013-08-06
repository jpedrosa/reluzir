library Lang;


String inspect(v) {
  var s;
  if (v is String) {
    var i, len = v.length, a, c;
    for (i = 0; i < len; i++) {
      c = v.codeUnitAt(i);
      if (c == 10 || c == 34 || c == 92) { // \n " \
        break;
      }
    }
    if (i < len) {
      s = v.substring(0, i);
      a = [];
      for (; i < len; i++) {
        c = v.codeUnitAt(i);
        if (c == 10) { // \n
          a.add(92); // \
          a.add(110); // n
        } else if (c == 34 || c == 92) { // " \
          a.add(92); // \
          a.add(c);
        } else {
          a.add(c);
        }
      }
      s = '"${s}${new String.fromCharCodes(a)}"';
    } else {
      s = '"${v}"';
    }
  } else if (v is List) {
    var e, sb = new StringBuffer(), comma = false;
    sb.write("[");
    for (e in v) {
      if (comma) {
        sb.write(', ');
      } else {
        comma = true;
      }
      sb.write(inspect(e));
    }
    sb.write("]");
    s = sb.toString();
  } else if (v is Map) {
    var k, sb = new StringBuffer(), comma = false;
    sb.write("{");
    for (k in v.keys) {
      if (comma) {
        sb.write(', ');
      } else {
        comma = true;
      }
      sb.write(inspect(k));
      sb.write(": ");
      sb.write(inspect(v[k]));
    }
    sb.write("}");
    s = sb.toString();    
  } else if (v is Function) {
    s = 'Function';
  } else if (v is Match) {
    var i, len = v.groupCount + 1, sb = new StringBuffer(), comma = false;
    sb.write('Match(${inspect(v[0])}');
    for (i = 1; i < len; i++) {
      if (comma) {
        sb.write(", ");
      } else {
        sb.write(" ");
        comma = true;
      }
      sb.write("${i}: ${inspect(v[i])}");
    }
    sb.write(')');
    s = sb.toString();
  } else if (v is Iterable) {
    var e, sb = new StringBuffer(), comma = false;
    sb.write("Iterable(");
    for (e in v) {
      if (comma) {
        sb.write(', ');
      } else {
        comma = true;
      }
      sb.write(inspect(e));
    }
    sb.write(")");
    s = sb.toString();
  } else {
    s = '$v';
  }
  return s;
}


void printInspect(v) {
  print(inspect(v)); 
}


void p(v) {
  print(inspect(v));
}


bool respondTo(fn()) {
  var r = true;
  try {
    fn();
  } catch (e) {
    r = false;
  }
  return r;
}


bool get isDartVM => 1.0 is! int;




