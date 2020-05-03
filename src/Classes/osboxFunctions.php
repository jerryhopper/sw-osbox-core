<?php


class osboxFunctions {




    static function setupmodule($module){
        exec("sudo osbox setup module sw-osbox-core",$output,$returnvar);
        return $output;
    }

    static function reboot(){
        exec("sudo osbox reboot",$output,$returnvar);

    }
    static function setupstatus(){
        exec("osbox setup status",$output,$returnvar);

        $res = explode(",",$output[0]);

        return array($res[0],$res[1],$res[2]);
    }

    static function networkinfo(){
        exec("osbox network info",$output,$returnvar);

        $res = explode(",",$output[0]);
        //array( "IPV4"=>$res[0],"TYPE"=>$res[1],"NET"=>$res[2],"GATEWAY"=>$res[3] );
        //array( "IPV4"=>$res[0],"TYPE"=>$res[1],"NET"=>$res[2],"GATEWAY"=>$res[3] )

        return array( "IPV4"=>$res[0],"TYPE"=>$res[1],"NET"=>$res[2],"GATEWAY"=>$res[3] );

    }

    /**
     * @param $network  String 10.0.1.4/24
     * @return array
     */
    static function nmap($network){

        //  10.0.1.4/24
        exec("osbox network scan",$output,$returnvar);

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
