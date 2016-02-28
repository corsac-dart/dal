part of corsac_stateless;

/// Identity Map keeps track of entities loaded into memory within single
/// business transaction.
abstract class IdentityMap {
  /// Puts entity in this identity map.
  void put(Type type, Object id, Object entity);

  /// Returns true if entity exists in this identity map.
  bool has(Type type, Object id);

  /// Fetches entity specified by [type] and [id] from this identity map.
  Object get(Type type, Object id);
}

/// Simple "in-memory" implementation of IdentityMap.
///
/// Stores it's state in a local [Map].
class InMemoryIdentityMap implements IdentityMap {
  final Map _namespaces = new Map();

  Map _getNamespace(Type type) {
    if (!_namespaces.containsKey(type)) {
      _namespaces[type] = new Map();
    }

    return _namespaces[type];
  }

  @override
  void put(Type type, Object id, Object entity) {
    final map = _getNamespace(type);
    map[id] = entity;
  }

  @override
  bool has(Type type, Object id) {
    return _getNamespace(type).containsKey(id);
  }

  @override
  Object get(Type type, Object id) {
    return _getNamespace(type)[id];
  }

  void flush() {
    _namespaces.clear();
  }
}

/// IdentityMap which stores its state in a zone-local value.
///
/// Use this implementation if you plan to leverage Dart's `runZoned()`
/// functionality for executing business transactions.
///
///     void main() {
///       var identityMap = new ZoneLocalIdentityMap();
///       runZoned(() {
///         identityMap.put(Entity, 'id', instance);
///       }, zoneValues: identityMap.zoneValues);
///     }
class ZoneLocalIdentityMap implements IdentityMap {
  /// Name of the key under which IdentityMap state will be stored in zoneValues
  /// map.
  ///
  /// Make sure to use "unique enough" key so that there is no chances any child
  /// zone can override it.
  final Symbol key;

  /// Creates new instance of IdentityMap.
  ///
  /// Make sure to use "unique enough" [key] so that there is no chances any
  /// child zone can override it.
  ZoneLocalIdentityMap(this.key);

  /// Zone-local values defined by this identity map.
  ///
  /// Make sure to pass this value to the `runZoned()` call. Otherwise any
  /// access to this identity map will throw a `StateError`.
  Map get zoneValues {
    return {key: new Map()};
  }

  Map _getNamespace(Type type) {
    if (Zone.current[key] == null) {
      throw new StateError('ZoneLocalIdentityMap has not been initialized');
    }

    Map state = Zone.current[key];
    if (!state.containsKey(type)) {
      state[type] = new Map();
    }

    return state[type];
  }

  @override
  void put(Type type, Object id, Object entity) {
    final map = _getNamespace(type);
    map[id] = entity;
  }

  @override
  bool has(Type type, Object id) {
    return _getNamespace(type).containsKey(id);
  }

  @override
  Object get(Type type, Object id) {
    return _getNamespace(type)[id];
  }
}

@proxy
class RepositoryIdentityCacheDecorator implements Repository {
  final IdentityMap identityMap;
  final Repository repository;

  RepositoryIdentityCacheDecorator(this.identityMap, this.repository);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    var result = reflect(repository).delegate(invocation);
    if (result is Future) {
      return result.then((entity) {
        if (entity == null) {
          return null;
        }
        var t = reflect(entity).type.reflectedType;
        var id = entityId(entity);
        if (!identityMap.has(t, id)) {
          identityMap.put(t, id, entity);
        }
        return identityMap.get(t, id);
      });
    } else if (result is Stream) {
      return result.transform(streamTransformer); // TODO: transform the stream.
    } else {
      return result;
    }
  }
}
