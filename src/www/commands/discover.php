<?php




class discover extends commandBase {

    function osbox(){
        echo "cmd: osbox\n";
        $this->pusher->push(["OSBOX"]);
        $this->pusher->push(["OSBOX"]);
        //$this->test();
    }

    function osboxmaster(){
        return true;
    }



}


