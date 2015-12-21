library corsac_stateless.test.model;

import 'package:corsac_call_stack/corsac_call_stack.dart';
import 'package:corsac_stateless/corsac_stateless.dart';

class User {
  final int id;
  final String name;

  User(this.id, this.name);
}

abstract class UserQueryModel {
  User findById(int id);
  User findByName(String name);
}

class UserRepository extends Repository<User> implements UserQueryModel {
  UserRepository(CallStack executionQueue, DataGateway storage)
      : super(executionQueue, storage);
}

class UserInMemoryDataGateway extends InMemoryDataGateway<User>
    implements UserQueryModel {}
