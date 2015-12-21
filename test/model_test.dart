library corsac_stateless.test;

import 'package:test/test.dart';
import 'package:corsac_call_stack/corsac_call_stack.dart';
import 'package:corsac_stateless/corsac_stateless.dart';
import 'test_model.dart';

void main() {
  group('Test model:', () {
    test('it stores entities', () async {
      var stack = new CallStack();
      var repo = new UserRepository(stack, new UserInMemoryDataGateway());
      await stack.push('Main', (StackFrame frame) {
        expect(frame.state, isEmpty);
        repo.add(new User(1, 'John'));
        var user = repo.findById(1);
        expect(user, new isInstanceOf<User>());
        expect(frame.state, isNotEmpty);
        final IdentityMap idMap = frame.state['identityMap'];
        expect(idMap.get(User, 1), same(user));
        frame.completer.complete();
      });

      await stack.push('Main', (StackFrame frame) {
        expect(frame.state, isEmpty);
        var user = repo.findById(1);
        expect(user, new isInstanceOf<User>());
        expect(frame.state, isNotEmpty);
        IdentityMap idMap = frame.state['identityMap'];
        expect(idMap.has(User, 1), isTrue);
        frame.completer.complete();
      });
    });

    test('it forwards query method calls to the storage', () async {
      var stack = new CallStack();
      var repo = new UserRepository(stack, new UserInMemoryDataGateway());
      await stack.push('Main', (StackFrame frame) {
        repo.add(new User(1, 'John'));
        var user = repo.findByName('John');
        expect(user, new isInstanceOf<User>());
        expect(frame.state, isNotEmpty);
        final IdentityMap idMap = frame.state['identityMap'];
        expect(idMap.get(User, 1), same(user));
        frame.completer.complete();
      });
    });
  });
}
