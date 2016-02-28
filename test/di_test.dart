library corsac_stateless.di.tests;

import 'package:test/test.dart';
import 'package:corsac_di/corsac_di.dart';
import 'package:corsac_stateless/in_memory.dart';
import 'package:corsac_stateless/corsac_stateless.dart';
import 'package:corsac_stateless/di.dart';
import 'dart:mirrors';

void main() {
  group('IdentityMapContainerMiddleware:', () {
    IdentityMap idMap;
    DIContainer container;

    setUp(() {
      idMap = new InMemoryIdentityMap();
      container = new DIContainer();
      var config = new RepositoryConfiguration();
      config.registerRepositoryType(
          UserRepository, UserRepositoryIdentityCacheDecorator);
      container
          .addMiddleware(new IdentityMapContainerMiddleware(idMap, config));
      container.addMiddleware(new InMemoryRepositoryContainerMiddleware());
    });

    test('it decorates repositories with identity caching decorator', () {
      execute((Repository<User> repo, Repository<Account> repo2) {
        expect(repo, new isInstanceOf<RepositoryIdentityCacheDecorator>());
        expect(repo2, new isInstanceOf<RepositoryIdentityCacheDecorator>());
        expect(repo, isNot(same(repo2)));
      }, container);
    });

    test('it only allows one repository implementation per entity type', () {
      expect(() {
        execute((Repository<User> repo, UserRepository repo2) {}, container);
      }, throws);
    });

    test('it supports subclasses of repository interface via configuration.',
        () {
      execute((Repository<Account> repo, UserRepository repo2) {
        expect(repo, new isInstanceOf<RepositoryIdentityCacheDecorator>());
        expect(repo2, new isInstanceOf<UserRepositoryIdentityCacheDecorator>());
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

abstract class UserRepository implements Repository<User>, BatchOperations {}

class UserRepositoryIdentityCacheDecorator
    extends RepositoryIdentityCacheDecorator implements UserRepository {
  UserRepositoryIdentityCacheDecorator(
      IdentityMap identityMap, Repository repository)
      : super(identityMap, repository);
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
