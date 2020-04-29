<?php


class avahi {

    public function browseAll(){
        $res = exec("avahi-browse -artpk |grep \"=;eth0;IPv4\"", $output,$return_var);
        return $this->parseResult($output);
    }

    public function browse ( $service )
    {
        $res = exec("avahi-browse -rtpk $service|grep \"=;eth0;IPv4\"", $output, $return_var);
        return $this->parseResult($output);
    }


    public function parseResult($output){
        $list = array();
        foreach($output as $item){
            $parts = explode(";",$item);

            $mdns = array();
            #$mdns['huh'] =$parts[0]; // =
            #$mdns['interface'] = $parts[1]; // interface
            #$mdns['proto'] = $parts[2]; // proto
            $mdns['name'] = $this->text_clean($parts[3]); // name
            $mdns['service'] = $parts[4]; //
            $mdns['domain'] = $parts[5]; // domain
            $mdns['hostname'] = $parts[6]; // hostname
            $mdns['ip'] = $parts[7]; // ip
            $mdns['port'] = $parts[8]; // port
            $mdns['data'] = $this->avahi_text_decode($parts[9]); // textstuff.

            $list[] = $mdns;

        }
        return $list;
    }

    private function text_clean($input_line)
    {
        preg_match_all("/\\\\([0-0][0-9][0-9])/", $input_line, $output_array);
        $replace = array();
        foreach ($output_array[1] as $o) {
            $replace[] = mb_convert_encoding('&#' . intval($o) . ';', 'UTF-8', 'HTML-ENTITIES');
        }
        return str_replace($output_array[0], $replace, $input_line);
    }


    private function avahi_text_decode($text){
        preg_match_all('/"([^"]*)"/', $text, $matches);
        $final=array();
        foreach(array_reverse($matches[1]) as $m){
            $var = explode("=",$m);
            $final[$var[0]]=$var[1];
        }
        return $final;
    }
}

