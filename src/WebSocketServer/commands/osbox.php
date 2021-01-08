<?php


##  https://www.swoole.co.uk/article/swoole-coroutine


class osbox extends CommandBase {

    function default($args=""){
        $pusher =$this->pusher; // Required!
        $command ="osbox"; // The issued command  or __FUNCTION__

        echo "osbox:default()\n";


        go(function() use ($command,$pusher) {
            /*
             * Here you can do tasks and push info to the websocket
             * There are 3 message variants.
             *
             *  $pusher->push( "RESULT","command", array() )
             *  $pusher->push( "INFO", "title", "text" )
             *  $pusher->push( "ERROR", "errormessage", "$e->getmessage()" )
             *
             */


            # Execute the command, and get the results.
            $ret = Co\System::exec("osbox network info");

            $ret['output'] = json_encode(explode(",",$ret['output']));


            # Push the final result to websocket
            $pusher->push( "PONG",$command, $ret );

        });

    }


    function status($args=""){
        $pusher =$this->pusher; // Required!
        $command ="osbox status"; // The issued command  or __FUNCTION__

        #echo "osbox:default()\n";


        go(function() use ($command,$pusher) {
            /**
             * Here you can do tasks and push info to the websocket
             * There are 3 message variants.
             *
             *  $pusher->push( "RESULT","command", array() )
             *  $pusher->push( "INFO", "title", "text" )
             *  $pusher->push( "ERROR", "errormessage", "$e->getmessage()" )
             *
             **/


            # Execute the command, and get the results.
            $ret = Co\System::exec($command);


            # Push the final result to websocket
            $pusher->push( "RESULT",$command, $ret );

        });

    }


    function update($args=""){
        $pusher =$this->pusher; // Required!
        $command ="osbox update"; // The issued command  or __FUNCTION__

        #echo "osbox:default()\n";


        go(function() use ($command,$pusher) {
            /**
             * Here you can do tasks and push info to the websocket
             * There are 3 message variants.
             *
             *  $pusher->push( "RESULT","command", array() )
             *  $pusher->push( "INFO", "title", "text" )
             *  $pusher->push( "ERROR", "errormessage", "$e->getmessage()" )
             *
             **/


            # Execute the command, and get the results.
            $ret = Co\System::exec($command);


            # Push the final result to websocket
            $pusher->push( "RESULT",$command, $ret );

        });
    }

    function authpoll($args=""){
        $pusher = $this->pusher; // Required!


        $command = "osbox auth poll"; // The issued command


        go(function () use ($command, $pusher) {
            /*
             * Here you can do tasks and push info to the websocket
             * There are 3 message variants.
             *
             *  $pusher->push( "RESULT","command", array() )
             *  $pusher->push( "INFO", "title", "text" )
             *  $pusher->push( "ERROR", "errormessage", "$e->getmessage()" )
             *
             */

            # Execute the command, and get the results.
            $ret = Co\System::exec($command);

            #$ret['code'];
            #$ret['signal'];
            #$ret['output'];
            #echo "output:";
            #var_dump($ret['output']);
            //$ret['output'] = explode("\n", $ret['output']);
            //var_dump($ret['output']);


            $updret = Co\System::exec("osbox setregistered");

            $devicestatus = json_decode($updret['output']);

            echo "---------------------------------------------";
            var_dump($devicestatus);
            //error_log(json_encode($ret['output']) );
            ## check if registered.

            ## if registered, notify server

            ## if server fails, do not register this device.


            ## if server success, go on






            $pusher->push("RESULT", $command, $ret);


        });
    }


    function auth($args=""){
        $pusher = $this->pusher; // Required!


        $command = "osbox auth request"; // The issued command


        go(function () use ($command, $pusher) {
            /*
             * Here you can do tasks and push info to the websocket
             * There are 3 message variants.
             *
             *  $pusher->push( "RESULT","command", array() )
             *  $pusher->push( "INFO", "title", "text" )
             *  $pusher->push( "ERROR", "errormessage", "$e->getmessage()" )
             *
             */

            # Execute the command, and get the results.
            $ret = Co\System::exec($command);

            $ret['code'];
            $ret['signal'];
            $ret['output'];
            //echo "output:";
           #var_dump($ret['output']);
            //$ret['output'] = explode("\n", $ret['output']);
            //var_dump($ret['output']);


            $pusher->push("RESULT", $command, $ret);


        });
    }

