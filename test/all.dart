library corsac_dal.tests.all;

import 'identity_map_test.dart' as im_test;
import 'functions_test.dart' as functions_test;
import 'repository_test.dart' as repository_test;
import 'di_test.dart' as di_test;
import 'criteria_test.dart' as criteria_test;

void main() {
  im_test.main();
  functions_test.main();
  repository_test.main();
  di_test.main();
  criteria_test.main();
}
