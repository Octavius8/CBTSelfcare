import 'package:encrypt/encrypt.dart';
import '../config/system_constants.dart';

class Encryption {
  static String decrypt(String keyString, Encrypted encryptedData) {
    final key = Key.fromUtf8(keyString);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final initVector = IV.fromUtf8(keyString.substring(0, 16));
    print("IV: " + initVector.base64);
    return encrypter.decrypt(encryptedData, iv: initVector);
  }

  static String encrypt(String plainText) {
    String keyString = SystemConstants.encryption_key;
    final key = Key.fromUtf8(keyString);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final initVector = IV.fromUtf8(keyString.substring(0, 16));
    Encrypted encryptedData = encrypter.encrypt(plainText, iv: initVector);
    return encryptedData.base64;
  }
}
