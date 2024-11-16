import 'dart:collection';

import 'pm_font_table.dart';

class PMFontTables {
  final HashMap<String, PMFontTable> _tables = HashMap<String, PMFontTable>();

  addTable(PMFontTable table) {
    _tables[table.tag] = table;
  }

  PMFontTable? getTable(String tag) {
    return _tables[tag];
  }

  PMFontTable requireFontTable(String tag) {
    final table = getTable(tag);
    if (table == null) {
      throw Exception('Table "$tag" not found');
    } else {
      return table;
    }
  }

  static final tableNameGlyf = "glyf";
  static final tableNameLoca = "loca";
  static final tableNameHead = "head";
  static final tableNameMaxp = "maxp";
  static final tableNameCmap = "cmap";
}
