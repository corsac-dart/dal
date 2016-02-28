/// DI bindings for repository layer.
library corsac_stateless.di;

import 'dart:mirrors';

import 'package:corsac_di/corsac_di.dart';
import 'package:corsac_stateless/corsac_stateless.dart';

class RepositoryConfiguration {
  final Map<Type, Type> types = new Map();
  void registerRepositoryType(
      Type repositoryType, Type identityMapDecoratorType) {
    var mirror = reflectType(repositoryType);
    if (_locateEntityType(mirror) == dynamic) {
      throw "Entity type of repository can not be dynamic. Please provide concrete type.";
    }
    types[repositoryType] = identityMapDecoratorType;
  }
}

Type _locateEntityType(ClassMirror repoMirror) {
  if (repoMirror.typeArguments.isNotEmpty) {
    return repoMirror.typeArguments.first.reflectedType;
  } else {
    return repoMirror.superinterfaces
        .firstWhere((m) => m.isSubtypeOf(reflectType(Repository)))
        .typeArguments
        .first
        .reflectedType;
  }
}

class IdentityMapContainerMiddleware implements DIContainerMiddleware {
  final IdentityMap identityMap;
  final RepositoryConfiguration config;

  Map<Type, Repository> _repositoryByEntityType = new Map();

  IdentityMapContainerMiddleware(this.identityMap, this.config);

  @override
  get(id, DIMiddlewarePipeline next) {
    if (!isRepositoryType(id)) {
      return next.get(id);
    }

    var mirror = reflectType(id);
    var entityType = _locateEntityType(mirror);
    if (entityType == dynamic) {
      throw "Entity type of repository can not be dynamic. Please provide concrete type.";
    }

    if (_repositoryByEntityType.containsKey(entityType)) {
      var existingRepo = _repositoryByEntityType[entityType];
      throw "Repository for entity ${id} already exists. Existing repository type is ${existingRepo}, you provided ${id}.";
    }

    var entry = next.get(id);

    if (mirror.superinterfaces.isEmpty) {
      // means it's base Repository<T> interface
      _repositoryByEntityType[entityType] = entry;

      return new RepositoryIdentityCacheDecorator(identityMap, entry);
    } else if (config.types.containsKey(id)) {
      _repositoryByEntityType[entityType] = entry;
      var decoratorMirror = reflectClass(config.types[id]);

      return decoratorMirror
          .newInstance(const Symbol(""), [identityMap, entry]).reflectee;
    } else {
      throw "Could not decorate repository type ${id}. Should be registered with RepositoryConfiguration.";
    }
  }

  bool isRepositoryType(id) {
    return (id is Type)
        ? reflectType(id).isSubtypeOf(reflectType(Repository))
        : false;
  }
}
