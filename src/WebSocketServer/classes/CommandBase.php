<?php

use Swoole\WebSocket\Server;
use Swoole\Http\Request;
use Swoole\WebSocket\Frame;




class CommandBase
{
    public $method;
    public $subcommands;
    public $pusher;

    function __construct( pusher $pusher)
    {
        $this->pusher=$pusher;
    }

}
