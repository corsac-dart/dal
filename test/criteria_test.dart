library corsac_stateless.test.identity_map;

import 'dart:async';

import 'package:corsac_stateless/corsac_stateless.dart';
import 'package:test/test.dart';

void main() {
  group('CriteriaBuilder:', () {
    test('it stores entities', () async {
      var cb = new CriteriaBuilder<User>();
      cb.where((_) => _.id == 1);
    });
  });
}

class User {
  final int id;

  User(this.id);
}
