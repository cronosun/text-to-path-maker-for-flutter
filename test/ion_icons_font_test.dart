import 'package:test/test.dart';

import 'ion_icons_font.dart';
import 'test_utils.dart';

void main() {
  test('Ion icons font test', () {
    // Checking against information from 'https://fontdrop.info/'.

    final font = ionIconsFont.asPmFont();
    expect(font.numGlyphs, equals(1285));
    expect(font.sfntVersion, equals(65536));

    final codePoints = font.codePoints;
    final numberOfCodePoints = codePoints.length;
    // "1338" is correct, according to https://fontdrop.info/).
    expect(numberOfCodePoints, equals(1338));

    // Test some codepoints we know (according to https://fontdrop.info/) they must exist.
    assetHasPathForCodePoints(font, [
      59906,
      59942,
      59961,
      59976,
      60010,
      60046,
      60286,
      60547,
      60680,
      60944,
      61204,
      61233,
      61242
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
    expect(codePointsAsSortedList[0], equals(59905));
    // Info from https://fontdrop.info/
    // The largest code point
    expect(codePointsAsSortedList.last, equals(61242));

    assertPathNormalizationWorks(font, false);
  });
}
