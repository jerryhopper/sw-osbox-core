<?php


class Pusher
{
    private $socketserver;
    private $frame;

    function __construct( Server $server,Frame $frame)
    {
        $this->socketserver = $server;
        $this->frame = $frame;
    }

    public function push( $data , $statuscode=200,$statusmsg="ok"){
        echo "Pushed message!\n";
        $this->socketserver->push($this->frame->fd, $this->outputFormat( $data ,$statuscode,$statusmsg) );
    }

    private function outputFormat($data, $statuscode,$statusmsg){
        return json_encode( [$statuscode, time(), $data ] );
    }

}

