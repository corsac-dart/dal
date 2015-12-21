part of corsac_stateless;

/// Base interface for entity data gateways.
///
/// This interface follows "put/get/delete" persistence model as opposed to
/// "insert/update/get/delete".
abstract class DataGateway<T> {
  void put(T entity);
  bool contains(T entity);
  T findById(dynamic id);
}

/// In-memory entity storage which can be used for testing and prototyping
/// purposes.
class InMemoryDataGateway<T> implements DataGateway<T> {
  Set<T> items = new Set();

  @override
  void put(T entity) {
    items.add(entity);
  }

  @override
  bool contains(T entity) {
    return items.contains(entity);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final methodName = MirrorSystem.getName(invocation.memberName);
    if (invocation.isMethod && methodName.startsWith('findBy')) {
      var method = _findMethodDeclaration(invocation.memberName);
      // Intentionally naive implementation for now.
      final fieldName = _getFieldName(methodName);
      if (method.returnType.reflectedType == T) {
        return items.firstWhere((item) {
          return _entityFieldValue(item, fieldName) ==
              invocation.positionalArguments.first;
        });
      } else if (method.returnType.isSubtypeOf(reflectType(Iterable))) {
        return items.where((item) {
          return _entityFieldValue(item, fieldName) ==
              invocation.positionalArguments.first;
        });
      } else {
        throw new StateError(
            'Entity query methods must have return type of the entity or an iterable of entities.');
      }
    } else {
      return super.noSuchMethod(invocation);
    }
  }

  MethodMirror _findMethodDeclaration(Symbol methodName) {
    final mirror = reflect(this);
    for (var i in mirror.type.superinterfaces) {
      if (i.declarations.containsKey(methodName)) {
        return i.declarations[methodName];
      }
    }
    throw new StateError(
        'Method declaration not found in any of super interfaces.');
  }

  Symbol _getFieldName(String methodName) {
    var nameCandidate = methodName.replaceFirst('findBy', '');
    var mirror = reflectClass(T);
    for (var symbol in mirror.declarations.keys) {
      var name = MirrorSystem.getName(symbol);
      if (name.toLowerCase() == nameCandidate.toLowerCase()) {
        return symbol;
      }
    }

    throw new StateError(
        'Could not find property with name  ${nameCandidate} in ${T}.');
  }
}

dynamic _entityFieldValue(dynamic entity, Symbol fieldName) {
  var mirror = reflect(entity);
  return mirror.getField(fieldName).reflectee;
}
