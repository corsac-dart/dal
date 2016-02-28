/// Generic in-memory repository implementation.
///
/// This implementation can be used for testing purposes or in early stages
/// of development.
///
/// The [InMemoryRepository] is not safe to use for concurrent tests.
library corsac_stateless.in_memory;

import 'dart:async';

import 'package:corsac_stateless/corsac_stateless.dart';
import 'package:corsac_di/corsac_di.dart';
import 'dart:mirrors';

class _StubType {}

/// Repository which stores entities in memory.
class InMemoryRepository implements Repository<_StubType> {
  final Type entityType;
  final Set items = new Set();

  InMemoryRepository(this.entityType);

  @override
  Future get(id) {
    var item = items.firstWhere((i) => entityId(i) == id, orElse: () => null);
    return new Future.value(item);
  }

  @override
  Future put(entity) {
    if (entity.runtimeType != entityType) {
      throw new StateError('Wrong entity type.');
    }
    items.add(entity);
    return new Future.value();
  }
}

class InMemoryRepositoryContainerMiddleware implements DIContainerMiddleware {
  @override
  get(id, DIMiddlewarePipeline next) {
    if (id is Type) {
      var mirror = reflectType(id);
      if (mirror.isSubtypeOf(reflectType(Repository))) {
        var entityType = _locateEntityType(mirror);
        if (entityType == dynamic) {
          throw 'Entity type of repository can not be dynamic. Please provide concrete type';
        }
        return new InMemoryRepository(entityType);
      }
    }
    return next.get(id);
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
