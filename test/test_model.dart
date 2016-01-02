library corsac_stateless.test.model;

import 'package:corsac_stateless/corsac_stateless.dart';

class User {
  final int id;
  final String name;

  User(this.id, this.name);
}

class UserRepository extends Repository<User> with BatchOperations<User> {
  UserRepository(IdentityMap identityMap, DataGateway<User> storage)
      : super(identityMap, storage);
}

class UserInMemoryDataGateway extends InMemoryDataGateway<User> {}
