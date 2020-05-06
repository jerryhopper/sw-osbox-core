<?php

require_once( "/usr/local/osbox/project/sw-osbox-core/src/Classes/osboxSsl.php");


$ssl = new osboxSsl();

$ssl->requestCertificate();

echo "ok";

