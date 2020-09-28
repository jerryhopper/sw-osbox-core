<?php




class discover extends commandBase {

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


