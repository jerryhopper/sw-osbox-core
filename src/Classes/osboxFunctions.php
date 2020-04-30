<?php


class osboxFunctions {


    static function networkinfo(){
        exec("bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/networkinfo.sh",$output,$returnvar);

        $res = explode(",",$output[0]);
        //array( "IPV4"=>$res[0],"TYPE"=>$res[1],"NET"=>$res[2],"GATEWAY"=>$res[3] );
        //array( "IPV4"=>$res[0],"TYPE"=>$res[1],"NET"=>$res[2],"GATEWAY"=>$res[3] )

        return array( "IPV4"=>$res[0],"TYPE"=>$res[1],"NET"=>$res[2],"GATEWAY"=>$res[3] )

    }

    static function nmap($network){

        //  10.0.1.4/24
        exec("nmap -v -sn $network -oG -|grep Host",$output,$returnvar);

        # $regels = explode("\n",$output);
        $list=array();
        $freelist = array();

        foreach($output as $regel){
            $tmp = explode(" ",$regel);
            $list[] = array($tmp[1],$tmp[3]);

            if($tmp[3]=="Down"){
                $freelist[] = $tmp[1];
            }

        }
        return $list;
    }

}
