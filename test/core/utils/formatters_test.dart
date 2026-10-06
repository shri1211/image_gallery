import 'package:flutter_test/flutter_test.dart';
import 'package:image_gallery/core/utils/formatters.dart';

void main() {
  group('Formatters.compactNumber', () {
    test('leaves small numbers intact', () {
      expect(Formatters.compactNumber(42), '42');
      expect(Formatters.compactNumber(999), '999');
    });

    test('compacts thousands', () {
      expect(Formatters.compactNumber(1000), '1K');
      expect(Formatters.compactNumber(12500), '12.5K');
    });

    test('compacts millions', () {
      expect(Formatters.compactNumber(1200000), '1.2M');
    });
  });

  group('Formatters.titleCase', () {
    test('title-cases words', () {
      expect(Formatters.titleCase('mountain lake'), 'Mountain Lake');
      expect(Formatters.titleCase('NATURE'), 'Nature');
    });

    test('handles empty input', () {
      expect(Formatters.titleCase(''), '');
    });
  });
}
