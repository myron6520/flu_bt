import 'dart:typed_data';

class Message {
  final String uuid;
  final String characteristicUUID;
  final Uint8List data;

  Message(this.uuid, this.characteristicUUID, this.data);
}
