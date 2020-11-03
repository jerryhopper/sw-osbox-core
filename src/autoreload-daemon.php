<?php
require __DIR__.'/Swoole/ToolKit/AutoReload.php';

$filename = "/run/swoole.pid";
$handle = fopen($filename, "r");
$contents = fread($handle, filesize($filename));
fclose($handle);



$kit = new Swoole\ToolKit\AutoReload((int)trim($contents));
$kit->watch('/usr/local/osbox/project');
$kit->run();
