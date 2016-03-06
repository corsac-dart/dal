library corsac_stateless.tests.criteria;

import 'package:corsac_stateless/corsac_stateless.dart';
import 'package:test/test.dart';

void main() {
  group('Criteria:', () {
    test('it builds conditions', () async {
      var criteria = new Criteria<User>();
      criteria.where((u) => u.id == 1);
      expect(criteria.conditions, isNotEmpty);
      expect(criteria.conditions, hasLength(1));
      EqualsCondition c = criteria.conditions.first;
      expect(c, new isInstanceOf<EqualsCondition>());
      expect(c.key, equals('id'));
      expect(c.value, equals(1));
    });
  });
}

class User {
  final int id;

  User(this.id);
}
