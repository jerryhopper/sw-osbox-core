<?php

use Swoole\Coroutine\Server;
use Swoole\Coroutine\Server\Connection;

use Pachico\SlimSwoole\BridgeManager;



$certpath = "/etc/osbox/ssl/blackbox.surfwijzer.nl/ssl.cert";

$certinfo = openssl_x509_parse(file_get_contents($certpath));

$valid_from = date(DATE_RFC2822,$certinfo['validFrom_time_t']);
$valid_to = date(DATE_RFC2822,$certinfo['validTo_time_t']);

if( $certinfo['validFrom_time_t'] > time() || $certinfo['validTo_time_t'] < time() ){
    //print "Certificate is expired.";
    error_log("Certificate is expired.  ".$valid_to);
}else{
    //error_log("valid to ".$certinfo['validTo_time_t']);
    error_log("SSLCert Valid From: ".$valid_from);
    error_log("SSLCert Valid To:".$valid_to);

}

##################################################################################################################

/**
 * We instanciate the BridgeManager (this library)
 */
$bridgeManager = new BridgeManager($app);

/**
 * We start the Swoole server
 */
#$xhttp = new Swoole\HTTP\Server("0.0.0.0");
#$port1 = $server->listen("127.0.0.1", 9501, SWOOLE_SOCK_TCP);

$srv = new Swoole\HTTP\Server("0.0.0.0", 9501,SWOOLE_BASE, SWOOLE_SOCK_TCP);
//$srv = new Swoole\HTTP\Server("0.0.0.0", 9501, SWOOLE_PROCESS, SWOOLE_SOCK_TCP | SWOOLE_SSL);


// setup the location of ssl cert files and key files
$ssl_dir="/etc/osbox/ssl/blackbox.surfwijzer.nl";

$srv->set([
    'ssl_cert_file' => $ssl_dir . '/ssl.cert',
    'ssl_key_file' => $ssl_dir . '/ssl.key',
    'pid_file' => '/var/run/osbox.pid',
    'daemonize' => true,
    'worker_num'=> 2,
    //'user' => 'osbox',
    //'group' => 'osbox',
    'log_level' => 0,
    'log_file' => '/var/log/swoole.log',
    //'open_http2_protocol' => true, // Enable HTTP2 protocol
]);



/**
 * We register the on "start" event
 */
$srv->on("start", function (\swoole_http_server $server) {
    error_log( sprintf('osbox http server is started at https://%s:%s', $server->host, $server->port) );
    echo sprintf('osbox http server is started at https://%s:%s', $server->host, $server->port), PHP_EOL;
});

$srv->on("shutdown", function (\swoole_http_server $server) {
    error_log( sprintf('osbox http server is shutdown at https://%s:%s', $server->host, $server->port) );
    echo sprintf('osbox http server is shutdown at https://%s:%s', $server->host, $server->port), PHP_EOL;
    unlink('/var/run/osbox.pid');
});
/**
 * We register the on "request event, which will use the BridgeManager to transform request, process it
 * as a Slim request and merge back the response
 *
 */
$srv->on("request",
    function (swoole_http_request $swooleRequest, swoole_http_response $swooleResponse) use ($bridgeManager) {
        $bridgeManager->process($swooleRequest, $swooleResponse)->end();
    }
);
$srv->start();
