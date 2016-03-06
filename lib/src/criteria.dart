part of corsac_stateless;

/// Error thrown for invalid operations in [Criteria].
class CriteriaError {
  final String message;
  CriteriaError(this.message);
}

/// Base interface for criteria conditions.
abstract class Condition {
  String get key;
  dynamic get value;
}

/// Condition for field equality.
class EqualsCondition implements Condition {
  @override
  final String key;
  @override
  final dynamic value;

  EqualsCondition(this.key, this.value);
}

/// Criteria provides a way to filter entities fetched from [Repository] based
/// on certain conditions. Used in `findOne` and `find` methods of
/// [FindOperations] interface.
class Criteria<T> {
  final List<Condition> conditions = new List();
  int skip;
  int take;

  void where(bool test(T entity)) {
    var entity = new _EntityStub<T>();
    test(entity);
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

@proxy
class _FieldStub implements FieldStub {
  final String name;
  final List<Condition> conditions = new List();

  _FieldStub(this.name);

  bool operator ==(other) {
    conditions.add(new EqualsCondition(name, other));
    return true;
  }
}
