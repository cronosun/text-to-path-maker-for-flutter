import 'dart:typed_data';
import 'dart:io';

import 'pm_font_builder.dart';
import 'package:cronosun_text_to_path_maker/cronosun_text_to_path_maker.dart';

import 'pm_codepoint_to_glyph_table.dart';
import 'pm_contour_point.dart';
import 'pm_font_table.dart';
import 'pm_font_tables.dart';

/**
* Text to Path Maker
* Copyright Ashraff Hathibelagal 2019
*/

/// This class contains all the code required to read the contents of
/// a .ttf file.
class PMFontReader {
  ByteData fontData = ByteData(0);
  var font = PMFontBuilder();

  /// Use this method to convert a .ttf file into a PMFont object.
  /// It expects you to pass the path of the .ttf file as its only argument.
  Future<PMFont> parseTTF(path) {
    return File(path).readAsBytes().then((data) {
      fontData = ByteData.view(data.buffer);
      return _parseTTF();
    });
  }

  /// Use this method to convert a .ttf file you have in your assets folder into
  /// a PMFont object.
  PMFont parseTTFAsset(ByteData data) {
    fontData = data;
    return _parseTTF();
  }

  /// This method is responsible for calling a bunch of methods that parse
  /// the tables in the font file. It returns a PMFont object.
  PMFont _parseTTF() {
    // If the reader is used multiple times, reset it's state.
    font = PMFontBuilder();

    final offset = _initializeOffsetTable();
    _initializeTables(offset);
    _readHead();
    _setNumGlyphs();
    _createGlyphs();
    _getCharacterMappings();

    return font.build();
  }

  /// Initializes the offset table in the .ttf file
  int _initializeOffsetTable() {
    int offset = 0;
    font.sfntVersion = fontData.getUint32(offset);
    offset += 4;
    font.numTables = fontData.getUint16(offset);
    offset += 2;
    font.searchRange = fontData.getUint16(offset);
    offset += 2;
    font.entrySelector = fontData.getUint16(offset);
    offset += 2;
    font.rangeShift = fontData.getUint16(offset);
    offset += 2;
    return offset;
  }

  /// Initializes objects for all the tables in the .ttf file
  void _initializeTables(offset) {
    for (int i = 0; i < font.numTables; i++) {
      final tag = _getTag(fontData, offset);
      offset += 4;
      final checkSum = fontData.getUint32(offset);
      offset += 4;
      final tableOffset = fontData.getUint32(offset);
      offset += 4;
      final length = fontData.getUint32(offset);
      offset += 4;

      final table = new PMFontTable(
          tag: tag, offset: tableOffset, length: length, checkSum: checkSum);
      font.tables.addTable(table);
    }
  }

  /// Each table has a tag, which is composed of 4 characters. This
  /// method reads all the four characters and concatenates them into
  /// a string.
  String _getTag(ByteData fontData, int offset) {
    List<int> charCodes = List.empty(growable: true);
    charCodes.add(fontData.getUint8(offset));
    charCodes.add(fontData.getUint8(offset + 1));
    charCodes.add(fontData.getUint8(offset + 2));
    charCodes.add(fontData.getUint8(offset + 3));
    return String.fromCharCodes(charCodes);
  }

