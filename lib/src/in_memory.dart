part of corsac_stateless;

/// Repository which stores entities in memory.
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

  @override
  Stream<T> find(Criteria criteria) {
    var filtered = items.where((i) {
      for (var c in criteria.conditions) {
        var matcher = new _Matcher.createMatcherFor(c);
        if (!matcher.match(i)) {
          return false;
        }
      }
      return true;
    });

    return new Stream<T>.fromIterable(filtered);
  }

  @override
  Future<T> findOne(Criteria criteria) => find(criteria)
      .first
      .catchError((_) => null, test: (error) => error is StateError);

  @override
  Stream<T> batchGet(Set ids) {
    return new Stream<T>.fromIterable(
        items.where((i) => ids.contains(entityId(i))));
  }

  @override
  Future batchPut(Set<T> entities) {
    items.addAll(entities);
    return new Future.value();
  }
}

abstract class _Matcher {
  bool match(entity);

  factory _Matcher.createMatcherFor(Condition condition) {
    if (condition.predicate == ConditionPredicate.equals) {
      return new _EqualsMatcher(condition);
    } else {
      throw new ArgumentError(
          "Unsupported condition type (${condition}) for in-memory matcher.");
    }
  }
}

class _EqualsMatcher implements _Matcher {
  final Condition condition;

  _EqualsMatcher(this.condition);

  bool match(entity) {
    var fieldName = MirrorSystem.getSymbol(condition.key);
    var value = reflect(entity).getField(fieldName).reflectee;
    return value == condition.value;
  }
}
