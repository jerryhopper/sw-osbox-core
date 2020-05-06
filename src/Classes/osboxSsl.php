<?php




class osboxSsl
{

    protected $SSLdomain      = "blackbox.surfwijzer.nl";
    protected $SSLrequestUrl  = "https://setup.surfwijzer.nl/api/ssl/";
    protected $SSLsaveLocation= "/etc/osbox/ssl/";


    function jsonSSLurl (){
        return $this->SSLrequestUrl.$this->SSLdomain;
    }




    function requestCertificate (){

        /**
         *
         * https://setup.surfwijzer.nl/api/ssl/{blackbox.surfwijzer.nl}
         *
         * Request certifcate, response is json:
         * "ssl.ca,ssl.cert,ssl.combined,ssl.key"
         *
         **/
        if ($stream = fopen($this->jsonSSLurl(), 'r')) {
            // print all the page starting at the offset 10
            $data= json_decode(stream_get_contents($stream,-1),true);
            fclose($stream);
        }

        try{
            mkdir($this->SSLsaveLocation.$this->SSLdomain);
        }catch(Exception $e){

        }

        foreach( $data as $key=>$value ){
            $this->writedata($this->SSLsaveLocation.$this->SSLdomain."/".$key,$value);
        }
    }


    /**
     * @param $filename
     * @param $data
     **/
    private function writedata($filename,$data){

        try{
            if (!$handle = fopen($filename, 'w+')) {
                echo "Cannot open file ($filename)";
                exit;
            }
            if (fwrite($handle, $data) === FALSE) {
                echo "Cannot write to file ($filename)";
                exit;
            }
        }catch(Exception $e){
            throw new \Exception("Write errror");
        }

    }

}