  /// Reads the glyf and loca tables to determine a bunch of coordinates that
  /// can be used to form a glyph.
  void _createGlyphs() {
    final fontTables = font.tables;
    final glyfFontTable =
        fontTables.requireFontTable(PMFontTables.tableNameGlyf);
    final headFontTable = fontTables.getTable(PMFontTables.tableNameHead);
    var startGlyfOffset = glyfFontTable.offset;
    var startLocaOffset =
        fontTables.requireFontTable(PMFontTables.tableNameLoca).offset;

    final tableData = PMGlyfFontTableData();
    glyfFontTable.setData(tableData);

    for (int i = 0; i < font.numGlyphs; i++) {
      int glyphOffset = startGlyfOffset;

      final indexToLocFormat = headFontTable
          ?.tryGettingData<PMHeaderFontTableData>()
          ?.indexToLocFormat;
      if (indexToLocFormat != null && indexToLocFormat == 0) {
        glyphOffset += fontData.getUint16(startLocaOffset) * 2;
        startLocaOffset += 2;
      } else {
        glyphOffset += fontData.getUint32(startLocaOffset);
        startLocaOffset += 4;
      }

      final gdId = i;
      final gdNContours = fontData.getInt16(glyphOffset);
      glyphOffset += 2;
      final gdXMin = fontData.getInt16(glyphOffset);
      glyphOffset += 2;
      final gdYMin = fontData.getInt16(glyphOffset);
      glyphOffset += 2;
      final gdXMax = fontData.getInt16(glyphOffset);
      glyphOffset += 2;
      final gdYMax = fontData.getInt16(glyphOffset);
      glyphOffset += 2;

      final glyphData = PMGlyphData(
          id: gdId,
          nContours: gdNContours,
          xMin: gdXMin,
          yMin: gdYMin,
          xMax: gdXMax,
          yMax: gdYMax);
      tableData.addGlyph(glyphData);

      if (glyphData.nContours > 0) {
        for (var j = 0; j < glyphData.nContours; j++) {
          glyphData.endIndicesOfContours.add(fontData.getUint16(glyphOffset));
          glyphOffset += 2;
        }

        final cdInstructionLength = fontData.getUint16(glyphOffset);
        glyphOffset += 2;

        final cdInstructions = <int>[];
        if (cdInstructionLength > 0) {
          for (var j = 0; j < cdInstructionLength; j++) {
            cdInstructions.add(fontData.getUint8(glyphOffset));
            glyphOffset += 1;
          }
        }

        final int cdNCords;
        final endIndicesOfContours = glyphData.endIndicesOfContours;
        if (endIndicesOfContours.length > 0) {
          cdNCords = endIndicesOfContours[endIndicesOfContours.length - 1] + 1;
        } else {
          cdNCords = 0;
        }

        // Contour data flags
        final cdFlags = <int>[];
        for (var j = 0; j < cdNCords; j++) {
          var flag = fontData.getUint8(glyphOffset);
          glyphOffset += 1;
          cdFlags.add(flag);

          if ((flag & 0x08) == 0x08) {
            var times = fontData.getUint8(glyphOffset);
            glyphOffset += 1;
            for (var k = 0; k < times; k++) {
              cdFlags.add(flag);
              j += 1;
            }
          }
        }

        // Points: is on curve?
        final cdPointsIsOnCurve = <bool>[];
        for (var j = 0; j < cdFlags.length; j++) {
          final flag = cdFlags[j];
          final bool pointIsOnCurve = ((flag & 0x01) == 0x01);
          cdPointsIsOnCurve.add(pointIsOnCurve);
        }

        // Load X coordinates
        int prevX = 0;
        final cdPointsX = <int>[];
        for (var j = 0; j < cdFlags.length; j++) {
          final flag = cdFlags[j];
          int pointX = 0;
          int curX = 0;
          if ((flag & 0x02) == 0x02) {
            curX = fontData.getUint8(glyphOffset);
            glyphOffset += 1;
            if ((flag & 0x10) == 0) {
              curX *= -1;
            }
            pointX = prevX + curX;
          } else {
            if ((flag & 0x10) == 0x10)
              pointX = prevX;
            else {
              pointX = prevX + fontData.getInt16(glyphOffset);
              glyphOffset += 2;
            }
          }
          prevX = pointX;
          cdPointsX.add(pointX);
        }

        // Load Y coordinates
        int prevY = 0;
        final cdPointsY = <int>[];
        for (var j = 0; j < cdFlags.length; j++) {
          final flag = cdFlags[j];
          int pointY = 0;
          int curY = 0;
          if ((flag & 0x04) == 0x04) {
            curY = fontData.getUint8(glyphOffset);
            glyphOffset += 1;
            if ((flag & 0x20) == 0) {
              curY *= -1;
            }
            pointY = prevY + curY;
          } else {
            if ((flag & 0x20) == 0x20)
              pointY = prevY;
            else {
              pointY = prevY + fontData.getInt16(glyphOffset);
              glyphOffset += 2;
            }
          }
          prevY = pointY;
          cdPointsY.add(pointY);
        }

        // Collect points
        final cdPoints = <PMContourPoint>[];
        for (var j = 0; j < cdFlags.length; j++) {
          final isOnCurve = cdPointsIsOnCurve[j];
          final flag = cdFlags[j];
          final pointX = cdPointsX[j];
          final pointY = cdPointsY[j];

          final point = PMContourPoint(
              x: pointX.toDouble(),
              y: pointY.toDouble(),
              isOnCurve: isOnCurve,
              flag: flag);
          cdPoints.add(point);
        }

        final contourData = PMContourData(
            instructionLength: cdInstructionLength,
            instructions: cdInstructions,
            nCoords: cdNCords,
            points: cdPoints);
        glyphData.contourData = contourData;
      }
    }
  }

  /// Reads the head table.
  void _readHead() {
    final fontTables = font.tables;
    final headFontTable =
        fontTables.requireFontTable(PMFontTables.tableNameHead);

    final startOffset = headFontTable.offset;

    final magicNumber = fontData.getUint32(startOffset + 12);
    final flags = fontData.getUint16(startOffset + 16);
    final unitsPerEm = fontData.getUint16(startOffset + 18);
    final indexToLocFormat = fontData.getUint16(startOffset + 50);
    final data = PMHeaderFontTableData(
        magicNumber: magicNumber,
        flags: flags,
        unitsPerEm: unitsPerEm,
        indexToLocFormat: indexToLocFormat);
    headFontTable.setData(data);
  }

  /// Reads the maxp table to determine the number of glyphs present
  /// in the .ttf file.
  void _setNumGlyphs() {
    final fontTables = font.tables;
    final maxpFontTable =
        fontTables.requireFontTable(PMFontTables.tableNameMaxp);

    final startOffset = maxpFontTable.offset;
    final numGlyphs = fontData.getUint16(startOffset + 4);
    font.numGlyphs = numGlyphs;
    final tableData = PMMaxpFontTableData(numGlyphs: numGlyphs);
    maxpFontTable.setData(tableData);
  }

