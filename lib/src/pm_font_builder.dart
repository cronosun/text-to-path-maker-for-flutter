import 'package:cronosun_text_to_path_maker/cronosun_text_to_path_maker.dart';

import 'pm_codepoint_to_glyph_table.dart';
import 'pm_font_tables.dart';

class PMFontBuilder {
  int? sfntVersion;
  int numTables = 0;
  int? searchRange;
  int? entrySelector;
  int? rangeShift;
  PMFontTables tables = PMFontTables();
  int numGlyphs = 0;
  PMCodepointToGlyphTable? codepointToGlyphTable;

  PMFont build() {
    if (sfntVersion == null) {
      throw Exception("sfntVersion is required");
    }
    if (searchRange == null) {
      throw Exception("searchRange is required");
    }
    if (entrySelector == null) {
      throw Exception("entrySelector is required");
    }
    if (rangeShift == null) {
      throw Exception("rangeShift is required");
    }
    if (codepointToGlyphTable == null) {
      throw Exception("codepointToGlyphTable is required");
    }
    return PMFont(
        sfntVersion: sfntVersion!,
        numTables: numTables,
        searchRange: searchRange!,
        entrySelector: entrySelector!,
        rangeShift: rangeShift!,
        codepointToGlyphTable: codepointToGlyphTable!,
        tables: tables,
        numGlyphs: numGlyphs);
  }
}
