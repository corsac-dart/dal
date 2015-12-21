library corsac_stateless.test;

import 'package:test/test.dart';
import 'package:corsac_stateless/corsac_stateless.dart';
import 'test_model.dart';

void main() {
  group('Test model:', () {
    test('it stores entities', () async {
      var idMap = new IdentityMap();
      var dg = new UserInMemoryDataGateway();
      var repo = new UserRepository(idMap, dg);

      repo.add(new User(1, 'John'));
      var user = repo.findById(1);
      expect(user, new isInstanceOf<User>());
      expect(idMap.has(User, 1), isTrue);
      expect(idMap.get(User, 1), same(user));

      idMap = new IdentityMap();
      repo = new UserRepository(idMap, dg);
      user = repo.findById(1);
      expect(user, new isInstanceOf<User>());
      expect(idMap.has(User, 1), isTrue);
    });

    test('it forwards query method calls to the storage', () async {
      var idMap = new IdentityMap();
      var repo = new UserRepository(idMap, new UserInMemoryDataGateway());

      repo.add(new User(1, 'John'));
      var user = repo.findByName('John');
      expect(user, new isInstanceOf<User>());
      expect(idMap.get(User, 1), same(user));
    });
  });
}
