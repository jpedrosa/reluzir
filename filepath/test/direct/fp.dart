
import "../../lib/filepath.dart";
import "../../../lang/lib/lang.dart";


main() {
  var fp = new FilePath(windows: true);/*
  //p(fp.ensureWindowsPath("../publish/web/"));
  p(fp.baseName("../publish/web.oba/"));
  p(fp.baseName("../publish/web.oba/", ".oba"));
  p(fp.baseName("../publish/web.oba/", "oba"));
  p(fp.baseName("a"));
  p(fp.baseName("a/"));
  //p(fp.dirName("../publish/web.oba/"));
  //p(fp.dirName("b"));
  p(fp.dirName("/c:"));
  p(fp.dirName("\\\\c:"));
  p(fp.dirName("c://///"));
  p(fp.dirName("c:"));
  p(fp.extName("c:/t_/afile.txt"));
  p(fp.extName("b.a..."));
  p(fp.extName("c:/t_/afile.txt.two"));
  p(fp.extName(".ignore"));
  p(fp.extName("c:/t_/.y."));
  p(fp.extName(".y."));
  p(fp.join("a///////", "\\b"));*/
  //p(fp.expandPath("c:/t_/../apps/dart"));
  p(fp.expandPath("c:\\"));
  p(fp.expandPath("c:\\t_\\"));
  p(fp.expandPath("/ale/./.././le/bleu"));
  //p(fp.expandPath("c:/Program Files/.."));
  //p(fp.expandPath("c:/t_/../apps"));
  //p(fp.expandPath("c:/t_/./apps"));
  //p(fp.expandPath("c:/t_/.../abc"));
  //p(fp.expandPath("../ab/cd/../ef/.."));
  p(fp.ensureLinuxPath("..\\publish\\web/"));
  p(fp.ensureOsPath("..\\publish\\web/"));
}

