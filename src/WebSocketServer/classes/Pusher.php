<?php


use Swoole\WebSocket\Server;
use Swoole\Http\Request;
use Swoole\WebSocket\Frame;

class Pusher
{
    private $socketserver;
    private $frame;

    function __construct( Server $server,Frame $frame)
    {
        $this->socketserver = $server;
        $this->frame = $frame;
    }

    # $pusher->push( "RESULT","command", array() )
    # $pusher->push( "INFO", "title", "text" )
    # $pusher->push( "ERROR", "errormessage", "$e->getmessage()" )

    public function push( $type , $text, $data){
        echo "type=".$type."\n";
        echo "text=".$text."\n";
        echo "data=\n";
        print_r($data);

    #public function push( $data , $statuscode=200,$statusmsg="ok"){
        if( $type=="INFO"){
            # $pusher->push( "INFO", "title", "text" )
            # $this->socketserver->push($this->frame->fd, $this->outputFormat( $data ,$statuscode,$statusmsg) );
            $statuscode=200;
            $statusmsg=$text;



        }else if( $type=="PONG"){
            # $pusher->push( "RESULT","command", array() )
            # array() contains : {"code":0,"signal":0,"output":"someoutput" }
            $data['code'];
            $data['signal'];
            $data['output'];

            if($data['code']==0){
                $statuscode=200;
                $statusmsg=$text;
            }else{
                $statuscode=500+$data['code'];
                $statusmsg="An error occured.";
            }
            $data = json_decode($data['output']);
            # $this->socketserver->push($this->frame->fd, $this->outputFormat( $data ,$statuscode,$statusmsg) );

        }else if( $type=="RESULT"){
            # $pusher->push( "RESULT","command", array() )
            # array() contains : {"code":0,"signal":0,"output":"someoutput" }
            $data['code'];
            $data['signal'];
            $data['output'];

            if($data['code']==0){
                $statuscode=200;
                $statusmsg=$text;
            }else{
                $statuscode=500+$data['code'];
                $statusmsg="An error occured.";
            }
            $data = json_decode($data['output']);
            # $this->socketserver->push($this->frame->fd, $this->outputFormat( $data ,$statuscode,$statusmsg) );

        }else if ($type=="ERROR"){
            # $pusher->push( "ERROR", "errormessage", "$e->getmessage()" )
            $statuscode=500;
            $statusmsg=$text;
        }else{
            #error
            $statuscode=500;
            $statusmsg=$text;
        }

        //
        echo "Push message!\n";

        $this->socketserver->push($this->frame->fd, $this->outputFormat( $type,$statuscode,$statusmsg,$data) );
        #$this->socketserver->push($this->frame->fd, $this->outputFormat( $type,$data ,$type,$statusmsg) );
    }

    private function outputFormat($type,$statuscode,$statusmessage,$data){
        return json_encode( [$type, time(), $statuscode,$statusmessage, $data ] );
    }

}