    function discover($args=""){
        $pusher =$this->pusher; // Required!
        $command ="osbox discover all"; // The issued command  or __FUNCTION__

        echo "args=";
        print_r($args);

        go(function() use ($command,$pusher) {
            /*
             * Here you can do tasks and push info to the websocket
             * There are 3 message variants.
             *
             *  $pusher->push( "RESULT","command", array() )
             *  $pusher->push( "INFO", "title", "text" )
             *  $pusher->push( "ERROR", "errormessage", "$e->getmessage()" )
             *
             */

            # Execute the command, and get the results.
            $ret = Co\System::exec($command);

            $ret['code'];
            $ret['signal'];
            $ret['output'];
            echo "output:";
            var_dump($ret['output']);
            $ret['output']=explode("\n",$ret['output']);
            foreach($ret['output'] as $box){
                if(trim($box)!="") {
                    $boxdetails = explode(";", $box);



                    echo "> ".$boxdetails[7];

                    #$client = new WebSocketClient(, $boxdetails[8]);
                    $client = new WebSocketClient($boxdetails[7], $boxdetails[8]);

                    $data = $client->connect();
                    $client->send("osbox status");
                    $tmp = $client->recv();
                    $r = json_decode($tmp);
                    $status = (array)$r[4];



                    $items[] = array("if" => $boxdetails[1], "net" => $boxdetails[2], "host" => $boxdetails[6], "ip" => $boxdetails[7],"port" =>$boxdetails[8],"status"=>$status);

                }
            }

            $ret['output']=json_encode($items);
            //var_dump($ret['output']);

           //$this->MyTest();

            # Push the final result to websocket
            $pusher->push( "RESULT",$command, $ret );

        });

    }



    function MyTest($host,$port){
        echo "--------------------------------";
        $host = '127.0.0.1';
        $port = 81;

        $client = new WebSocketClient($host, $port);
        $data = $client->connect();
        #var_dump( $data);
        #$data = "data";
        #if (!empty($size)) {
        #    $data = str_repeat("A", $size * 1024);
        #}

        $client->send("osbox status");
        $recvData = "";
        #while(1) {
        $tmp = $client->recv();
        #   if (empty($tmp)) {
        #       break;
        #   }
        $recvData .= $tmp;
        #}
        echo $recvData . "size:" . strlen($recvData) . PHP_EOL;
        //$client->disconnect();
        echo "--------------------------------";
        return $recvData;

    }



    function restart($args=""){
        $pusher =$this->pusher; // Required!
        $command ="osbox restart"; // The issued command  or __FUNCTION__



        go(function() use ($command,$pusher) {
            /*
             * Here you can do tasks and push info to the websocket
             * There are 3 message variants.
             *
             *  $pusher->push( "RESULT","command", array() )
             *  $pusher->push( "INFO", "title", "text" )
             *  $pusher->push( "ERROR", "errormessage", "$e->getmessage()" )
             *
             */


            # Execute the command, and get the results.
            $ret = Co\System::exec($command);


            # Push the final result to websocket
            $pusher->push( "RESULT",$command, $ret );

        });

    }

    function reboot($args=""){
        $pusher =$this->pusher; // Required!
        $command ="shutdown -r now"; // The issued command  or __FUNCTION__



        go(function() use ($command,$pusher) {
            /*
             * Here you can do tasks and push info to the websocket
             * There are 3 message variants.
             *
             *  $pusher->push( "RESULT","command", array() )
             *  $pusher->push( "INFO", "title", "text" )
             *  $pusher->push( "ERROR", "errormessage", "$e->getmessage()" )
             *
             */


            # Execute the command, and get the results.
            $ret = Co\System::exec($command);


            # Push the final result to websocket
            $pusher->push( "RESULT",$command, $ret );

        });

    }

    function installmodule($args=""){
        $pusher =$this->pusher; // Required!
        $command ="ls -latr /usr/local/osbox"; // The issued command  or __FUNCTION__

        go(function() use ($command,$pusher) {
            /*
             * Here you can do tasks and push info to the websocket
             * There are 3 message variants.
             *
             *  $pusher->push( "RESULT","command", array() )
             *  $pusher->push( "INFO", "title", "text" )
             *  $pusher->push( "ERROR", "errormessage", "$e->getmessage()" )
             *
             */


            # Execute the command, and get the results.
            $ret = Co\System::exec($command);

            # Push the final result to websocket
            $pusher->push( "RESULT",$command, $ret );

        });
    }
}
