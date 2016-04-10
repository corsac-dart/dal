library corsac_dal.tests.identity_map;

import 'dart:async';

import 'package:corsac_dal/corsac_dal.dart';
import 'package:test/test.dart';

void main() {
  group('ZoneLocalIdentityMap:', () {
    test('it stores entities', () async {
      var map = new ZoneLocalIdentityMap(#identityMap);
      runZoned(() {
        expect(map.contains(User, 10), isFalse);
        var user = new User(10, 'Ten');
        map.put(User, 10, user);
        expect(map.contains(User, 10), isTrue);
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
        expect(map.contains(User, 10), isFalse);
      }, zoneValues: map.zoneValues);
    });
  });

  group('IdentityMapCachingRepositoryDecorator:', () {
    test('it caches entities in identity map', () async {
      var map = new InMemoryIdentityMap();
      var repo = new InMemoryRepository();
      var decoratedRepo = new IdentityMapRepositoryDecorator(map, repo, User);
      var user = new User(10, 'Ten');

      decoratedRepo.put(user);
      var fetchedUser = await decoratedRepo.get(10);
      expect(fetchedUser, same(user));
      expect(map.contains(User, 10), isTrue);

      map.flush();

      var freshUser = await decoratedRepo.get(10);
      expect(freshUser, same(user));
      expect(map.contains(User, 10), isTrue);
    });
  });
}

class User {
  final int id;
  final String name;

  User(this.id, this.name);
}
