<?php
//  https://github.com/Yurunsoft/Guzzle-Swoole

use Swoole\Coroutine\Server;
use Swoole\Coroutine\Server\Connection;

use Pachico\SlimSwoole\BridgeManager;
use Slim\Http;

use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;



use GuzzleHttp\Client;
use GuzzleHttp\HandlerStack;
use Yurun\Util\Swoole\Guzzle\SwooleHandler;

require __DIR__ . '/../vendor/autoload.php';

require_once __DIR__.'/Middleware/AuthorisationMiddleware.php';



/*
$_loaderdirs=["Middleware"];

spl_autoload_register(function ($class_name) {
    $_loaderdirs=["Middleware"];
    foreach($_loaderdirs as $dir){
        if(file_exists("./Middleware/".$class_name . '.php')){
            require_once("./$dir/".$class_name . '.php');
        }else{
            error_log("./Middleware/".$class_name . '.php');
        }
    }
});
*/


/**
 * Checks whether the process is running.
 *
 * @param int $pid Process PID.
 * @return bool
 */
function isProcessRunning($pid) {
// Calling with 0 kill signal will return true if process is running.
    exec("kill -9 $pid");
    return posix_kill((int) $pid, SIGHUP );
}

/**
 * Get the command of the process.
 * For example apache2 in case that's the Apache process.
 *
 * @param int $pid Process PID.
 * @return string
 */
function getProcessCommand($pid) {
    $pid = (int) $pid;
    return trim(shell_exec("ps o comm= $pid"));
}


$pidfilename='/var/run/osbox.pid';
if( file_exists($pidfilename) ){
    $handle = fopen($pidfilename, "r");
    $contents = fread($handle, filesize($pidfilename));
    fclose($handle);
    echo ">>>". $contents;
    isProcessRunning($contents);
}else{
    echo "no pid";
}



/*
->add(function (Request $request, Response $response, callable $next) {

    $response->getBody()->write('BEFORE' . PHP_EOL);
    $response = $next($request, $response);
    $response->getBody()->write(PHP_EOL . 'AFTER');

    return $response;
});
*/














//isProcessRunning($contents);

$slimSettings = array('determineRouteBeforeAppMiddleware' => true);

#if (ENVIRONMENT === 'dev')
#{
    $slimSettings['displayErrorDetails'] = true;
#}

$slimConfig = array('settings' => $slimSettings);

/**
 * This is how you would normally bootstrap your Slim application
 * For the sake of demonstration, we also add a simple middleware
 * to check that the entire app stack is being setup and executed
 * properly.
 */
$app = new \Slim\App($slimConfig );


#$app->add(function ($request, $response, $next) {
#    $response->getBody()->write('BEFORE');
#    $response = $next($request, $response);
#    $response->getBody()->write('AFTER');
#    return $response;
#});


/*


use Lcobucci\JWT\Parser;
use Lcobucci\JWT\ValidationData;

# parse
$token = (new Parser())->parse((string) $token); // Parses from a string
$token->getHeaders(); // Retrieves the token header
$token->getClaims(); // Retrieves the token claims

echo $token->getHeader('jti'); // will print "4f1g23a12aa"
echo $token->getClaim('iss'); // will print "http://example.com"
echo $token->getClaim('uid'); // will print "1"


#verify
$data = new ValidationData(); // It will use the current time to validate (iat, nbf and exp)
$data->setIssuer('http://example.com');
$data->setAudience('http://example.org');
$data->setId('4f1g23a12aa');

var_dump($token->validate($data)); // false, because token cannot be used before now() + 60

$data->setCurrentTime($time + 61); // changing the validation time to future

var_dump($token->validate($data)); // true, because current time is between "nbf" and "exp" claims

$data->setCurrentTime($time + 4000); // changing the validation time to future

var_dump($token->validate($data)); // false, because token is expired since current time is greater than exp

// We can also use the $leeway parameter to deal with clock skew (see notes below)
// If token's claimed time is invalid but the difference between that and the validation time is less than $leeway,
// then token is still considered valid
$dataWithLeeway = new ValidationData($time, 20);
$dataWithLeeway->setIssuer('http://example.com');
$dataWithLeeway->setAudience('http://example.org');
$dataWithLeeway->setId('4f1g23a12aa');

var_dump($token->validate($dataWithLeeway)); // false, because token can't be used before now() + 60, not within leeway

$dataWithLeeway->setCurrentTime($time + 51); // changing the validation time to future

var_dump($token->validate($dataWithLeeway)); // true, because current time plus leeway is between "nbf" and "exp" claims

$dataWithLeeway->setCurrentTime($time + 3610); // changing the validation time to future but within leeway

var_dump($token->validate($dataWithLeeway)); // true, because current time - 20 seconds leeway is less than exp

$dataWithLeeway->setCurrentTime($time + 4000); // changing the validation time to future outside of leeway

var_dump($token->validate($dataWithLeeway)); // false, because token is expired since current time is greater than exp


*/


##################################################################################################################
##################################################################################################################





























/**
 * Define your routes
 */
/**
 * Define your routes
 */
$app->get('/', function ($request, $response, $args) {


});


$app->get('/urlresolve', function ($request, $response, $args) {

    $allGetVars = $request->getQueryParams();
    $getParam = $allGetVars['url'];
    //'https://t.co/JEI6qlzh4r'   https%3A%2F%2Ft.co%2FJEI6qlzh4r

    $responseData = array(
        "requestedUrl"=>$getParam ,
        "resolvedUrl"=>false,
        "statusCode"=>500
    );


    $client = new Client([
        'allow_redirects'=>true
    ]);

    try{
        $client->get( $getParam ,[
            'verify' => false ,
            'on_stats'=>function (GuzzleHttp\TransferStats $stats) use(&$redir){
                $redir = (string) $stats->getEffectiveUri();
            }
        ]);
        $responseData['resolvedUrl']=$redir;
        $responseData['statusCode']=200;
    }catch( GuzzleHttp\Exception\ClientException $e){
        $responseData['statusCode']= $e->getCode();

    }

    /*
    $gresponse = $client->request('GET', 'https://t.co/JEI6qlzh4r?amp=1', [
        'verify' => false ,
        'on_stats'=>function (GuzzleHttp\TransferStats $stats){
            $redir = (string) $stats->getEffectiveUri();
            error_log($redir);
        }
    ]);*/

    //var_dump($response->getStatusCode());
    //error_log("Guzzledone!");
    //error_log($redir);

    //$redir = urlencode("https://t.co/JEI6qlzh4r");

    //$response->getBody()->write($redir);

    return $response->withJSON($responseData);
});

//->add( new AuthorisationMiddleware(["","admin"]) );






$app->get('/foo[/{myArg}]', function ( $request,  $response, array $args) {
    $data = [
        'args' => $args,
        'body' => (string) $request->getBody(),
        'parsedBody' => $request->getParsedBody(),
        'params' => $request->getParams(),
        'headers' => $request->getHeaders(),
        'uploadedFiles' => $request->getUploadedFiles()
    ];

    return $response->withJson($data);
});




$app->get('/boo',function (Http\Request $request, Http\Response $response, array $args) {

	//Swoole\Timer->list();

    $res = exec("ls /root/standalone/project -l",$output,$returnvar);

    var_dump($res);

    /// die();

   return $response->withJson($res);
});


##################################################################################################################
##################################################################################################################


















##################################################################################################################
##################################################################################################################

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
    'daemonize' => false,
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
    //unlink('/var/run/osbox.pid');
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
