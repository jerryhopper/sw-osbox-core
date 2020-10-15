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







class commandBase {
    public $method;
    public $subcommands;
    public $pusher;

    function __construct( Array $subcommands,pusher $pusher)
    {
        $this->pusher=$pusher;

        $this->method=$subcommands[0];
        $this->subcommands = $subcommands;

        echo "class! (".$this->method.")\n";

    }

    public function _result(){
        $cmd = $this->method;
        $this->$cmd();
    }

    public function _send($data,$sleep=2)
    {
        // $data
        $fp = fopen('/host/osbox/pipe', 'w');
        fwrite($fp, $data);
        fclose($fp);

        sleep($sleep);
        $filename="/host/osbox/response";
        $handle = fopen($filename, "rb");
        $contents = '';
        while (!feof($handle)) {
            $contents .= fread($handle, 8192);
        }
        echo "contents = ".strlen($contents)." characters  ( ".$contents.")\n";

        if( strpos($contents,"\n" ) ){
            echo "has newline \n";
            $contents = explode("\n",$contents);

            $contents = array_filter($contents, function($v){
                return trim($v);
            });

            //var_dump($result);
//array_slice()

            //var_dump($res);

        }

        fclose($handle);

        if ($data !=$contents[0]){
            # error?!
            echo "COMMAND ERROR!? \n";
        }
        $results = array_splice($contents,1);

        #$handle = fopen($filename, "r");
        #$contents = fread($handle, filesize($filename));
        #fclose($handle);
        return $results;
    }
}















class ProcessMessage {

    private $statusCode = 500;
    private $statusMsg  = "Unknown error";


    function __construct(Frame $frame, $pusher )
    {
        $this->pusher = $pusher;
        $this->frame = $frame;
        $this->command = $frame->data;

        echo "received message: {$frame->fd}\n";
        echo "received message: {$frame->data}\n";




        try{
            $this->command_exists($this->command);

        }catch( Exception $e){
            //$x = $this->result($e->getMessage() );

            $this->pusher->push( "error", 500, "command_exists (".$this->command.")".$e->getMessage() );
            return;
        }


        $this->class->_result();

    }




    function command_exists($command){
        $cmdparts = explode(' ', $command);
        //print_r($cmdparts);
        # [0] osbox
        # [1] discover  (class)
        # [2] all (class:method)

        $class = "\\".$cmdparts[1];
        $method = $cmdparts[2];

        $subcommands = array_splice($cmdparts,2);
        //print_r($subcommands);
        if($class=="\\"){
            $class="\\osbox";
        }

        if( !class_exists($class) ){
            echo "class '".$class."' doenst exist\n";
            $this->statusCode = 500;
            $this->statusMsg = "Invalid command\n";
            //echo "Invalid command";
            throw new Exception("Invalid command");
        }

        //echo "method:".$method."|\n";

        if($method==""){
            echo "Default method!";
            $subcommands=array("default");
            $method="default";
        }

        if( ! in_array($method,get_class_methods($class))  ){
            echo "method ".$subcommand." doesnt exist.\n";
            $this->statusCode = 500;
            $this->statusMsg = "Invalid method\n";
            throw new Exception("Invalid method");
        }

        print_r($subcommands);

        $this->class = new $class($subcommands,$this->pusher);

    }

}




class Executor{

    function __construct()
    {
        $this->process = new Swoole\Process(function($process){
            //execute the external program
            //$process->exec("/usr/bin/osbox", array(''));
        }, FALSE); // enable the redirection of stdin and stdout

        //execute the external program
//        $process->exec("/bin/ls", array(''));
//        $process->start();
//        $res = $process->read();
//        echo $res;
        //var_dump($res);
    }


    function test(){

        $fp = fopen('/hostpipe', 'w');
        fwrite($fp, 'ip addr');
        fclose($fp);

        //execute the external program
        //try{
        //    $this->process->exec("/bin/echo", array('"osbox"','>','/hostpipe'));
        //}catch(Exception $e){
        //    echo "aarg!";
        //}

        //$this->process->start();
        //$res = $this->process->read();
        echo $res;

    }

}
$executor = new Executor();

//$executor->test();



class Pusher
{
    private $socketserver;
    private $frame;

    function __construct( Server $server,Frame $frame)
    {
        $this->socketserver = $server;
        $this->frame = $frame;
    }

    public function push( $data , $statuscode=200,$statusmsg="ok"){
        echo "Pushed message!\n";
        $this->socketserver->push($this->frame->fd, $this->outputFormat( $data ,$statuscode,$statusmsg) );
    }

    private function outputFormat($data, $statuscode,$statusmsg){
        return json_encode( [$statuscode, time(), $data ] );
    }

}







# check if sqlite3 db exists.
#
#  /host/etc/osbox/master.db
#  /host/etc/osbox/osbox.db







$server = new Server("0.0.0.0", 9501);
$server->set(["worker_num" => 2]);

$server->on("start", function (Server $server) {

    echo "Swoole WebSocket Server is started at http://127.0.0.1:9502\n";
});

$server->on('open', function (Server $server, Swoole\Http\Request $request) {
    echo "connection open: {$request->fd}\n";
    //$server->tick(200, function () use ($server, $request) {
        //$server->push($request->fd, json_encode([204, time(),["noop"]]));
    //});
});

$server->on('message', function (Server $server, Frame $frame) {
    echo "On message: {$fd}\n";
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
