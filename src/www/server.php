#!/usr/bin/env php
<?php

declare(strict_types=1);


use Swoole\WebSocket\Server;
use Swoole\Http\Request;
use Swoole\WebSocket\Frame;



require_once ("classes/Pusher.php");
require_once ("classes/ProcessMessage.php");

require_once ("classes/CommandBase.php");

require_once ("classes/Executor.php");







require_once ("commands/discover.php");
require_once ("commands/network.php");

require_once ("commands/websetup.php");

require_once ("commands/status.php");
require_once ("commands/osbox.php");
require_once ("commands/logs.php");


#$executor = new Executor();
//$executor->test();

##

function x( $command="/usr/bin/php",$options=array("./testexec.php") ){
    // parent process
    $process = new Swoole\Process(function ($process)
    {
        //execute the external program
        $process->exec("/usr/bin/php", array('-v'));
    }, TRUE); // enable the redirection of stdin and stdout

    $process->start();

    //Inter-Process Communication Of main process and child process by stdin and stdout

    #$process->write("hello child process from main process");

    $res = $process->read();

    var_dump($res);
}

# check if sqlite3 db exists.
#
#  /host/etc/osbox/master.db
#  /host/etc/osbox/osbox.db




$server = new Server("0.0.0.0", 81);

$server->set([
    "worker_num" => 2,
    'daemonize' => true,
    'pid_file' => '/run/swoole.pid',
    // logging
    'log_level' => 1,
    'log_file' => '/var/log/osbox-swoole.log',
    'log_rotation' => SWOOLE_LOG_ROTATION_DAILY | SWOOLE_LOG_ROTATION_SINGLE,
    'log_date_format' => true, // or "day %d of %B in the year %Y. Time: %I:%S %p",
    'log_date_with_microseconds' => false,

]);

$server->on("start", function (Server $server) {

    echo "SWoole WebSocket Server is started at http://127.0.0.1:81\n";
});

$server->on('open', function (Server $server, Swoole\Http\Request $request) {
    echo "connection open: {$request->fd}\n";
    //$server->tick(200, function () use ($server, $request) {
        //$server->push($request->fd, json_encode([204, time(),["noop"]]));
    //});
});

$server->on('message', function (Server $server, Frame $frame) {
    echo "On message: ".$frame->fd."\n";

    $pusher = new Pusher($server,$frame);
    $cp = new ProcessMessage($frame,$pusher);

});

$server->on('close', function (Server $server, int $fd) {
    echo "connection close: {$fd}\n";
});

$server->start();
