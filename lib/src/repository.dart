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

/// Generic repository interface.
///
/// The repository is responsible for abstracting from storage
/// layer.
abstract class Repository<T> {
  /// Puts entity in this repository. Here "put" means either insert and/or
  /// update (sometimes also refered to as "upsert").
  Future put(T entity);

  /// Returns entity specified by [id] from the repository.
  ///
  /// If no entity with provided [id] found returns `null`.
  Future<T> get(id);

  /// Finds entity matching provided [criteria].
  Future<T> findOne(Criteria criteria);

  /// Finds all entities matching provided [criteria].
  Stream<T> find(Criteria criteria);

  /// Puts [entities] in this repository. This will either add entities to this
  /// repository or update them.
  Future batchPut(Set<T> entities);

  /// Returns a stream containing all entities specified by [ids].
  Stream<T> batchGet(Set ids);
}
