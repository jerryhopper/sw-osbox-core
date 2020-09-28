<?php

class websetup extends commandBase {



    function start(){
        echo ">>> osbox websetup start\n";

        #  check for boxes
        #  check for master -> redir to admin
        #  check network
        #    router/gateway info
        #    ip info
        #    set network/staticip
        #    routerconfig
        #    done -> redir to admin
        #
        #
        $statuscode=100;
        $statusmsg="ok";

        //["INFO",{"title":"Scanning the network","text":"Scanning the network."}]
        //array("title"=>"Scanning the network","text"=>"Scanning the network.");

        $this->pusher->push(["INFO",array("title"=>"Scanning the network","text"=>"Scanning the network.")],$statuscode,$statusmsg);

        #sleep(1);
        #$this->pusher->push("Scanning the network",$statuscode,$statusmsg);
        #sleep(1);
        #$this->pusher->push("Scanning the network",$statuscode,$statusmsg);


        $command = "osbox discover master";
        $results = $this->_send($command);
        //$results = array();
        #if($ret[0]!=$command){
        #    echo "COMMAND ERROR!? \n";
        #}
        #$results = array_splice($ret,1);


        if( count($results)>0){
            # there is a master!
            $redir = "http://setup.surfwijzer.nl/support";
            $this->pusher->push(["REDIR",array("title"=>"Osbox found!","text"=>"A configured osbox was found!","redir"=>$redir)],$statuscode,$statusmsg);


        }else{
            # xxx
            $this->pusher->push(["INFO",array("title"=>"Scanning the network","text"=>"No configured hardware found")],$statuscode,$statusmsg);

        }

        //return;


        $command = "osbox discover all";
        $ret = $this->_send($command);

        if(count($ret)==0){
            $redir = "http://setup.surfwijzer.nl/support";
            $this->pusher->push(["REDIR",array("title"=>"A error occured","text"=>"A unexpected error occured.","redir"=>$redir)],$statuscode,$statusmsg);

        }elseif( count($ret)==1 ){
            $this->pusher->push(["INFO",array("title"=>"Scanning finished","text"=>"Multiple devices found.")],$statuscode,$statusmsg);
        }
        elseif( count($ret)>1 ){
            $this->pusher->push(["INFO",array("title"=>"Scanning finished","text"=>"Multiple devices found.")],$statuscode,$statusmsg);
        }

        $this->pusher->push(["CALL",array("function"=>"vraag1","vars"=>[])],$statuscode,$statusmsg);


        // get all osboxes
        //$ret = $this->_send("osbox discover all");
        // result is an array
        #print_r($results);

        #echo $results;


        $statuscode=200;
        $statusmsg="ok";

        #$this->pusher->push($ret,$statuscode,$statusmsg);
        //$this->pusher->push(["OSBOX"]);
        //$this->test();



    }
}
