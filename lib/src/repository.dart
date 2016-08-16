part of corsac_dal;

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
  /// Returns `null` if there is no such entity.
  Future<T> get(id);

  /// Finds entity matching provided [filter].
  Future<T> findOne(Filter<T> filter);

  /// Finds all entities matching provided [filter].
  Stream<T> find(Filter<T> filter);

  /// Returns total number of items in this repository. If [filter] is
  /// provided then returns total number of items satisfying this filter
  /// (the `skip` and `take` fields of the filter are ignored).
  Future<int> count([Filter<T> filter]);

  /// Puts [entities] in this repository. This will either add entities to this
  /// repository or update them.
  Future batchPut(Set<T> entities);

  /// Returns a stream containing all entities specified by [ids].
  Stream<T> batchGet(Set ids);
}
