<?php

class HostnameMiddleware{

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
        // TODO: Implement __invoke() method.
        //$request->getScheme();

        $configured = false;
        $configuredfqdn="blackbox.surfwijzer.nl";
        $proto="https://";
        $localdn="osbox.local";


        if( $request->getHost() == $localdn && $configured ) {
            # request on osbox.local and configured is true
            return $response->withRedirect($proto.$configuredfqdn);

        }elseif( $request->getHost() == $localdn && $configured ){
            # request on osbox.local and configured is false

        }elseif( $request->getHost() == $configuredfqdn ){
            # request on a configured device.
            if( $request->getScheme() != "https"){
                # request is not https - redirect.
                return $response->withRedirect($proto.$configuredfqdn);
            }
            # secure request on a configured device

        }



        $response = $next($request, $response);


        return $response;
    }
}
