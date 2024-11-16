/**
* Text to Path Maker
* Copyright Ashraff Hathibelagal 2019
*/

/// Represents a point in the contours of a glyph.
class PMContourPoint {
  final bool isOnCurve;
  final double x;
  final double y;
  final int flag;

  PMContourPoint(
      {required this.isOnCurve,
      required this.x,
      required this.y,
      required this.flag});
}
