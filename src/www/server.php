#!/usr/bin/env php
<?php

declare(strict_types=1);


use Swoole\WebSocket\Server;
use Swoole\Http\Request;
use Swoole\WebSocket\Frame;

require_once ("commands/discover.php");
require_once ("commands/network.php");

require_once ("commands/websetup.php");

require_once ("commands/status.php");
require_once ("commands/osbox.php");
require_once ("commands/logs.php");


require_once ("classes/CommandBase.php");
require_once ("classes/Executor.php");
require_once ("classes/ProcessMessage.php");
require_once ("classes/Pushere.php");


$executor = new Executor();
//$executor->test();


##



# check if sqlite3 db exists.
#
#  /host/etc/osbox/master.db
#  /host/etc/osbox/osbox.db




$server = new Server("0.0.0.0", 9501);
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

    echo "SWoole WebSocket Server is started at http://127.0.0.1:9501\n";
});

$server->on('open', function (Server $server, Swoole\Http\Request $request) {
    echo "connection open: {$request->fd}\n";
    //$server->tick(200, function () use ($server, $request) {
        //$server->push($request->fd, json_encode([204, time(),["noop"]]));
    //});
});

$server->on('message', function (Server $server, Frame $frame) {
    echo "On message: {$fd}\n";
    echo  "On message: {$fd}\n";
    //global $executor;
    $pusher = new Pusher($server,$frame);
    //$executor->test();

    #$pusher->push("YEEHAW");
    #$pusher->push("YEEHAW");
    $cp = new ProcessMessage($frame,$pusher);

    //$cp = new commandProcess($frame->data);
    //$server->push($frame->fd, $cp->result() );
});

$server->on('close', function (Server $server, int $fd) {
    echo "connection close: {$fd}\n";
});

$server->start();
