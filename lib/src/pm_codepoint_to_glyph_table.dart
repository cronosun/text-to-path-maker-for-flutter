class PMCodepointToGlyphTable {
  final Map<int, int> _codePointToGlyph;

  PMCodepointToGlyphTable(this._codePointToGlyph);

  int? glyphForCodePoint(int codePoint) {
    return _codePointToGlyph[codePoint];
  }

  Iterable<int> get codePoints => _codePointToGlyph.keys;
}
