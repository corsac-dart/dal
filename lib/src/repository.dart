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

  throw new StateError('Can not determine entity identity for ${entity}.');
}

/// Generic repository interface.
///
/// The repository is responsible for abstracting from persistence
/// technology.
abstract class Repository<T> {
  /// Puts entity in this repository. Here "put" means either insert and/or
  /// update (sometimes also refered to as "upsert").
  Future put(T entity);

  /// Returns entity specified by [id] from the repository.
  ///
  /// If no entity with provided [id] found, StateError will be thrown.
  Future<T> get(id);
}

/// Interface for standard find operations. Should be implemented by
/// data gateways.
///
/// The `criteria` parameter does not force any particular criteria interface
/// so implementers are free to define their own.
abstract class FindOperations<T> {
  Future<T> findOne(Object criteria);
  Stream<T> find(Object criteria);
}

abstract class BatchOperations<T> {
  Future batchPut(Set<T> entities);
  Stream<T> batchGet(Set ids);
}
