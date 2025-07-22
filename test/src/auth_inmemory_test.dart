// ignore_for_file: prefer_const_constructors
import 'package:auth_inmemory/auth_inmemory.dart';
import 'package:test/test.dart';

void main() {
  group('AuthInmemory', () {
    test('can be instantiated', () {
      expect(AuthInmemory(), isNotNull);
    });
  });
}
