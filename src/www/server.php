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



class discover {

    function __construct($subcommands)
    {

    }

    function osbox(){
        return "x";
    }

    function osboxmaster(){
        return "x";
    }
}




class commandProcess{

    private $statusCode = 500;
    private $statusMsg  = "Unknown error";


    function __construct($frame,$server)
    {
        $this->SocketServer = $server;
        $this->command = $frame->data;

        echo "received message: {$frame->fd}\n";
        echo "received message: {$frame->data}\n";

        try{
            $this->command_exists($this->command);

        }catch( Exception $e){
            $x = $this->result($e->getMessage() );
            $this->SocketServer ->push($frame->fd, $x );
            return;
        }



        $this->statusCode=200;
        $this->statusMsg="ok";

        $this->SocketServer ->push($frame->fd, $this->result("xxxxx") );

    }


    function command_exists($command){
        $cmdparts = explode('|', $command);
        $class = "\\".$cmdparts[0];

        if( !class_exists($class) ){
            //echo "class '".$class."' doenst exist\n";
            $this->statusCode = 500;
            $this->statusMsg = "Invalid command";
            throw new Exception("Invalid command");
        }

        $subcommands = explode(" ", $cmdparts[1] );
        //echo "subcommands = ".json_encode($subcommands)."\n";

        $subcommand = $subcommands[0];
        //echo "> ".json_encode($subcommands )."\n";
        //echo " ". json_encode(get_class_methods($class) )."\n";
        echo "subcommand:".$subcommand."\n";


        if( ! in_array($subcommand,get_class_methods($class))  ){
            //echo "method ".$subcommand." doesnt exist.\n";
            $this->statusCode = 500;
            $this->statusMsg = "Invalid method";
            throw new Exception("Invalid method");
        }

        $this->class = new $class($subcommands);

    }





    function result(){
        $data = 4;
        return $this->outputFormat( $data );
    }

    function outputFormat($data){
        return json_encode( [$this->statusCode, time(), array(
            "code"=>$this->statusCode,
            "msg"=>$this->statusMsg,
            "cmd"=>$this->command,
            "result"=>(object)$data )] );
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
    //$server->push($frame->fd, $cp->result() );
});

$server->on('close', function (Server $server, int $fd) {
    echo "connection close: {$fd}\n";
});

$server->start();
