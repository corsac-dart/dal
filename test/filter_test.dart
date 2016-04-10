library corsac_dal.tests.filter;

import 'package:corsac_dal/corsac_dal.dart';
import 'package:test/test.dart';

void main() {
  group('Filter:', () {
    test('it builds conditions', () async {
      var filter = new Filter<User>();
      filter.where((u) => u.id == 1);
      expect(filter.conditions, isNotEmpty);
      expect(filter.conditions, hasLength(1));
      Condition c = filter.conditions.first;
      expect(c, new isInstanceOf<Condition>());
      expect(c.key, equals('id'));
      expect(c.value, equals(1));
      expect(c.predicate, equals(Condition.EQ));
    });
  });
}

class User {
  final int id;

  User(this.id);
}
