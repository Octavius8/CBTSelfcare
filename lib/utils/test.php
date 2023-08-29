<?php
$ciphering = "AES-128-CBC";
$options = 0;
$simple_string = 'E4TqkFnbCWRGpI+E8i79vsc5VlyIW0drOslW8pQyzwfDIwjX0Hk8jPJZMbNRFehcmsuK+a3qMdAK4EaVsv1zWw==';
$decryption_iv = 'YoZr16CharactXrK';
$decryption_key = "YoZr16CharactXrK";
$decryption=openssl_decrypt ($simple_string, $ciphering,
		$decryption_key, $options, $decryption_iv);
echo "Decrypted data is: ".$decryption;
?>

$ java -jar pepk.jar  --keystore=/Users/user/Workspace/cbt/CBTSelfcare/android/app/upload-keystore.jks --alias=key --output=/Users/user/Workspace/cbt/CBTSelfcare/android/app/output.zip --include-cert --rsa-aes-encryption --encryption-key-path=/Users/user/Workspace/cbt/CBTSelfcare/android/app/encryption_public_key.pem

keytool -exportcert -alias selfsigned -keypass password -keystore upload-keystore.jks -rfc -file upload-keystore.pem -cp "Library/Java/Extensions/bc-noncert-1.0.2.4.jar;lib/*"

java -jar pepk.jar --keystore=upload-keystore.jks --alias=key --output=output.zip --include-cert --rsa-aes-encryption --encryption-key-path=encryption_public_key.pem -cp "Library/Java/Extensions/bc-noncert-1.0.2.4.jar;lib/*"