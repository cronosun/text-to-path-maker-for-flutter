import 'package:flutter/rendering.dart';

/// Utility class to perform transform operations on a [Path] object
class PMTransform {
  /// Translate and scale a path to desired location and size
  static Path moveAndScale(
      Path path, double posX, double posY, double scaleX, double scaleY) {
    var transformMatrix = Matrix4.identity();
    transformMatrix.translate(posX, posY);
    transformMatrix.scale(scaleX, -scaleY);
    return path.transform(transformMatrix.storage);
  }

  /// Normalize a path. Details:
  ///
  ///  - Translates the path so that the top-left corner of the bounding box is at (0, 0)
  ///  - Mirrors along the Y-axis, so the path is not upside down.
  ///  - Note: Does NOT scale the path.
  static Path normalizePath(Path path) {
    final bounds = path.getBounds();

    final transformMatrix = Matrix4.identity();
    transformMatrix.translate(-bounds.left, bounds.bottom);
    transformMatrix.scale(1.0, -1.0);
    return path.transform(transformMatrix.storage);
  }
}
