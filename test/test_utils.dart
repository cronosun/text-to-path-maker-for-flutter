import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:cronosun_text_to_path_maker/cronosun_text_to_path_maker.dart';

class Base64Font {
  final String fontAsBase64;
  Uint8List? _fontAsBytes;
  PMFont? _pmFont;

  Base64Font(this.fontAsBase64);

  PMFont asPmFont() {
    final pmFont = _pmFont;
    if (pmFont != null) {
      return pmFont;
    } else {
      final reader = PMFontReader();
      final font = reader.parseTTFAsset(ByteData.sublistView(asUint8List()));
      _pmFont = font;
      return font;
    }
  }

  Uint8List asUint8List() {
    final uInt8List = _fontAsBytes;
    if (uInt8List == null) {
      final fontAsBytes = base64Decode(fontAsBase64);
      _fontAsBytes = fontAsBytes;
      return fontAsBytes;
    } else {
      return uInt8List;
    }
  }
}

void assetHasPathForCodePoints(PMFont font, List<int> codePoints) {
  for (final codePoint in codePoints) {
    final path = font.generatePathForCharacterOrNull(codePoint);
    expect(path, isNotNull);
  }
}

void assertPathNormalizationWorks(PMFont font, bool allowEmptyGlyphs) {
  for (final codePoint in font.codePoints) {
    final path = font.generatePathForCharacterOrNull(codePoint);
    final normalizedPath = PMTransform.normalizePath(path!);
    final bounds = normalizedPath.getBounds();

    expect(bounds.left, isZero);
    expect(bounds.top, isZero);
    if (bounds.right == 0 && bounds.bottom == 0 && allowEmptyGlyphs) {
      // That's ok, some fonts (the material icon font, for example) have empty glyphs.
    } else {
      expect(bounds.right, isPositive);
      expect(bounds.bottom, isPositive);
    }
  }
}
