library corsac_stateless.test.data_gateway;

import 'package:test/test.dart';
import 'package:corsac_stateless/corsac_stateless.dart';

void main() {
  group('InMemoryDataGateway:', () {
    test('it can filter entities by single field', () {
      var dg = new UserInMemoryDataGateway();
      dg.put(new User(1, 'John', 'Sales'));
      dg.put(new User(2, 'Mike', 'Sales'));
      var user = dg.findByName('John');
      expect(user, new isInstanceOf<User>());
      expect(user.name, equals('John'));
    });

    test('it throws error if entity not found when querying for single item',
        () {
      var dg = new UserInMemoryDataGateway();
      dg.put(new User(1, 'John', 'Sales'));
      expect(() => dg.findByName('Bill'), throwsStateError);
    });

    test('it can return collections of entities', () {
      var dg = new UserInMemoryDataGateway();
      dg.put(new User(1, 'John', 'Sales'));
      dg.put(new User(2, 'Mike', 'Sales'));
      var productGuy = new User(3, 'Mike', 'Product');
      dg.put(productGuy);
      var result = dg.findByDepartment('Sales');
      expect(result, new isInstanceOf<Iterable>());
      expect(result, hasLength(2));
      expect(result, isNot(contains(productGuy)));
      expect(result.first.name, equals('John'));
      expect(result.last.name, equals('Mike'));
    });
  });
}

class User {
  final int id;
  final String name;
  final String department;

  User(this.id, this.name, this.department);
}

abstract class UserQueryModel {
  User findByName(String name);
  List<User> findByDepartment(String department);
}

class UserInMemoryDataGateway extends InMemoryDataGateway<User>
    implements UserQueryModel {}
