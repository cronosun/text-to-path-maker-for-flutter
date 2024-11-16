/**
* Text to Path Maker
* Copyright Ashraff Hathibelagal 2019
*/

import 'pm_contour_point.dart';

/// Represent a font table
class PMFontTable {
  final String tag;
  final int offset;
  final int length;
  final int checkSum;
  PMFontTableData? _data;

  PMFontTable(
      {required this.tag,
      required this.offset,
      required this.length,
      required this.checkSum});

  T requireData<T extends PMFontTableData>() {
    final localData = tryGettingData<T>();
    if (localData == null) {
      throw StateError('Data is null');
    } else {
      return localData;
    }
  }

  T? tryGettingData<T extends PMFontTableData>() {
    final localData = _data;
    if (localData == null) {
      return null;
    } else if (localData is T) {
      return localData;
    } else {
      return null;
    }
  }

  void setData(PMFontTableData data) {
    _data = data;
  }
}

class PMFontTableData {}

class PMMaxpFontTableData extends PMFontTableData {
  final int numGlyphs;

  PMMaxpFontTableData({required this.numGlyphs});
}

class PMHeaderFontTableData extends PMFontTableData {
  final int magicNumber;
  final int flags;
  final int unitsPerEm;
  final int indexToLocFormat;

  PMHeaderFontTableData(
      {required this.magicNumber,
      required this.flags,
      required this.unitsPerEm,
      required this.indexToLocFormat});
}

class PMGlyfFontTableData extends PMFontTableData {
  final List<PMGlyphData> glyphs = [];

  PMGlyfFontTableData();

  void addGlyph(PMGlyphData glyph) {
    glyphs.add(glyph);
  }
}

class PMCMapFontTableData extends PMFontTableData {
  final int version;
  // Note: This was sometimes called 'characterMap', sometimes
  // 'glyphIdToCharacterCodes', will use 'glyphIdToCharacterCodes' for now.
  // Second problem: Previously was a Map<int, int>, but it should be a Map<int, Set<int>>,
  // since a glyph can have multiple character codes.
  final Map<int, Set<int>> glyphIdToCharacterCodes = {};

  PMCMapFontTableData({required this.version});

  void addGlyphIdToCharacterCode(int glyphId, int characterCode) {
    if (!glyphIdToCharacterCodes.containsKey(glyphId)) {
      glyphIdToCharacterCodes[glyphId] = {};
    }
    glyphIdToCharacterCodes[glyphId]!.add(characterCode);
  }

  bool hasMappingForGlyphId(int glyphId) {
    return glyphIdToCharacterCodes.containsKey(glyphId);
  }
}

class PMGlyphData {
  final int id;
  final int nContours;
  final int xMin;
  final int yMin;
  final int xMax;
  final int yMax;
  PMContourData? contourData;
  List<int> endIndicesOfContours = [];

  PMGlyphData(
      {required this.id,
      required this.nContours,
      required this.xMin,
      required this.yMin,
      required this.xMax,
      required this.yMax});
}

class PMContourData {
  final int instructionLength;
  final List<int> instructions;
  final int nCoords;
  final List<PMContourPoint> points;

  PMContourData(
      {required this.instructionLength,
      required this.instructions,
      required this.nCoords,
      required this.points});
}
