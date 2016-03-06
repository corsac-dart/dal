part of corsac_stateless;

/// Repository which stores entities in memory.
///
// TODO: implement [FindOperations] and [BatchOperations].
class InMemoryRepository<T> implements Repository<T>, FindOperations<T> {
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
  Future<T> findOne(Criteria criteria) => find(criteria).first;
}

abstract class _Matcher {
  bool match(entity);

  factory _Matcher.createMatcherFor(Condition condition) {
    if (condition is EqualsCondition) {
      return new _EqualsMatcher(condition);
    } else {
      throw new ArgumentError(
          "Unsupported condition type (${condition}) for in-memory matcher.");
    }
  }
}

class _EqualsMatcher implements _Matcher {
  final EqualsCondition condition;

  _EqualsMatcher(this.condition);

  bool match(entity) {
    var fieldName = MirrorSystem.getSymbol(condition.key);
    var value = reflect(entity).getField(fieldName).reflectee;
    return value == condition.value;
  }
}
