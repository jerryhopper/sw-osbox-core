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
require_once __DIR__.'/PHPmDns/mdns.php';


error_reporting(1);
ini_set(display_errors,true);



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










function scan() {
    // Performs an mdns scan of the network to find chromecasts and returns an array
    // Let's test by finding Google Chromecasts
    $mdns = new mDNS();
    // Search for chromecast devices
    // For a bit more surety, send multiple search requests
    $mdns->query("_googlecast._tcp.local",1,12,"");
    $mdns->query("_googlecast._tcp.local",1,12,"");
    $mdns->query("_googlecast._tcp.local",1,12,"");
    $cc = 15;
    $chromecasts = array();
    while ($cc>0) {
        $inpacket = $mdns->readIncoming();
        //$mdns->printPacket($inpacket);
        // If our packet has answers, then read them
        if ($inpacket->packetheader->getAnsweRRrs()> 0) {
            for ($x=0; $x < sizeof($inpacket->answerrrs); $x++) {
                if ($inpacket->answerrrs[$x]->qtype == 12) {
                    //print_r($inpacket->answerrrs[$x]);
                    if ($inpacket->answerrrs[$x]->name == "_googlecast._tcp.local") {
                        $name = "";
                        for ($y = 0; $y < sizeof($inpacket->answerrrs[$x]->data); $y++) {
                            $name .= chr($inpacket->answerrrs[$x]->data[$y]);
                        }
                        // The chromecast name is in $name. Send a a SRV query
                        $mdns->query($name, 1, 33, "");
                        $cc=15;
                    }
                }
                if ($inpacket->answerrrs[$x]->qtype == 33) {
                    $d = $inpacket->answerrrs[$x]->data;
                    $port = ($d[4] * 256) + $d[5];
                    // We need the target from the data
                    $offset = 6;
                    $size = $d[$offset];
                    $offset++;
                    $target = "";
                    for ($z=0; $z < $size; $z++) {
                        $target .= chr($d[$offset + $z]);
                    }
                    $target .= ".local";
                    $chromecasts[$inpacket->answerrrs[$x]->name] = array("port"=>$port, "ip"=>"", "target"=>$target);
                    // We know the name and port. Send an A query for the IP address
                    $mdns->query($target,1,1,"");
                    $cc=15;
                }
                if ($inpacket->answerrrs[$x]->qtype == 1) {
                    $d = $inpacket->answerrrs[$x]->data;
                    $ip = $d[0] . "." . $d[1] . "." . $d[2] . "." . $d[3];
                    // Loop through the chromecasts and fill in the ip
                    foreach ($chromecasts as $key=>$value) {
                        if ($value['target'] == $inpacket->answerrrs[$x]->name) {
                            $value['ip'] = $ip;
                            $chromecasts[$key] = $value;
                        }
                    }
                }
            }
        }
        $cc--;
    }

    return $chromecasts;
}


















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

    //$res = exec("ls /root/standalone/project -l",$output,$returnvar);

    //var_dump($res);

    /// die();

   return $response->withJson( scan() );
});


##################################################################################################################
##################################################################################################################


















##################################################################################################################
##################################################################################################################

include("Swoole/SlimSwoole.php");

