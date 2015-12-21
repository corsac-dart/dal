library corsac_stateless.test.model;

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
  UserRepository(IdentityMap identityMap, DataGateway storage)
      : super(identityMap, storage);
}

class UserInMemoryDataGateway extends InMemoryDataGateway<User>
    implements UserQueryModel {}
