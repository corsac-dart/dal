library corsac_stateless.in_memory.tests;

import 'package:test/test.dart';
import 'package:corsac_stateless/in_memory.dart';
import 'package:corsac_stateless/corsac_stateless.dart';

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

  group('In-memory Repository Container Middleware', () {
    test('it', () {
      var m = new InMemoryRepositoryContainerMiddleware();
      var result = m.get(Repository, null);
      expect(result, new isInstanceOf<InMemoryRepository>());
    });
  });
}

class User {
  final int id;
  final String name;

  User(this.id, this.name);
}
