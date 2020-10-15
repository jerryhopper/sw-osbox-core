<?php

class osbox extends commandBase {

    function default(){
        echo "osbox:default()";
        //$this->pusher->push(["INFO",array("title"=>"osbox:default()","text"=>"osbox:default()")],$statuscode,$statusmsg);

        $ret = $this->_send("osbox",0);
        echo "after send!";
       //$ret = array("lalalala");
        $statuscode=200;
        $statusmsg="ok";

        $this->pusher->push($ret,$statuscode,$statusmsg);
    }



}
