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

/// Repository which stores entities in memory.
class InMemoryRepository<T> implements Repository<T> {
  final Set<T> items = new Set();

  @override
  Future<T> get(id) {
    var item = items.firstWhere((i) => entityId(i) == id, orElse: () => null);
    return new Future.value(item);
  }

  @override
  Future put(T entity) {
    items.add(entity);
    return new Future.value();
  }
}

class InMemoryRepositoryContainerMiddleware implements DIContainerMiddleware {
  @override
  get(id, DIMiddlewarePipeline next) {
    if (id is Type) {
      var mirror = reflectClass(id);
      if (mirror.isSubclassOf(reflectClass(Repository))) {
        return new InMemoryRepository();
      } else {
        return next.get(id);
      }
    } else {
      return next.get(id);
    }
  }
}
