import 'package:encrypt/encrypt.dart';

void main() {
  final key = "YoZr16CharactXrK";
  final plainText = "We need a proper example,if you know what I mean";
  Encrypted encrypted = encrypt(key, plainText);
  print("encrypted text:" + encrypted.base64);
  String decryptedText = decrypt(key, encrypted);
  print(decryptedText);
}

String decrypt(String keyString, Encrypted encryptedData) {
  final key = Key.fromUtf8(keyString);
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  final initVector = IV.fromUtf8(keyString.substring(0, 16));
  print("IV: " + initVector.base64);
  return encrypter.decrypt(encryptedData, iv: initVector);
}

Encrypted encrypt(String keyString, String plainText) {
  final key = Key.fromUtf8(keyString);
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  final initVector = IV.fromUtf8(keyString.substring(0, 16));
  Encrypted encryptedData = encrypter.encrypt(plainText, iv: initVector);
  return encryptedData;
}
