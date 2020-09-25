<?php




class discover extends commandBase {

    function osbox(){
        $this->pusher->push(["OSBOX"]);
        $this->pusher->push(["OSBOX"]);
    }

    function osboxmaster(){
        return true;
    }
}


