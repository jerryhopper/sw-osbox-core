<?php

class status extends commandBase {

    function default(){
        $ret = array();
        $statuscode=200;
        $statusmsg="ok";

        $this->pusher->push($ret,$statuscode,$statusmsg);
    }



}