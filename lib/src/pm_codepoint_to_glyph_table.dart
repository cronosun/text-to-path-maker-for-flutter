/// Maps codepoints to glyph indices.
///
/// Use case: When creating a path, we get a codepoint, but need the glyph index.
class PMCodepointToGlyphTable {
  final Map<int, int> _codePointToGlyph;

  PMCodepointToGlyphTable(this._codePointToGlyph);

  int? glyphForCodePoint(int codePoint) {
    return _codePointToGlyph[codePoint];
  }

  Iterable<int> get codePoints => _codePointToGlyph.keys;
}
