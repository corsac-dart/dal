part of corsac_stateless;

/// Returns [entity] ID.
///
/// By default it looks for a field with name `id`. If such field
/// does not exist it will check if there is a field annotated with `@identity`.
///
/// > Note that field with name `id` will have preference over annotation.
/// > Though this behavior may be changed in future versions.
///
/// If it can't find either it will throw `StateError`.
Object entityId(Object entity) {
  final mirror = reflect(entity);

  if (mirror.type.declarations.containsKey(const Symbol('id'))) {
    return mirror.getField(const Symbol('id')).reflectee;
  } else {
    var annotatedField = mirror.type.declarations.values.firstWhere((_) {
      return _ is VariableMirror && _.metadata.contains(reflect(identity));
    }, orElse: () => null);

    if (annotatedField is VariableMirror) {
      return mirror.getField(annotatedField.simpleName).reflectee;
    }
  }

  throw new StateError('Can not determine entity identity for ${entity}.');
}

/// Resolves type of entities from the given repository type.
///
/// For instance, passing `Repository<User>` will result in `User` type.
/// When repository does not explicitely declare it's type argument this
/// function returns `dynamic`.
Type getEntityType(Type repositoryType) {
  var m = reflectType(repositoryType);
  if (m.typeArguments.isNotEmpty) {
    return m.typeArguments.first.reflectedType;
  } else {
    return m.superinterfaces
        .firstWhere((m) => m.isSubtypeOf(reflectType(Repository)))
        .typeArguments
        .first
        .reflectedType;
  }
}
