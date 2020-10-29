<?php


class CommandBase
{
    public $method;
    public $subcommands;
    public $pusher;

    function __construct( Array $subcommands,pusher $pusher)
    {
        $this->pusher=$pusher;

        $this->method=$subcommands[0];
        $this->subcommands = $subcommands;

        echo "\\commandBase::construct class! (".$this->method.")\n";

    }

    public function _result(){
        $cmd = $this->method;
        $this->$cmd();
    }

    public function _send($data,$sleep=1)
    {
        error_log("_send( $data )\n");
        // $data
        //error_log("send to /host/osbox/pipe");
        echo  "send '$data' to /host/osbox/pipe\n";
        $fp = fopen('/host/osbox/pipe', 'w');
        fwrite($fp, $data);
        fclose($fp);

        error_log(  "sleep $sleep \n");
        sleep($sleep);

        $filename="/host/osbox/response";
        if (!file_exists($filename)){
            error_log(  "/host/osbox/response DOESN NOT EXIST!");
        }

        $handle = fopen($filename, "rb");
        $contents = '';
        while (!feof($handle)) {
            $contents .= fread($handle, 8192);
        }
        echo "contents = ".strlen($contents)." characters  ( ".$contents.")\n";

        if( strpos($contents,"\n" ) ){
            echo "has newline \n";
            $contents = explode("\n",$contents);

            $contents = array_filter($contents, function($v){
                return trim($v);
            });

            //var_dump($result);
//array_slice()

            //var_dump($res);

        }

        fclose($handle);

        if ($data !=$contents[0]){
            # error?!
            echo "COMMAND ERROR!? \n";
        }
        $results = array_splice($contents,1);

        #$handle = fopen($filename, "r");
        #$contents = fread($handle, filesize($filename));
        #fclose($handle);
        return $results;
    }
}
