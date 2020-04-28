<?php

use Lcobucci\JWT\Parser;
use Lcobucci\JWT\ValidationData;

use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;


class AuthorisationMiddleware
{
    /**
     * the headerkey to extract the token from.
     **/
    private $header = 'Authorization';

    /**
     * the allowed scopes.
     **/
    private $allowedsopes = array();

    /**
     * is anon access allowed
     **/
    private $allowanonymous=false;


    /**
     * constructor
     **/
    function __construct($array)
    {
        $this->allowedsopes=$array;
        if( in_array('', $array) ){
            $this->allowanonymous=true;
        }
    }

    /**
     * Example middleware invokable class
     *
     * @param  \Psr\Http\Message\ServerRequestInterface $request  PSR7 request
     * @param  \Psr\Http\Message\ResponseInterface      $response PSR7 response
     * @param  callable                                 $next     Next middleware
     *
     * @return \Psr\Http\Message\ResponseInterface
     */
    public function __invoke($request, $response, $next)
    {
        // content-type
        $contentType = $this->detectContentType($request); // json/html

        // deny access, if there is no auth header, and anonymous access is not allowed.
        if( !$request->hasHeader($this->header) && !$this->allowanonymous ){
            if($contentType=="json"){
                return $response->withJson("access denied")->withStatus(403);
            }else{
                return $response->write("<h1>Access denied</h1>")->withStatus(403);
            }
        }

        // decode token
        $token_is_valid =true;
        try{
            $this->decodeToken($request->hasHeader($this->header)[0]);
        }catch(Exception $e){
            // malformed token?
            $token_is_valid =false;
        }


        // checks
        if(
            ( !$this->allowanonymous  && $token_is_valid && $this->token_is_allowed() ) ^
            ( $this->allowanonymous && !$token_is_valid )
        ){
            // Allow, if anon is not allowed, and token is valid & allowed
            $response = $next($request, $response);

        }else{
            // no access!
            if($contentType=="json"){
                return $response->withJson("access denied")->withStatus(403);
            }else{
                return $response->write("<h1>Access denied</h1>")->withStatus(403);
            }
        }
        //
        ;

        //$token = $request->getHeader($this->header)[0];


        //$response->getBody()->write('BEFORE');
        //$response = $next($request, $response);
        //$response->getBody()->write( (string)$this->allowanonymous );

        return $response;
    }


    private function decodeToken($token){
        $parsedToken = $this->parseToken($token);
        $this->verifyToken($parsedToken);

    }

    private function detectContentType($request){
        // content-type
        if( $request->hasHeader( "Content-Type") ){
            if ( $request->getHeader("Content-Type")[0]=="application/json") {
                $contentType = "json";
            }else{
                $contentType = "html";
            }
        }else{
            $contentType = "html";
        }
        return $contentType;
    }


    private function token_is_allowed($token){

        $parsedToken = $this->parseToken($token);

        try{
            $this->verifyToken($parsedToken);
        }catch(Exception $e){

        }

        return true;
    }


    private function parseToken($tokenString){
        # parse
        $parsedToken = (new Parser())->parse((string) $tokenString); // Parses from a string
        #$parsedToken->getHeaders(); // Retrieves the token header
        #$parsedToken->getClaims(); // Retrieves the token claims

        #echo $parsedToken->getHeader('jti'); // will print "4f1g23a12aa"
        #echo $parsedToken->getClaim('iss'); // will print "http://example.com"
        #echo $parsedToken->getClaim('uid'); // will print "1"

        return $parsedToken;
    }

    private function verifyToken($parsedToken){
        #verify
        $data = new ValidationData(); // It will use the current time to validate (iat, nbf and exp)
        $data->setIssuer('http://example.com');
        $data->setAudience('http://example.org');
        $data->setId('4f1g23a12aa');

        var_dump($parsedToken->validate($data)); // false, because token cannot be used before now() + 60

        $data->setCurrentTime($time + 61); // changing the validation time to future

        var_dump($parsedToken->validate($data)); // true, because current time is between "nbf" and "exp" claims

        $data->setCurrentTime($time + 4000); // changing the validation time to future

        var_dump($parsedToken->validate($data)); // false, because token is expired since current time is greater than exp

        // We can also use the $leeway parameter to deal with clock skew (see notes below)
        // If token's claimed time is invalid but the difference between that and the validation time is less than $leeway,
        // then token is still considered valid
        $dataWithLeeway = new ValidationData($time, 20);
        $dataWithLeeway->setIssuer('http://example.com');
        $dataWithLeeway->setAudience('http://example.org');
        $dataWithLeeway->setId('4f1g23a12aa');

        var_dump($parsedToken->validate($dataWithLeeway)); // false, because token can't be used before now() + 60, not within leeway

        $dataWithLeeway->setCurrentTime($time + 51); // changing the validation time to future

        var_dump($parsedToken->validate($dataWithLeeway)); // true, because current time plus leeway is between "nbf" and "exp" claims

        $dataWithLeeway->setCurrentTime($time + 3610); // changing the validation time to future but within leeway

        var_dump($parsedToken->validate($dataWithLeeway)); // true, because current time - 20 seconds leeway is less than exp

        $dataWithLeeway->setCurrentTime($time + 4000); // changing the validation time to future outside of leeway

        var_dump($parsedToken->validate($dataWithLeeway)); // false, because token is expired since current time is greater than exp



    }



}
