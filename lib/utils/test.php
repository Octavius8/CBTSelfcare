<?php
$ciphering = "AES-128-CBC";
$options = 0;
$simple_string = 'ZMPfMnSbw0KFpJqT0TcI/BBbDl8M7RrrCYVqc2xAlv/nz00Hl1TzCYAUazzuthGAgFmaZAcNNcol4KKXAcNJwA==';
$decryption_iv = 'YoZr16CharactXrK';
$decryption_key = "YoZr16CharactXrK";
$decryption=openssl_decrypt ($simple_string, $ciphering,
		$decryption_key, $options, $decryption_iv);
echo $decryption;
?>