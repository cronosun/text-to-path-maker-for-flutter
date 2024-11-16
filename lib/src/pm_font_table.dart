/**
* Text to Path Maker
* Copyright Ashraff Hathibelagal 2019
*/

/// Represent a font table
class PMFontTable {
  final String tag;
  final int offset;
  final int length;
  final int checkSum;
  dynamic data;

  PMFontTable(
      {required this.tag,
      required this.offset,
      required this.length,
      required this.checkSum});
}
