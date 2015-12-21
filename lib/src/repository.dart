part of corsac_stateless;

class _Identity {
  const _Identity();
}

/// Annotation which can be used on entity field which contains unique
/// identifier.
///
///     class User {
///       @identity
///       final String email;
///     }
const identity = const _Identity();

/// Returns [entity] ID.
///
/// By default it looks for a property with name `id`. If such property
/// does not exist it will check if there property annotated with `@identity`.
///
/// If it can't find either it will throw `StateError`.
dynamic entityId(dynamic entity) {
  final mirror = reflect(entity);
  if (mirror.type.declarations.containsKey(const Symbol('id'))) {
    return mirror.getField(const Symbol('id')).reflectee;
  } else {
    throw new StateError(
        'Can not determine entity identity (no field with name id)');
  }
}

/// In-memory entity storage which can be used for testing and prototyping
/// purposes.
class InMemoryStorage<T> implements EntityStorage<T> {
  Set<T> _items = new Set();

  @override
  void put(T entity) {
    _items.add(entity);
  }

  @override
  bool contains(T entity) {
    return _items.contains(entity);
  }

  T findById(dynamic id) {
    return _items.firstWhere((i) => entityId(i) == id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    var name = MirrorSystem.getName(invocation.memberName);
    if (invocation.isMethod && name.startsWith('findBy')) {
      var m = reflect(this);
      print(m.type.superinterfaces);
    } else {
      return super.noSuchMethod(invocation);
    }
  }
}

abstract class StateSubscription {
  StateListener _stateListener;

  void set stateListener(StateListener stateListener) {
    if (_stateListener is StateListener) throw new StateError(
        'State listener is already set.');
    _stateListener = stateListener;
  }
}

abstract class StateListener {
  void onStateChange(entity);
}

/// Generic repository for entities.
class Repository<T> {
  final CallStack callStack;
  final EntityStorage<T> storage;

  IdentityMap get _identityMap {
    if (!callStack.currentFrame.state.containsKey('identityMap')) {
      callStack.currentFrame.state['identityMap'] = new IdentityMap();
    }

    return callStack.currentFrame.state['identityMap'];
  }

  Repository(this.callStack, this.storage);

  void add(T entity) {
    if (_identityMap.has(T, entityId(entity)) || storage.contains(entity)) {
      throw new StateError('Entity already exists in repository.');
    }

    storage.put(entity);
    _identityMap.put(T, entityId(entity), entity);
  }

  T findById(dynamic id) {
    if (!_identityMap.has(T, id)) {
      var entity = storage.findById(id);
      _identityMap.put(T, id, entity);
    }

    return _identityMap.get(T, id);
  }
}

abstract class EntityStorage<T> {
  void put(T entity);
  bool contains(T entity);
  T findById(id);
}
