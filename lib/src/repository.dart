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
}

/// Interface for standard find operations. Should be implemented by
/// repositories.
///
// TODO: Update criteria to use own abstraction of criterias.
abstract class FindOperations<T> {
  Future<T> findOne(Object criteria);
  Stream<T> find(Object criteria);
}

/// Inteface for standard batch operations. Should be implemented by
/// repositories.
abstract class BatchOperations<T> {
  Future batchPut(Set<T> entities);
  Stream<T> batchGet(Set ids);
}

/// Repository which stores entities in memory.
///
// TODO: implement [FindOperations] and [BatchOperations].
class InMemoryRepository<T> implements Repository<T> {
  final Set items = new Set();

  InMemoryRepository();

  @override
  Future get(id) {
    var item = items.firstWhere((i) => entityId(i) == id, orElse: () => null);
    return new Future.value(item);
  }

  @override
  Future put(entity) {
    items.add(entity);
    return new Future.value();
  }
}
