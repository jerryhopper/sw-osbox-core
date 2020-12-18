<?php


class auth extends CommandBase
{


    function default($data = "")
    {
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
            echo "output:";
            var_dump($ret['output']);
            $ret['output'] = explode("\n", $ret['output']);
            var_dump($ret['output']);


            $pusher->push("RESULT", $command, $ret);


        });
    }


}
