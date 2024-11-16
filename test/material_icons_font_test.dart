import 'package:test/test.dart';

import 'material_icons_font.dart';
import 'test_utils.dart';

void main() {
  test('Material icons regular font test', () {
    // Checking against information from 'https://fontdrop.info/'.

    final font = materialIconsRegularFont.asPmFont();
    expect(font.numGlyphs, equals(2229));
    expect(font.sfntVersion, equals(65536));

    final codePoints = font.codePoints;
    final numberOfCodePoints = codePoints.length;
    // "2226" is correct, according to https://fontdrop.info/).
    expect(numberOfCodePoints, equals(2226));

    // Test some codepoints we know (according to https://fontdrop.info/) they must exist.
    assetHasPathForCodePoints(font, [
      48,
      95,
      57936,
      59721,
      60247,
      61422,
      61713,
      63701,
      63724,
      63741,
      1114109
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

    // What happens if we try to get a path for a codepoint that does not exist?
    final notExistentPath = font.generatePathForCharacterOrNull(1114110);
    expect(notExistentPath, isNull);

    final codePointsAsSortedList = codePoints.toList(growable: false);
    codePointsAsSortedList.sort();
    // Info from https://fontdrop.info/
    // The smallest code point
    expect(codePointsAsSortedList[0], equals(48));
    // Info from https://fontdrop.info/
    // The largest code point
    expect(codePointsAsSortedList.last, equals(1114109));

    assertPathNormalizationWorks(font, true);
  });
}
