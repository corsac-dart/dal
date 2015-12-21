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
  final DataGateway<T> dataGateway;

  IdentityMap get _identityMap {
    if (!callStack.currentFrame.state.containsKey('identityMap')) {
      callStack.currentFrame.state['identityMap'] = new IdentityMap();
    }

    return callStack.currentFrame.state['identityMap'];
  }

  Repository(this.callStack, this.dataGateway);

  void add(T entity) {
    if (_identityMap.has(T, entityId(entity)) || dataGateway.contains(entity)) {
      throw new StateError('Entity already exists in repository.');
    }

    dataGateway.put(entity);
    _identityMap.put(T, entityId(entity), entity);
  }

  T findById(dynamic id) {
    if (!_identityMap.has(T, id)) {
      var entity = dataGateway.findById(id);
      _identityMap.put(T, id, entity);
    }

    return _identityMap.get(T, id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    var result;
    final mirror = reflect(dataGateway);
    if (mirror.type.declarations.containsKey(invocation.memberName)) {
      result = mirror
          .invoke(invocation.memberName, invocation.positionalArguments,
              invocation.namedArguments)
          .reflectee;
    } else {
      result = dataGateway.noSuchMethod(invocation);
    }

    if (result is T) {
      return _ensureIdentity(result);
    } else if (result is Iterable) {
      return result.map((i) => _ensureIdentity(i));
    } else {
      throw new StateError(
          'Entity storage can only return instances of entity or collections of the same entity.');
    }
  }

  /// Makes sure only one instance with the same ID returned from this
  /// repository.
  ///
  /// Checks [IdentityMap] for an instance with the same ID. If it already
  /// exists then the instance from [IdentityMap] is returned. Otherwise new
  /// instance is added to [IdentityMap] and returned.
  T _ensureIdentity(T entity) {
    if (_identityMap.has(T, entityId(entity))) {
      return _identityMap.get(T, entityId(entity));
    } else {
      _identityMap.put(T, entityId(entity), entity);
      return entity;
    }
  }
}
