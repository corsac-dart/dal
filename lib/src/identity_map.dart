part of corsac_stateless;

/// Identity Map keeps track of entities loaded into memory within single
/// business transaction.
class IdentityMap {
  final Map _namespaces = new Map();

  Map _getNamespace(Type type) {
    if (!_namespaces.containsKey(type)) {
      _namespaces[type] = new Map();
    }

    return _namespaces[type];
  }

  void put(Type type, Object id, Object entity) {
    final map = _getNamespace(type);
    map[id] = entity;
  }

  bool has(Type type, Object id) {
    return _getNamespace(type).containsKey(id);
  }

  Object get(Type type, Object id) {
    return _getNamespace(type)[id];
  }
}
