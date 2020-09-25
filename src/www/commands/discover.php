<?php




class discover extends commandBase {

    function osbox(){
        echo "cmd: osbox\n";

        $ret = $this->_send("osbox");

        $this->pusher->push([$ret]);
        $this->pusher->push(["OSBOX"]);
        //$this->test();
    }

    function osboxmaster(){
        return true;
    }



}


