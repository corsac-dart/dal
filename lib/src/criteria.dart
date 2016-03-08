part of corsac_stateless;

/// Error thrown for invalid operations in [Criteria].
class CriteriaError {
  final String message;
  CriteriaError(this.message);
}

/// List of valid predicates for conditions.
abstract class ConditionPredicate {
  static const String equals = '=';
  static const String notEquals = '<>';
  static const String greaterThan = '>';
  static const String greaterThanOrEqual = '>=';
  static const String lessThan = '<';
  static const String lessThanOrEqual = '<=';
  static const String inList = 'IN';
  static const String between = 'BETWEEN';
  static const String like = 'LIKE';
}

/// Condition for [Criteria].
class Condition {
  String key;
  dynamic value;
  String predicate;

  Condition(this.key, this.value, this.predicate);

  @override toString() => "Condition(${key} ${predicate} $value)";
}

/// Criteria provides a way to filter entities fetched from [Repository] based
/// on certain conditions. Used in `findOne` and `find` methods of
/// [Repository] interface.
class Criteria<T> {
  final List<Condition> conditions = new List();
  int skip;
  int take;

  void where(bool test(T entity)) {
    var entity = new _EntityStub<T>();
    test(entity); // dynamic proxies... where are you?
    conditions.addAll(entity.conditions);
  }
}

@proxy
class _EntityStub<T> {
  final List<_FieldStub> fields = new List();
  List<Condition> _conditions;

  @override
  noSuchMethod(Invocation invocation) {
    if (invocation.isGetter) {
      var field = new _FieldStub(MirrorSystem.getName(invocation.memberName));
      fields.add(field);
      return field;
    } else {
      throw new CriteriaError(
          'Only getters can be called in criteria builder.');
    }
  }

  List<Condition> get conditions {
    if (_conditions == null) {
      _conditions = new List();
      for (var f in fields) {
        _conditions.addAll(f.conditions);
      }
    }
    return _conditions;
  }
}

abstract class FieldStub {
  List<Condition> get conditions;
}

// TODO: implement all predicates.
@proxy
class _FieldStub implements FieldStub {
  final String name;
  final List<Condition> conditions = new List();

  _FieldStub(this.name);

  @override
  bool operator ==(other) {
    conditions.add(new Condition(name, other, ConditionPredicate.equals));
    return true;
  }

  bool operator >(other) {
    conditions.add(new Condition(name, other, ConditionPredicate.greaterThan));
    return true;
  }
}
