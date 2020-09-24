#!/usr/bin/env php
<?php

declare(strict_types=1);


use Swoole\WebSocket\Server;
use Swoole\Http\Request;
use Swoole\WebSocket\Frame;









class commandProcess{
    function __construct($data)
    {
        echo "rXeceived message: {$data}\n";
    }

    function result(){
        return json_encode(["hello", time()]);
    }
}






$server = new Server("0.0.0.0", 9501);
$server->set(["worker_num" => 1]);

$server->on("start", function (Server $server) {
    echo "Swoole WebSocket Server is started at http://127.0.0.1:9502\n";
});

$server->on('open', function (Server $server, Swoole\Http\Request $request) {
    echo "connection open: {$request->fd}\n";
    $server->tick(1000, function () use ($server, $request) {
        $server->push($request->fd, json_encode(["noop", time()]));
    });
});

$server->on('message', function (Server $server, Frame $frame) {

    $cp new commandProcess($frame->data);
    $server->push($frame->fd, $cp->result() );
});

$server->on('close', function (Server $server, int $fd) {
    echo "connection close: {$fd}\n";
});

$server->start();
