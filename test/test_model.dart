library corsac_stateless.test.model;

import 'package:corsac_call_stack/corsac_call_stack.dart';
import 'package:corsac_stateless/corsac_stateless.dart';

class User {
  final int id;
  final String name;

  User(this.id, this.name);
}

class UserRepository extends Repository<User> {
  UserRepository(CallStack executionQueue, EntityStorage storage)
      : super(executionQueue, storage);
}
