<?php


class network extends commandBase {

    function set(){
        $this->pusher->push(["OSBOX"]);
        $this->pusher->push(["OSBOX"]);

    }

}
