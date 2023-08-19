<?php
echo "<pre>\n";
$key = base64_decode("G0HPTE61KCQ+CYn3voqMlFnXEtpaow6gYDqaaGSVzuE=");
$textToEncrypt = "Hello world! This my secret message.";
$iv = base64_decode('b3902f0a5e90b20577fcc62e');
echo "BASE64(IV)=" . base64_encode($iv) . "\n";
$encrypted = openssl_encrypt($textToEncrypt, 'aes-256-cbc', $key, 0, $iv);
echo "encrypted output=" . $encrypted . "\n";
//  PART 2. DECRYPT - do the reverse
$decrypted = openssl_decrypt($encrypted,  'aes-256-cbc', $key, 0, $iv);
echo "decrypted output=" . $decrypted . "\n";
 




echo "\n" . "Reference test with fixed IV" . "\n";
$iv = base64_decode("cJrccDraCqm7rQXdOsS8Zg==");
echo "BASE64(IV)=" . base64_encode($iv) . "\n";
$encrypted = openssl_encrypt($textToEncrypt, 'aes-256-cbc', $key, 0, $iv);
echo "encrypted output=" . $encrypted . "\n";
echo "expected output =" . "p+aQDK8isX68i+PPl4uhsYW2sJFR40a+nbnj29wd2TN1mnvWmiI4EU12CsRWlEp0" . "\n";
$decrypted = openssl_decrypt($encrypted,  'aes-256-cbc', $key, 0, $iv);
echo "decrypted output=" . $decrypted . "\n";
echo "</pre>\n";