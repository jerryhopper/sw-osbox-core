<?php


class avahiServiceConfig{

    var $_service="_osbox._tcp";
    var $_servicename="OsBox device on %h";
    var $_port=9501;

    function __construct($port=9501,$ssl=false)
    {

    }


    function createOsboxMaster(){

        // osboxConstants::WEB_PORT
        $this->service($this->_servicename,osboxConstants::AVAHI_SERVICE_OSBOXMASTER,osboxConstants::WEB_PORT,$txtRecords=array("SSL=true") );
    }

    function createOsbox(){
        $this->service($this->_servicename,osboxConstants::AVAHI_SERVICE_OSBOX,osboxConstants::WEB_PORT,$txtRecords=array("SSL=false") );
    }

    private function service($servicename,$service,$port=false,$txtRecords=array() )
    {
        $svc = '<?xml version="1.0" standalone=\'no\'?><!--*-nxml-*-->'.PHP_EOL;
        $svc .='<!DOCTYPE service-group SYSTEM "avahi-service.dtd">'.PHP_EOL;
        $svc .='<service-group>'.PHP_EOL;
        $svc .='    <name replace-wildcards="yes">'.$servicename.'</name>'.PHP_EOL;
        $svc .='    <service protocol="ipv4">'.PHP_EOL;
        $svc .='        <type>'.$service.'</type>'.PHP_EOL;
        $svc .='        <domain-name>local</domain-name>'.PHP_EOL;

        if($port!==false){
            $svc .='        <port>'.$port.'</port>'.PHP_EOL;
        }

        foreach($txtRecords as $txtRecord){
            $svc .='        <txt-record>'.$txtRecord.'</txt-record>'.PHP_EOL;
        }

        $svc .='    </service>'.PHP_EOL;
        $svc .='</service-group>'.PHP_EOL;
        return $svc;
    }



}
