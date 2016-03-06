/// DI bindings for repository layer.
library corsac_stateless.di;

import 'dart:mirrors';

import 'package:corsac_di/corsac_di.dart';
import 'package:corsac_stateless/corsac_stateless.dart';

class RepositoryConfiguration {
  final Map<Type, Type> types = new Map();
  void registerRepositoryType(
      Type repositoryType, Type identityMapDecoratorType) {
    if (getEntityType(repositoryType) == dynamic) {
      throw "Entity type of repository can not be dynamic. Please provide concrete type.";
    }
    types[repositoryType] = identityMapDecoratorType;
  }
}

class IdentityMapDIMiddleware implements DIMiddleware {
  final IdentityMap identityMap;
  final RepositoryConfiguration config;

  Map<Type, Repository> _repositoryByEntityType = new Map();

  IdentityMapDIMiddleware(this.identityMap, this.config);

  @override
  resolve(id, DIMiddlewarePipeline next) {
    if (!isRepositoryType(id)) {
      return next.resolve(id);
    }

    var mirror = reflectType(id);
    var entityType = getEntityType(id);
    if (entityType == dynamic) {
      throw "Entity type of repository can not be dynamic. Please provide concrete type.";
    }

    if (_repositoryByEntityType.containsKey(entityType)) {
      var existingRepo = _repositoryByEntityType[entityType];
      throw "Repository for entity ${id} already exists. Existing repository type is ${existingRepo}, you provided ${id}.";
    }

    var entry = next.resolve(id);

    if (mirror.superinterfaces.isEmpty) {
      // means it's base Repository<T> interface
      _repositoryByEntityType[entityType] = entry;

      return new IdentityMapRepositoryDecorator(identityMap, entry, entityType);
    } else if (config.types.containsKey(id)) {
      _repositoryByEntityType[entityType] = entry;
      var decoratorMirror = reflectClass(config.types[id]);

      return decoratorMirror
          .newInstance(const Symbol(""), [identityMap, entry]).reflectee;
    } else {
      throw "Could not decorate repository type ${id}. Should be registered with RepositoryConfiguration.";
    }
  }
}

/// Replaces all repositories requested from the DI container with
/// [InMemoryRepository] implementation which can be used for early development
/// and/or in tests.
class InMemoryRepositoryDIMiddleware implements DIMiddleware {
  @override
  resolve(id, DIMiddlewarePipeline next) {
    if (isRepositoryType(id)) {
      if (getEntityType(id) == dynamic) {
        throw 'Entity type of repository can not be dynamic. Please provide concrete type.';
      }
      // TODO: waiting on a fix for `reflectClass` to be able to set type argument for a generic class.
      // See https://github.com/dart-lang/sdk/issues/12921 for details.
      return new InMemoryRepository();
    }
    return next.resolve(id);
  }
}
