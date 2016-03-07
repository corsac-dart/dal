library corsac_stateless.tests.functions;

import 'dart:mirrors';

import 'package:corsac_stateless/corsac_stateless.dart';
import 'package:test/test.dart';

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

  group('Entity types:', () {
    test('it can resolve entity type from base repository interface', () {
      var f = (Repository<User> repo) {
        var type = getEntityType(
            reflect(repo).type.superinterfaces.first.reflectedType);
        expect(type, equals(User));
      };

      f(new UserRepo());
    });

    test('it can resolve entity type from descendant of Repository interface',
        () {
      var f = (Repository<User> repo) {
        var type = getEntityType(reflect(repo).type.reflectedType);
        expect(type, equals(User));
      };

      f(new UserRepo());
    });

    test('it detects if entity type is not explicitely set (dynamic)', () {
      expect(getEntityType(Repository), dynamic);
      expect(getEntityType(FooRepo), dynamic);
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

class UserRepo implements Repository<User> {
  @override
  noSuchMethod(Invocation invocation) {}
}

@proxy
class FooRepo implements Repository {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
