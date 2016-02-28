part of corsac_stateless;

class CriteriaBuilder<T> {
  void where(bool test(T entity)) {
    var entity = new _EntityStub<T>();
    test(entity);
  }
}

@proxy
class _EntityStub<T> {
  @override
  noSuchMethod(Invocation invocation) {
    if (invocation.isGetter) {
      return new _FieldStub(MirrorSystem.getName(invocation.memberName));
    } else {
      throw 'Only getters can be called in criteria builder.';
    }
  }
}

@proxy
class _FieldStub {
  final String name;

  _FieldStub(this.name);

  @override
  noSuchMethod(Invocation invocation) {
    print(invocation.memberName);
    print(invocation.isGetter);
  }

  bool operator ==(other) {
    print('The ${name} should equal to ${other}');
    return true;
  }
}
