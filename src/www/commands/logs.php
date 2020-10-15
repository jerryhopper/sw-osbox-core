<?php




class logs extends commandBase {


    function default(){
        echo "cmd: osbox logs\n";


        $ret = $this->_send("osbox logs",5);

        $statuscode=200;
        $statusmsg="ok";

        $this->pusher->push($ret,$statuscode,$statusmsg);
        //$this->pusher->push(["OSBOX"]);
        //$this->test();
    }




}


