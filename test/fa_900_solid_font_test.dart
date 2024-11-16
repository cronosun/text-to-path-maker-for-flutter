import 'package:test/test.dart';

import 'fa_900_solid_font.dart';
import 'test_utils.dart';

void main() {
  test('900 solid font test', () {
    // Checking against information from 'https://fontdrop.info/'.

    final font = fa900SolidFont.asPmFont();
    expect(font.numGlyphs, equals(1396));
    expect(font.sfntVersion, equals(65536));

    final codePoints = font.codePoints;
    final numberOfCodePoints = codePoints.length;
    // "1969" is correct, according to https://fontdrop.info/).
    expect(numberOfCodePoints, equals(1969));

    // Test some codepoints we know (according to https://fontdrop.info/) they must exist.
    assetHasPathForCodePoints(font, [
      33,
      43,
      88,
      247,
      10069,
      57456,
      57754,
      58061,
      58589,
      58621,
      61481,
      61649,
      61790,
      62142,
      62660,
      62759,
      62911,
      63357,
      128190,
      128999,
      129519,
      129729
    ]);

    // Can we get the svg path for each code point?
    for (final codePoint in codePoints) {
      final path = font.generateSVGPathForCharacterOrNull(codePoint);
      expect(path, isNotNull);
    }

    // Can we get all paths for each code point?
    for (final codePoint in codePoints) {
      final path = font.generatePathForCharacterOrNull(codePoint);
      expect(path, isNotNull);
    }

    final codePointsAsSortedList = codePoints.toList(growable: false);
    codePointsAsSortedList.sort();
    // Info from https://fontdrop.info/
    // The smallest code point
    expect(codePointsAsSortedList[0], equals(33));
    // Info from https://fontdrop.info/
    // The largest code point
    expect(codePointsAsSortedList.last, equals(129729));

    assertPathNormalizationWorks(font, false);
  });
}
