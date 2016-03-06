library corsac_stateless.tests.repository;

import 'package:corsac_stateless/corsac_stateless.dart';
import 'package:test/test.dart';

void main() {
  group('In-memory Repository:', () {
    test('it stores entities', () async {
      var user = new User(341, 'Burt Macklin');
      var repository = new InMemoryRepository();
      repository.put(user);
      var fetchedUser = await repository.get(341);
      expect(fetchedUser, same(user));
      var noSuchUser = await repository.get(12836);
      expect(noSuchUser, isNull);
    });
  });
}

class User {
  final int id;
  final String name;

  User(this.id, this.name);
}
