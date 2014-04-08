
import "../../lib/filepath.dart";
import "../../../lang/lib/lang.dart";


main() {
  var fp = new FilePath();
  p(fp.ensureWindowsPath("../publish/web/"));
  p(fp.ensureLinuxPath("..\\publish\\web/"));
  p(fp.baseName("../publish/web.oba/"));
  p(fp.baseName("../publish/web.oba/", ".oba"));
  p(fp.dirName("c:/t_/sophia/afile.txt"));
  p(fp.extName("c:/t_/afile.txt"));
  p(fp.join("c:/apps", "dart/dart-sdk"));
  p(fp.expandPath("c:/t_/../apps/dart"));
  p(fp.isRootPath("W:/tres/bien"));
}

