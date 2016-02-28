library corsac_stateless.test.identity_map;

import 'package:test/test.dart';
import 'package:corsac_stateless/corsac_stateless.dart';
import 'package:corsac_stateless/in_memory.dart';
import 'dart:async';

void main() {
  group('ZoneLocalIdentityMap:', () {
    test('it stores entities', () async {
      var map = new ZoneLocalIdentityMap(#identityMap);
      runZoned(() {
        expect(map.has(User, 10), isFalse);
        var user = new User(10, 'Ten');
        map.put(User, 10, user);
        expect(map.has(User, 10), isTrue);
        expect(map.get(User, 10), same(user));
      }, zoneValues: map.zoneValues);
    });

    test('it\'s state is not shared between runs', () async {
      var map = new ZoneLocalIdentityMap(#identityMap);
      var user = new User(10, 'Ten');
      runZoned(() {
        map.put(User, 10, user);
      }, zoneValues: map.zoneValues);

      runZoned(() {
        expect(map.has(User, 10), isFalse);
      }, zoneValues: map.zoneValues);
    });
  });

  group('IdentityMapCachingRepositoryDecorator:', () {
    test('it caches entities in identity map', () async {
      var map = new InMemoryIdentityMap();
      var repo = new InMemoryRepository(User);
      var decoratedRepo = new RepositoryIdentityCacheDecorator(map, repo);
      var user = new User(10, 'Ten');

      decoratedRepo.put(user);
      var fetchedUser = await decoratedRepo.get(10);
      expect(fetchedUser, same(user));
      expect(map.has(User, 10), isTrue);

      map.flush();

      var freshUser = await decoratedRepo.get(10);
      expect(freshUser, same(user));
      expect(map.has(User, 10), isTrue);
    });
  });
}

class User {
  final int id;
  final String name;

  User(this.id, this.name);
}
