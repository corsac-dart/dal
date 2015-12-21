part of corsac_stateless;

/// Identity Map keeps track of entities currently loaded into memory.
class IdentityMap {
  final Map _namespaces = new Map();

  Map _getNamespace(Type type) {
    if (!_namespaces.containsKey(type)) {
      _namespaces[type] = new Map();
    }

    return _namespaces[type];
  }

  void put(Type type, dynamic id, dynamic entity, [stateListener]) {
    final map = _getNamespace(type);
    map[id] = entity;
  }

  bool has(Type type, dynamic id) {
    return _getNamespace(type).containsKey(id);
  }

  dynamic get(Type type, dynamic id) {
    return _getNamespace(type)[id];
  }
}
