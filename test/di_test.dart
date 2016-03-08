library corsac_stateless.di.tests;

import 'dart:mirrors';

import 'package:corsac_di/corsac_di.dart';
import 'package:corsac_stateless/corsac_stateless.dart';
import 'package:corsac_stateless/di.dart';
import 'package:test/test.dart';

void main() {
  group('Repository types:', () {
    test(
        'only reference to Repository interface directly is treated as a valid type',
        () {
      expect(isRepositoryType(Repository), isTrue);
      expect(isRepositoryType(const diType<Repository<User>>().type), isTrue);
      expect(isRepositoryType(UserRepository), isFalse);
      expect(isRepositoryType(UserMysqlRepository), isFalse);
    });
  });

  group('In-memory Repository Container Middleware', () {
    test('it resolves repositories to in-memory implementation', () {
      var m = new InMemoryRepositoryDIMiddleware();
      var t = const diType<Repository<User>>();
      var result = m.resolve(t.type, null);
      expect(result, new isInstanceOf<InMemoryRepository>());
    });
  });

  group('IdentityMapDIMiddleware:', () {
    IdentityMap idMap;
    DIContainer container;

    setUp(() {
      var config = {
        const diType<Repository<Account>>():
            DI.get(const diType<InMemoryRepository<Account>>()),
      };
      idMap = new InMemoryIdentityMap();
      container = new DIContainer.build([config]);
      container.addMiddleware(new IdentityMapDIMiddleware(idMap));
    });

    test('it decorates repositories with identity caching decorator', () {
      execute((Repository<Account> repo) {
        expect(repo, new isInstanceOf<IdentityMapRepositoryDecorator>());
        expect((repo as IdentityMapRepositoryDecorator).repository,
            new isInstanceOf<InMemoryRepository<Account>>());
      }, container);
    });

    // May change in the future!
    test('it does not resolve subclasses of repository interface', () {
      expect(() {
        execute((UserRepository repo2) {}, container);
      }, throws);
    });

    test('it does not allow dynamic type argument on repositories', () {
      expect(() {
        execute((Repository repo) {}, container);
      }, throwsArgumentError);
    });
  });
}

class User {}

class Account {}

abstract class UserRepository implements Repository<User> {}

class UserMysqlRepository extends UserRepository {
  @override noSuchMethod(Invocation invocation) {}
}

class UserIdentityMapRepositoryDecorator extends IdentityMapRepositoryDecorator
    implements UserRepository {
  UserIdentityMapRepositoryDecorator(
      IdentityMap identityMap, Repository repository)
      : super(identityMap, repository, User);
}

dynamic execute(Function body, DIContainer container) {
  ClosureMirror mirror = reflect(body);
  var positionalArguments = [];
  for (var param in mirror.function.parameters) {
    if (!param.isNamed) {
      positionalArguments.add(container.get(param.type.reflectedType));
    }
  }
  return mirror.apply(positionalArguments).reflectee;
}
