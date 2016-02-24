library corsac_stateless.tests.all;

import 'identity_map_test.dart' as im_test;
import 'identity_test.dart' as identity_test;
import 'in_memory_test.dart' as in_memory_test;

void main() {
  im_test.main();
  identity_test.main();
  in_memory_test.main();
}
