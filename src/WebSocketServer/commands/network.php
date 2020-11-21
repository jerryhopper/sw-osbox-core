<?php


class network extends CommandBase {

    function set(){
        $this->pusher->push(["OSBOX"]);
        $this->pusher->push(["OSBOX"]);

    }

}
