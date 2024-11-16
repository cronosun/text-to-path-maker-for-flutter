import 'dart:typed_data';

class PMCursor {
  final ByteData _data;
  int _offset = 0;

  PMCursor({required ByteData data, required int offset})
      : _data = data,
        _offset = offset;

  int get offset => _offset;

  set offset(int offset) {
    _offset = offset;
  }

  skip(int numberOfBytes) {
    _offset += numberOfBytes;
  }

  int getUint32([Endian endian = Endian.big]) {
    final value = _data.getUint32(_offset, endian);
    _offset += 4;
    return value;
  }

  int getUint16([Endian endian = Endian.big]) {
    final value = _data.getUint16(_offset, endian);
    _offset += 2;
    return value;
  }

  int getInt32([Endian endian = Endian.big]) {
    final value = _data.getInt32(_offset, endian);
    _offset += 4;
    return value;
  }

  int getInt16([Endian endian = Endian.big]) {
    final value = _data.getInt16(_offset, endian);
    _offset += 2;
    return value;
  }

  int getUint8() {
    final value = _data.getUint8(_offset);
    _offset += 1;
    return value;
  }

  int getInt8() {
    final value = _data.getInt8(_offset);
    _offset += 1;
    return value;
  }
}
