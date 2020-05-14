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

require_once __DIR__.'/osbox-constants.php';

require_once __DIR__.'/Middleware/AuthorisationMiddleware.php';
require_once __DIR__."/Middleware/HostnameMiddleware.php";

require_once __DIR__.'/Classes/avahi.php';
require_once __DIR__.'/Classes/avahiServiceConfig.php';
require_once __DIR__.'/Classes/osboxFunctions.php';






error_reporting(1);
ini_set(display_errors,true);

// Does the /etc/osbox dir exist?

if(!file_exists("/etc/osbox/db/osbox.db")){

}

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


$container = $app->getContainer();

$container['myService'] = function ($container) {

    $process = new Swoole\Process(function($process){
        //execute the external program
        $process->exec("nmap", array('-v -sn 10.0.1.4/24 -oG -|grep Host'));
    }, true); // enable the redirection of stdin and stdout

    $process->start();

    return $process;




    //Inter-Process Communication Of main process and child process by stdin and stdout

    //$process->write("hello child process from main process");

    #$res = $process->read();

    #var_dump($res);


    #$myService = new MyService();
    #return $myService;
};




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

##################################################################################################################
##################################################################################################################

























/**
 * Define your routes
 */
$app->get('/', function ($request, $response, $args) {

    if( $request->getUri()->getHost() == "osbox.local" && false ){
        # request on osbox.local and configured is false

    }elseif( $request->getUri()->getHost() == "blackbox.surfwijzer.nl" ){
        # request on a configured device.


    }


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

    $request->getUri()->getScheme();

    $request->getUri()->getHost();
    $request->getUri()->getPort();


    //$request->getHeader();
	//Swoole\Timer->list();

    //$res = exec("ls /root/standalone/project -l",$output,$returnvar);

    //var_dump($res);

    /// die();

   return $response->withJson( "" );
});



$app->post('/setup/{nix}/sslcheck',function (Http\Request $request, Http\Response $response, array $args) {

    //osboxFunctions::setssl();


    return $response->withJson( array("status"=>"ok","data"=>"TODO" ) )->withHeader("Access-Control-Allow-Origin","*");
});


$app->post('/setup/{nix}/setssl',function (Http\Request $request, Http\Response $response, array $args) {

    return $response->withJson( array("status"=>"ok","data"=>osboxFunctions::setssl() ) )->withHeader("Access-Control-Allow-Origin","*");
});


$app->post('/setup/{nix}/reboot',function (Http\Request $request, Http\Response $response, array $args) {
    ;
    return $response->withJson( array("status"=>"ok","data"=>osboxFunctions::reboot() ) )->withHeader("Access-Control-Allow-Origin","*");
});


$app->get('/setup/{nix}/networkinfo',function (Http\Request $request, Http\Response $response, array $args) {

    return $response->withJson( array("status"=>"ok","data"=>osboxFunctions::networkinfo() ) )->withHeader("Access-Control-Allow-Origin","*");
});

$app->get('/setup/{nix}/networkscan',function (Http\Request $request, Http\Response $response, array $args) {

    $netinfo = osboxFunctions::networkinfo();
    $items = osboxFunctions::nmap($netinfo["NET"]);


    # $regels = explode("\n",$output);
    $list=array();
    $freelist = array();

    foreach($items as $tmp){
        $list[] = array($tmp[0],$tmp[1]);
        if($tmp[1]=="Down"){
            $freelist[] = $tmp[0];
        }

    }
    return $response->withJson( array("status"=>"ok","data"=>array("free"=>$freelist,"all"=>$list)  ));
});

$app->get('/setup/{nix}/status',function (Http\Request $request, Http\Response $response, array $args) {

    return $response->withJson( array("status"=>"ok","data"=> osboxFunctions::setupstatus() ) )->withHeader("Cache-Control","no-cache")->withHeader("Access-Control-Allow-Origin","*");
});








$app->get('/setup/module/{module}',function (Http\Request $request, Http\Response $response, array $args) {

     $output=osboxFunctions::setupmodule($args['module']);

     //    exec("sudo osbox setup module sw-osbox-core",$output,$returnvar);
    //  set network to static.

    //  set postboot action

    //  reboot


    sleep(1);
    return $response->withJson( $output )->withHeader("Access-Control-Allow-Origin","*");
});

$app->get('/setup/network2',function (Http\Request $request, Http\Response $response, array $args) {
    sleep(1);
    return $response->withJson( "" )->withHeader("Access-Control-Allow-Origin","*");
});










// finished functions.





/**
 * Master Discovery endpoint.
 * Returns the osboxmaster on the network.
 **/
$app->get('/discover/all',function (Http\Request $request, Http\Response $response, array $args) {
    $avahi = new avahi();
    #$r = $avahi->browse("_http-alt._tcp");
    $r = $avahi->browseAll();
    if(count($r)==0){
        return $response->withJson( array("status"=>"ok","data"=>$r) )->withHeader("Access-Control-Allow-Origin","*");
    }
    return $response->withJson( array("status"=>"ok","data"=>$r) )->withHeader("Access-Control-Allow-Origin","*");;
});

/**
 * Osbox Discovery endpoint.
 * Returns all osboxes on the network.
 **/
$app->get('/setup/discover',function (Http\Request $request, Http\Response $response, array $args) {
    $avahi = new avahi();
    #$r = $avahi->browse("_http-alt._tcp");
    $boxes = $avahi->browse("_osbox._tcp");
    $master = $avahi->browse("_osboxmaster._tcp");
    ;


    return $response->withJson( array("status"=>"ok","data"=>array("boxes"=>$boxes,"master"=>$master) ) )->withHeader("Access-Control-Allow-Origin","*");
});

##################################################################################################################
##################################################################################################################


















##################################################################################################################
##################################################################################################################

include("Swoole/SlimSwoole.php");

