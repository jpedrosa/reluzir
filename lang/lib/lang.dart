library Lang;


String inspect(v) {
  var s;
  if (v is String) {
    var mirror = v.codeUnits, i, len = mirror.length, a, c;
    for (i = 0; i < len; i++) {
      c = mirror[i];
      switch (c) {
      case 10: // "
        if (a == null) { a = mirror.sublist(0, i); }
        a.add(92); // \
        a.add(110); // n
        break;
      case 34: // "
        if (a == null) { a = mirror.sublist(0, i); }
        a.add(92); // \
        a.add(c); // "
        break;
      case 92: // \
        if (a == null) { a = mirror.sublist(0, i); }
        a.add(92); // \
        a.add(c); // \
        break;
      default:
        if (a != null) { a.add(c); }
        break;
      }
    }
    s = a != null ? new String.fromCharCodes(a) : v;
    s = '"${s}"';
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




