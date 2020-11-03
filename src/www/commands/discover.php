<?php



use Swoole\WebSocket\Server;
use Swoole\Http\Request;
use Swoole\WebSocket\Frame;


class discover extends CommandBase {

    function master(){

    }

    function osbox(){
        echo "cmd: discover osbox\n";


        $ret = $this->_send("osbox discover all");

        $statuscode=200;
        $statusmsg="ok";

        $this->pusher->push($ret,$statuscode,$statusmsg);
        //$this->pusher->push(["OSBOX"]);
        //$this->test();
    }

    function osboxmaster(){
        return true;
    }



}


