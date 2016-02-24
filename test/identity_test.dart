library corsac_stateless.test;

import 'package:test/test.dart';
import 'package:corsac_stateless/corsac_stateless.dart';

void main() {
  group('Identity:', () {
    test('it can fetch identity from `id` field', () {
      var entity = new User(584, 'Example');
      var id = entityId(entity);
      expect(id, equals(584));
    });

    test('it can fetch identity from annotated field', () {
      var entity = new Account('35342', 'Example');
      var id = entityId(entity);
      expect(id, equals('35342'));
    });
  });
}

class User {
  final int id;
  final String name;

  User(this.id, this.name);
}

class Account {
  @identity
  final String twitterId;
  final String name;

  Account(this.twitterId, this.name);
}
