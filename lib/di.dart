/// DI bindings for repository layer.
library corsac_stateless.di;

import 'dart:mirrors';

import 'package:corsac_di/corsac_di.dart';
import 'package:corsac_stateless/corsac_stateless.dart';

class RepositoryContainerMiddleware implements DIContainerMiddleware {
  final IdentityMap identityMap;

  RepositoryContainerMiddleware(this.identityMap);

  @override
  get(id, DIMiddlewarePipeline next) {
    var entry = next.get(id);
    if (entry is IdentityMapCachingRepositoryDecorator) {
      return entry;
    } else if (entry is Repository) {
      return new IdentityMapCachingRepositoryDecorator(identityMap, entry);
    } else {
      return entry;
    }
  }
}
