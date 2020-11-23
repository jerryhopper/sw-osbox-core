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
            $this->process_message($this->command);

        } catch (Exception $e) {
            //$x = $this->result($e->getMessage() );
//$type , $text, $data)
            //$pusher->push( "INFO", "title", "text" )
            $this->pusher->push("ERROR", "Error!", $e->getMessage());
            return;
        }

        //$this->x();

        #$this->class->_result();

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


    function process_message($message){

        if(trim($message)==""){
            $this->statusCode = 500;
            $this->statusMsg = "Invalid message (".$message.")\n";
            echo "Invalid command (".$message.")";
            throw new Exception("Invalid message (".$message.")");
        }

        #echo "\n";
        $commandParts = explode(' ', trim($message),3);


        # class
        $class = "\\".trim($commandParts[0]);

        # check if class exists
        if( !class_exists($class) ){
            #echo "class '".$class."' doesnt exist\n";
            $this->statusCode = 500;
            $this->statusMsg = "Invalid class\n";
            //echo "Invalid command";
            throw new Exception("command '".$commandParts[0]."' doesnt exist");
        }




        $COMMAND =array( "class"=>$class );

        # method
        if(isset( $commandParts[1] )){
            $method = trim($commandParts[1]);
        }else{
            $method = "default";
            $params = "";
        }

        # arguments
        if(isset( $commandParts[2] )){
            $args = trim($commandParts[2] );
        }else{
            $args = "";
        }





        echo "Class = $class\n";
        echo "Method = $method\n";
        echo "Arguments = $args \n";

        if( ! in_array($method,get_class_methods($class))  ){
            #echo "method ".$method." doesnt exist.\n";
            $this->statusCode = 500;
            $this->statusMsg = "Invalid method\n";
            throw new Exception("method ".$method." doesnt exist");
        }

        #echo "Class = $class\n";
        #echo "Method = $method\n";
        #echo "Arguments = $args \n";


        $this->class = new $class($this->pusher);

        $this->class->$method($args);

    }

    function command_exists($command){

        # check if command is empty
        if(trim($command)==""){
            $this->statusCode = 500;
            $this->statusMsg = "Invalid command (".$command.")\n";
            echo "Invalid command (".$command.")";
            throw new Exception("Invalid command (".$command.")");
        }


        $commandParts = explode(' ', $command,3);

        print_r($commandParts);
        $cmd = $commandParts[0];
        $class = "\\".$cmd;

        # check if class exists
        if( !class_exists($class) ){
            echo "class '".$class."' doesnt exist\n";
            $this->statusCode = 500;
            $this->statusMsg = "Invalid class\n";
            //echo "Invalid command";
            throw new Exception("Invalid class");
        }

        #
        if(isset($commandParts[1])) {
            $method = $commandParts[1];
        }else{
            $method = "default";
        }

        #
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


        throw new Exception("End");
















        if(isset($commandParts[2])) {
            $rest    = $commandParts[2];
        }



        $cmdparts = explode(' ', $command);
        //print_r($cmdparts);
        # [0] osbox
        # [1] discover  (class)
        # [2] all (class:method)

        $class = "\\".$cmd;


        if(isset($cmdparts[2])) {
            $method = $cmdparts[2];
        }else{
            $method = "";
        }

        //echo "xxx";

        $subcommands = array_splice($cmdparts,2);
        //print_r($subcommands);
        if($class=="\\"){
            //$class="\\osbox";
        }

        if( !class_exists($class) ){
            echo "class '".$class."' doesnt exist\n";
            $this->statusCode = 500;
            $this->statusMsg = "Invalid command\n";
            //echo "Invalid command";
            throw new Exception("Invalid command");
        }

        //echo "method:".$method."|\n";


        print_r($subcommands);


        $this->class = new $class($subcommands,$this->pusher);

    }

}
