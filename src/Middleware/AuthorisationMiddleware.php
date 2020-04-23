<?php


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

        // Disallow access if requirements dont meet.
        if( !$request->hasHeader($this->header) && !$this->allowanonymous ){
            if($contentType=="json"){
                return $response->withJson("access denied")->withStatus(403);
            }else{
                return $response->write("<h1>Access denied</h1>")->withStatus(403);
            }
        }

        //
        $request->hasHeader($this->header)[0];

        //$token = $request->getHeader($this->header)[0];


        //$response->getBody()->write('BEFORE');
        $response = $next($request, $response);
        //$response->getBody()->write( (string)$this->allowanonymous );

        return $response;
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

    private function parseToken(){

    }

    private function verifyToken(){

    }



}
