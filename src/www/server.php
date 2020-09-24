#!/usr/bin/env php
<?php

declare(strict_types=1);


use Swoole\WebSocket\Server;
use Swoole\Http\Request;
use Swoole\WebSocket\Frame;



/*

discover|osbox
discover|osboxmaster

response :
command: discover|osbox
code: 200
msg: ok
data: {

}



 */





class commandProcess{

    private $statusCode = 500;
    private $statusMsg  = "Unknown error";



    function __construct($frame,$server)
    {
        $this->SocketServer = $server;
        $this->command = $frame->fd;

        echo "rXeceived message: {$frame->fd}\n";


        $this->SocketServer ->push($this->command, $this->result() );

    }








    function result(){

        $x = 1;

        return $this->outputFormat( ["hello", time()] );
    }

    function outputFormat($data){
        return (object)array(
            "code"=>$this->statusCode,
            "msg"=>$this->statusMsg,
            "cmd"=>$this->command,
            "data"=>$data);
    }
}






$server = new Server("0.0.0.0", 9501);
$server->set(["worker_num" => 2]);

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

    $cp = new commandProcess($frame,$server);

    //$cp = new commandProcess($frame->data);
    $server->push($frame->fd, $cp->result() );
});

$server->on('close', function (Server $server, int $fd) {
    echo "connection close: {$fd}\n";
});

$server->start();
