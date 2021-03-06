/// DI bindings for repository layer.
library corsac_dal.di;

import 'dart:mirrors';

import 'package:corsac_di/corsac_di.dart';
import 'package:corsac_dal/corsac_dal.dart';

bool isRepositoryType(id) {
  if (id is! Type) return false;
  var cm = reflectClass(id);
  return cm.isSubtypeOf(reflectType(Repository)) &&
      cm.superclass.reflectedType == Object &&
      cm.superinterfaces.isEmpty;
}

class IdentityMapDIMiddleware implements DIMiddleware {
  final IdentityMap identityMap;

  IdentityMapDIMiddleware(this.identityMap);

  @override
  resolve(id, DIMiddlewarePipeline next) {
    if (!isRepositoryType(id)) {
      return next.resolve(id);
    }

    var entityType = getEntityType(id);
    if (entityType == dynamic) {
      throw new ArgumentError(
          "Entity type of repository can not be dynamic. Please provide concrete type.");
    }

    var entry = next.resolve(id);
    return new IdentityMapRepositoryDecorator(identityMap, entry, entityType);
  }
}

/// Replaces all repositories requested from the DI container with
/// [InMemoryRepository] implementation which can be used in early development
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