  /// Reads the cmap table to map glyph IDs to character codes.
  void _getCharacterMappings() {
    final fontTables = font.tables;
    final cmapFontTable =
        fontTables.requireFontTable(PMFontTables.tableNameCmap);

    int cmapOffset = cmapFontTable.offset;

    final version = fontData.getUint16(cmapOffset);
    cmapOffset += 2;

    final tableData = PMCMapFontTableData(version: version);
    cmapFontTable.setData(tableData);

    final numTables = fontData.getUint16(cmapOffset);
    cmapOffset += 2;

    // The reverse map of what we have in the header (this is actually the one
    // we need, the 'glyphIdToCharacterCodes' in the header is IMHO useless).
    final Map<int, int> codepointToGlyph = {};

    int offset = -1;
    for (int i = 0; i < numTables; i++) {
      int platformID = fontData.getUint16(cmapOffset);
      cmapOffset += 2;
      int encodingID = fontData.getUint16(cmapOffset);
      cmapOffset += 2;
      offset = fontData.getUint32(cmapOffset);
      cmapOffset += 4;
      if (platformID == 3 &&
          (encodingID == 1 || encodingID == 0 || encodingID == 10)) {
        _readFormat4Table(tableData, offset, codepointToGlyph);
      }
    }

    font.codepointToGlyphTable = PMCodepointToGlyphTable(codepointToGlyph);

    if (offset == -1) {
      throw Exception("Font not supported.");
    }
  }

  /// Reads the Format4 subtable in the cmap table
  void _readFormat4Table(
      PMCMapFontTableData data, int offset, Map<int, int> codepointToGlyph) {
    final fontTables = font.tables;
    final cmapFontTable =
        fontTables.requireFontTable(PMFontTables.tableNameCmap);
    offset = offset + cmapFontTable.offset;

    final format = fontData.getUint16(offset);
    offset += 2;

    if (format != 4) {
      if (format == 12) {
        _readFormat12Table(data, offset, codepointToGlyph);
        return;
      } else {
        throw Exception("Font not supported yet.");
      }
    }

    offset += 2;

    offset += 2; // skip language
    final nSegments = fontData.getUint16(offset) / 2;
    offset += 2;

    final endCodes = <int>[];
    for (var i = 0; i < nSegments; i++) {
      endCodes.add(fontData.getUint16(offset));
      offset += 2;
    }

    offset += 2; // step over reserved pad

    final startCodes = <int>[];
    for (var i = 0; i < nSegments; i++) {
      startCodes.add(fontData.getUint16(offset));
      offset += 2;
    }

    final idDeltas = <int>[];
    for (var i = 0; i < nSegments; i++) {
      idDeltas.add(fontData.getInt16(offset));
      offset += 2;
    }

    final idRangeOffsets = <int>[];
    for (var i = 0; i < nSegments; i++) {
      idRangeOffsets.add(fontData.getUint16(offset));
      offset += 2;
    }

    var originalOffset = offset;

    for (var i = 0; i < nSegments; i++) {
      final start = startCodes[i];
      final end = endCodes[i];
      final idDelta = idDeltas[i];
      final idRangeOffset = idRangeOffsets[i];
      int glyphIndex = -1;
      for (var j = start; j <= end; j++) {
        if (idRangeOffset == 0) {
          glyphIndex = (j + idDelta) % 65536;
          data.addGlyphIdToCharacterCode(glyphIndex, j);
          codepointToGlyph[j] = glyphIndex;
        } else {
          var nOffset = originalOffset +
              ((idRangeOffset / 2) + (j - start) + (i - nSegments)) * 2;
          var glyphIndex = fontData.getUint16(nOffset.toInt());

          if (glyphIndex != 0) {
            glyphIndex += idDelta;
            glyphIndex = glyphIndex % 65536;
            // Don't know what this does. Just applying
            // https://github.com/hathibelagal-dev/text-to-path-maker-for-flutter/issues/1
            if (!data.hasMappingForGlyphId(glyphIndex)) {
              data.addGlyphIdToCharacterCode(glyphIndex, j);
              // Note: Adding: 'codepointToGlyph[j] = glyphIndex;' will result in test
              // failures.
            }
          }
        }
      }
    }
  }

  /// Reads the Format12 subtable in the cmap table
  void _readFormat12Table(
      PMCMapFontTableData data, int offset, Map<int, int> codepointToGlyph) {
    offset += 2; // Step over reserved
    offset += 4;
    offset += 4; // skip language
    final numGroups = fontData.getUint32(offset);
    offset += 4;

    for (int i = 0; i < numGroups; i++) {
      final startCode = fontData.getUint32(offset);
      offset += 4;
      final endCode = fontData.getUint32(offset);
      offset += 4;
      int startGlyphId = fontData.getUint32(offset);
      offset += 4;
      for (int j = startCode; j <= endCode; j++) {
        data.addGlyphIdToCharacterCode(startGlyphId, j);
        codepointToGlyph[j] = startGlyphId;
        startGlyphId += 1;
      }
    }
  }
}
