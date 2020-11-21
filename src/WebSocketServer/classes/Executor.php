<?php


use Swoole\WebSocket\Server;
use Swoole\Http\Request;
use Swoole\WebSocket\Frame;

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
