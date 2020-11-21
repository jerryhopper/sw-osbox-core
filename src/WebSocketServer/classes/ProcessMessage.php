<?php


use Swoole\WebSocket\Server;
use Swoole\Http\Request;
use Swoole\WebSocket\Frame;


class ProcessMessage
{

    private $statusCode = 500;
    private $statusMsg = "Unknown error";


    function __construct(Frame $frame, $pusher)
    {
        $this->pusher = $pusher;
        $this->frame = $frame;
        $this->command = $frame->data;

        echo "received message: {$frame->fd}\n";
        echo "received message: {$frame->data}\n";

        try {
            $this->command_exists($this->command);

        } catch (Exception $e) {
            //$x = $this->result($e->getMessage() );
//$type , $text, $data)
            //$pusher->push( "INFO", "title", "text" )
            $this->pusher->push("ERROR",  $e->getMessage());
            return;
        }

        //$this->x();

        $this->class->_result();

    }


    function x (){
        go(function() {
            $ret = Co\System::exec("md5sum ".__FILE__);
            echo json_encode($ret);
        });

        //Co\run(function() {
        go(function () {
            co::sleep(3.0);
            //go(function () {
            //    co::sleep(2.0);
            //    echo "co[3] end\n";
            //});
            echo "co[2] end\n";
        });

        co::sleep(1.0);
        echo "co[1] end\n";
        //});
    }


    function command_exists($command){
        $cmdparts = explode(' ', $command);
        //print_r($cmdparts);
        # [0] osbox
        # [1] discover  (class)
        # [2] all (class:method)

        $class = "\\".$cmdparts[1];
        $method = $cmdparts[2];
        //echo "xxx";

        $subcommands = array_splice($cmdparts,2);
        //print_r($subcommands);
        if($class=="\\"){
            $class="\\osbox";
        }

        if( !class_exists($class) ){
            echo "class '".$class."' doesnt exist\n";
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
