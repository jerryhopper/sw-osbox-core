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
            $ret = Co\System::exec($command);


            # Push the final result to websocket
            $pusher->push( "RESULT",$command, $ret );

        });

    }


    function status($args=""){
        $pusher =$this->pusher; // Required!
        $command ="osbox status"; // The issued command  or __FUNCTION__

        #echo "osbox:default()\n";


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

    function Xpoep($args=""){
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
