import 'pm_font_table.dart';
import 'pm_font_tables.dart';

import 'pm_codepoint_to_glyph_table.dart';
import 'pm_contour_point.dart';
import 'dart:ui';

/**
* Text to Path Maker
* Copyright Ashraff Hathibelagal 2019
*/

/// Represents a Font. Objects of this class must be generated
/// by the FontReader class.
class PMFont {
  final int sfntVersion;
  final int numTables;
  final int searchRange;
  final int entrySelector;
  final int rangeShift;
  final PMCodepointToGlyphTable codepointToGlyphTable;
  final PMFontTables tables;
  final int numGlyphs;

  PMFont(
      {required this.sfntVersion,
      required this.numTables,
      required this.searchRange,
      required this.entrySelector,
      required this.rangeShift,
      required this.codepointToGlyphTable,
      required this.tables,
      required this.numGlyphs});

  /// Converts a character into a Flutter [Path] you can
  /// directly draw on a [Canvas]. Returns null, if the code point
  /// could not be found.
  Path? generatePathForCharacterOrNull(int codepoint) {
    var svgPath = generateSVGPathForCharacterOrNull(codepoint);
    if (svgPath == null) {
      return null;
    }
    final commands = svgPath.split(" ");
    final path = Path();
    commands.forEach((command) {
      if (command.startsWith("M")) {
        final coords = command.substring(1).split(",");
        final x = double.parse(coords[0]);
        final y = double.parse(coords[1]);
        path.moveTo(x, y);
      }
      if (command.startsWith("L")) {
        final coords = command.substring(1).split(",");
        final x = double.parse(coords[0]);
        final y = double.parse(coords[1]);
        path.lineTo(x, y);
      }
      if (command.startsWith("Q")) {
        final coords = command.substring(1).split(",");
        final x1 = double.parse(coords[0]);
        final y1 = double.parse(coords[1]);
        final x2 = double.parse(coords[2]);
        final y2 = double.parse(coords[3]);
        path.quadraticBezierTo(x1, y1, x2, y2);
      }
      if (command.startsWith("z")) {
        path.close();
      }
    });

    return path;
  }

  /// Converts a character into a Flutter [Path] you can
  /// directly draw on a [Canvas]. Returns an empty path, if the codepoint
  /// cannot be found.
  Path generatePathForCharacter(int codepoint) {
    final path = generatePathForCharacterOrNull(codepoint);
    if (path == null) {
      return Path();
    } else {
      return path;
    }
  }

  Iterable<int> get codePoints {
    return codepointToGlyphTable.codePoints;
  }

  /// Takes a codepoint and returns an SVG Path string (if the character could be found),
  /// or null if the character could not be found.
  String? generateSVGPathForCharacterOrNull(int codepoint) {
    int? glyphId = codepointToGlyphTable.glyphForCodePoint(codepoint);
    if (glyphId == null) {
      return null;
    }

    final glyphsTable = tables.requireFontTable(PMFontTables.tableNameGlyf);
    final glyphsTableData = glyphsTable.tryGettingData<PMGlyfFontTableData>();

    if (glyphsTableData == null) {
      return null;
    }
    final glyphs = glyphsTableData.glyphs;
    if (glyphId < 0 || glyphId >= glyphs.length) {
      return null;
    }
    final glyphData = glyphs[glyphId];

    var contours = _contourify(
        glyphData.contourData?.points ?? [], glyphData.endIndicesOfContours);

    var path = "";

    for (int k = 0; k < contours.length; k++) {
      final contour = contours[k];

      var interpolated = <PMContourPoint>[];
      for (var i = 0; i < contour.length - 1; i++) {
        interpolated.add(contour[i]);
        if (!contour[i].isOnCurve && !contour[i + 1].isOnCurve) {
          final t = PMContourPoint(
              flag: 0,
              isOnCurve: true,
              x: (contour[i].x + contour[i + 1].x) / 2,
              y: (contour[i].y + contour[i + 1].y) / 2);
          interpolated.add(t);
        }
      }
      interpolated.add(contour[contour.length - 1]);
      var lastPoint = contour[contour.length - 1];
      if (!lastPoint.isOnCurve) {
        final t = PMContourPoint(
            flag: 0,
            isOnCurve: true,
            x: (lastPoint.x + contour[0].x) / 2,
            y: (lastPoint.y + contour[0].y) / 2);
        interpolated.add(t);
      }

      var pos = 0;
      for (var i = 0; i < interpolated.length - 1; i++) {
        if (i == 0) {
          path = path + "M${interpolated[i].x},${interpolated[i].y} ";
        } else {
          if (!interpolated[i].isOnCurve) {
            path = path + "Q${interpolated[i].x},${interpolated[i].y},";
            path = path + "${interpolated[i + 1].x},${interpolated[i + 1].y} ";
            i++;
          } else {
            path = path + "L${interpolated[i].x},${interpolated[i].y} ";
          }
        }
        pos = i;
      }
      if ((pos + 1) < interpolated.length) {
        path = path + "L${interpolated[pos + 1].x},${interpolated[pos + 1].y} ";
      }
      path = path + "z ";
    }
    return path;
  }

  /// Takes a character code (codepoint) and returns an SVG Path string.
  /// Returns an empty string if the character could not be found.
  String generateSVGPathForCharacter(int codepoint) {
    final stringOrNull = generateSVGPathForCharacterOrNull(codepoint);
    if (stringOrNull == null) {
      return "";
    } else {
      return stringOrNull;
    }
  }

  /// Groups the points of a glyph into contours. Returns a
  /// list of contours
  List<List<PMContourPoint>> _contourify(
      List<PMContourPoint> points, List<int> endPoints) {
    var contours = <List<PMContourPoint>>[];
    var currentContour = <PMContourPoint>[];
    for (var i = 0; i < points.length; i++) {
      currentContour.add(points[i]);
      for (var j = 0; j < endPoints.length; j++) {
        if (i == endPoints[j]) {
          contours.add(currentContour);
          currentContour = [];
        }
      }
    }
    return contours;
  }
}
