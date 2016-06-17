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
  /// Puts object in this repository. Here "put" means either insert and/or
  /// update (sometimes also refered to as "upsert").
  Future put(T entity);

  /// Returns object specified by [id] from this repository.
  ///
  /// Returns `null` if there is no such object.
  Future<T> get(id);

  /// Finds object matching provided [filter].
  Future<T> findOne(Filter<T> filter);

  /// Finds objects matching provided [filter] and returns them as a `Stream`.
  Stream<T> find(Filter<T> filter);

  /// Finds objects matching provided [filter] and batches them to [maxBatchSize]
  /// before sending to returned stream.
  Stream<Iterable<T>> findBatched(Filter<T> filter, int maxBatchSize);

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
