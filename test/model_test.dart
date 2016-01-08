library corsac_stateless.test;

import 'package:test/test.dart';
import 'package:corsac_stateless/corsac_stateless.dart';
import 'test_model.dart';

void main() {
  group('Repository:', () {
    test('it stores entities', () async {
      var idMap = new InMemoryIdentityMap();
      var dg = new UserInMemoryDataGateway();
      var repo = new UserRepository(idMap, dg);

      repo.put(new User(1, 'John'));
      var user = await repo.get(1);
      expect(user, new isInstanceOf<User>());
      expect(idMap.has(User, 1), isTrue);
      expect(idMap.get(User, 1), same(user));

      idMap = new InMemoryIdentityMap();
      repo = new UserRepository(idMap, dg);
      user = await repo.get(1);
      expect(user, new isInstanceOf<User>());
      expect(idMap.has(User, 1), isTrue);
    });
  });

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

class Account {
  @identity
  final String twitterId;
  final String name;

  Account(this.twitterId, this.name);
}
