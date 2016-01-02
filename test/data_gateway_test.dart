library corsac_stateless.test.data_gateway;

import 'package:test/test.dart';
import 'package:corsac_stateless/corsac_stateless.dart';

void main() {
  group('InMemoryDataGateway:', () {
    test('it can get entities by id', () async {
      var dg = new UserInMemoryDataGateway();
      dg.put(new User(1, 'John', 'Sales'));
      dg.put(new User(2, 'Mike', 'Sales'));
      var user = await dg.get(1);
      expect(user, new isInstanceOf<User>());
      expect(user.name, equals('John'));
    });

    test('it throws error if entity not found when querying for single item',
        () {
      var dg = new UserInMemoryDataGateway();
      dg.put(new User(1, 'John', 'Sales'));
      expect(() => dg.get(2), throwsStateError);
    });
  });
}

class User {
  final int id;
  final String name;
  final String department;

  User(this.id, this.name, this.department);
}

class UserInMemoryDataGateway extends InMemoryDataGateway<User> {}
