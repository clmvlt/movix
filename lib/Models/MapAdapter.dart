import 'package:hive/hive.dart';

class MapAdapter extends TypeAdapter<Map<String, dynamic>> {
  @override
  final int typeId = 1;

  @override
  Map<String, dynamic> read(BinaryReader reader) {
    return Map<String, dynamic>.from(reader.readMap());
  }

  @override
  void write(BinaryWriter writer, Map<String, dynamic> obj) {
    writer.writeMap(obj);
  }
}
