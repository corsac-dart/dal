part of corsac_stateless;

/// Base interface for entity data gateways.
///
/// Data gateways are responsible for communicating with underlying
/// persistence technology and mapping data between entities and storage
/// records (though mapping can be delegated to some other service).
///
/// This interface follows "put/get/remove" persistence model as opposed to
/// "insert/update/select/delete" or CRUD.
abstract class DataGateway<T> {
  Future put(T entity);
  Future<T> get(Object id);
}

/// In-memory entity storage which can be used for testing and prototyping
/// purposes.
class InMemoryDataGateway<T> implements DataGateway<T> {
  final Set<T> items = new Set();

  @override
  Future put(T entity) {
    items.add(entity);
    return new Future.value();
  }

  Future<T> get(Object id) {
    var item = items.firstWhere((i) => entityId(i) == id);
    return new Future.value(item);
  }
}
