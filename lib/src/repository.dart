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
/// By default it looks for a field with name `id`. If such field
/// does not exist it will check if there is a field annotated with `@identity`.
///
/// > Note that field with name `id` will have preference over annotation.
/// > Though this behavior may be changed in future versions.
///
/// If it can't find either it will throw `StateError`.
Object entityId(Object entity) {
  final mirror = reflect(entity);

  if (mirror.type.declarations.containsKey(const Symbol('id'))) {
    return mirror.getField(const Symbol('id')).reflectee;
  } else {
    var annotatedField = mirror.type.declarations.values.firstWhere((_) {
      return _ is VariableMirror && _.metadata.contains(reflect(identity));
    }, orElse: () => null);

    if (annotatedField is VariableMirror) {
      return mirror.getField(annotatedField.simpleName).reflectee;
    }
  }

  throw new StateError('Can not determine entity identity');
}

/// Generic repository for entities.
///
/// The repository is responsible for abstracting from used persistence
/// technology as well as for caching entities in [IdentityMap] for current
/// business transaction.
///
/// By default repositore implements only two basic operations: put and get.
/// However in future versions it will be possible to mix-in more behaviors
/// like:
///
/// * [BatchMixin] - provides `batchGet()` and `batchPut()`.
/// * [FindMixin] - provides `find()` and `findOne()`.
class Repository<T> {
  final DataGateway<T> dataGateway;
  final IdentityMap identityMap;

  Repository(this.identityMap, this.dataGateway);

  /// Puts entity in this repository. Here "put" means either insert and/or
  /// update (sometimes also refered to as "upsert").
  Future put(T entity) async {
    await dataGateway.put(entity);
    identityMap.put(T, entityId(entity), entity);
  }

  /// Returns entity specified by [id] from the repository.
  ///
  /// If no entity with provided [id] found, StateError will be thrown.
  Future<T> get(Object id) async {
    if (!identityMap.has(T, id)) {
      var entity = await dataGateway.get(id);
      identityMap.put(T, id, entity);
    }

    return identityMap.get(T, id);
  }
}

/// Mixin which can be added to repository implementations when batch
/// operations (batchPut and batchGet) are needed.
abstract class BatchMixin<T> {
  IdentityMap get identityMap;
  DataGateway<T> get dataGateway;

  Future batchPut(Set<T> entities) {
    // TODO: implement batchPut.
    return null;
  }

  Future<Set<T>> batchGet(Set<Object> ids) {
    // TODO: implement batchGet.
    return null;
  }
}

/// Mixin providing "filtering" capabilities. Designed to be used only by
/// repositories.
abstract class FindMixin<T> implements FindOperations<T> {
  IdentityMap get identityMap;
  DataGateway<T> get dataGateway;

  @override
  Future<T> findOne(Object criteria) async {
    if (dataGateway is! FindOperations) {
      throw new StateError('DataGateway must implement FindOperations.');
    }

    final entity = await (dataGateway as FindOperations).findOne(criteria);
    final id = entityId(entity);
    if (!identityMap.has(T, id)) {
      identityMap.put(T, id, entity);
    }

    return identityMap.get(T, id);
  }

  @override
  Future<Set<T>> find(Object criteria) async {
    if (dataGateway is! FindOperations) {
      throw new StateError('DataGateway must implement FindOperations.');
    }

    final entities = await (dataGateway as FindOperations).find(criteria);
    final result = new Set<T>();
    for (var entity in entities) {
      var id = entityId(entity);
      if (!identityMap.has(T, id)) {
        identityMap.put(T, id, entity);
      }
      result.add(identityMap.get(T, id));
    }

    return result;
  }
}

/// Interface for standard find operations. Should be implemented by
/// data gateways.
///
/// The `criteria` parameter does not force any particular criteria interface
/// so implementers are free to define their own.
abstract class FindOperations<T> {
  Future<T> findOne(Object criteria);
  Future<Set<T>> find(Object criteria);
}
