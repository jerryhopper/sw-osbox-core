<?php


##  https://www.swoole.co.uk/article/swoole-coroutine


class osbox extends CommandBase {


    function default(){
        $pusher =$this->pusher; // Required!
        $command ="osbox"; // The issued command

        echo "osbox:default()";


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
