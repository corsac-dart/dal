library corsac_stateless.di.tests;

import 'dart:mirrors';

import 'package:corsac_di/corsac_di.dart';
import 'package:corsac_stateless/corsac_stateless.dart';
import 'package:corsac_stateless/di.dart';
import 'package:test/test.dart';

void main() {
  group('In-memory Repository Container Middleware', () {
    test('it resolves repositories to in-memory implementation', () {
      var m = new InMemoryRepositoryDIMiddleware();
      var result = m.resolve(Repository, null);
      expect(result, new isInstanceOf<InMemoryRepository>());
    }, skip: 'todo');
  });

  group('IdentityMapContainerMiddleware:', () {
    IdentityMap idMap;
    DIContainer container;

    setUp(() {
      idMap = new InMemoryIdentityMap();
      container = new DIContainer();
      var config = new RepositoryConfiguration();
      config.registerRepositoryType(
          UserRepository, UserIdentityMapRepositoryDecorator);
      container.addMiddleware(new IdentityMapDIMiddleware(idMap, config));
      container.addMiddleware(new InMemoryRepositoryDIMiddleware());
    });

    test('it decorates repositories with identity caching decorator', () {
      execute((Repository<User> repo, Repository<Account> repo2) {
        expect(repo, new isInstanceOf<IdentityMapRepositoryDecorator>());
        expect(repo2, new isInstanceOf<IdentityMapRepositoryDecorator>());
        expect(repo, isNot(same(repo2)));
      }, container);
    });

    test('it only allows one repository implementation per entity type', () {
      expect(() {
        execute((Repository<User> repo, UserRepository repo2) {
          print(repo);
          print(repo2);
        }, container);
      }, throws);
    });

    test('it supports subclasses of repository interface via configuration.',
        () {
      execute((Repository<Account> repo, UserRepository repo2) {
        expect(repo, new isInstanceOf<IdentityMapRepositoryDecorator>());
        expect(repo2, new isInstanceOf<UserIdentityMapRepositoryDecorator>());
      }, container);
    });

    test('it does not allow dynamic type argument on repositories', () {
      expect(() {
        execute((Repository repo) {}, container);
      }, throws);
    });
  });
}

class User {}

class Account {}

abstract class UserRepository implements Repository<User> {}

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
