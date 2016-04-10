part of corsac_dal;

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
  Stream<T> find(Filter<T> filter) {
    var filtered = items.where((i) {
      for (var c in filter.conditions) {
        var matcher = new _Matcher.createMatcherFor(c);
        if (!matcher.match(i)) {
          return false;
        }
      }
      return true;
    });

    if (filter.skip is int) filtered = filtered.skip(filter.skip);
    if (filter.take is int) filtered = filtered.take(filter.take);

    return new Stream<T>.fromIterable(filtered);
  }

  @override
  Future<T> findOne(Filter<T> filter) => find(filter)
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

  @override
  Future<int> count([Filter<T> filter]) {
    if (filter is Filter) {
      var tmpFilter = new Filter<T>.from(filter);
      tmpFilter
        ..skip = null
        ..take = null;
      return find(tmpFilter).length;
    } else {
      return new Future.value(items.length);
    }
  }
}

abstract class _Matcher {
  bool match(entity);

  factory _Matcher.createMatcherFor(Condition condition) {
    if (condition.predicate == Condition.EQ) {
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
