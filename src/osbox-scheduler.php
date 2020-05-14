<?php

use GO\Scheduler;

require __DIR__ . '/../vendor/autoload.php';


#error_reporting(1);
#ini_set(display_errors,true);

$pid = getmypid();
#echo "PID:$pid";


#display_errors(1);

Swoole \Timer::set([
    'enable_coroutine' => true,
]);

function tick($timerid, $tasks)
{
    $scheduler = scheduleTasks($tasks);
    // Let the scheduler execute jobs which are due.
    $scheduler->run();
}


function scheduleTasks( $tasks ){

    // https://github.com/peppeocchi/php-cron-scheduler
    // Create a new scheduler
    $scheduler = new Scheduler([
        'tempDir' => '/tmp'
    ]);
    //$scheduler = new Scheduler();
    foreach( $tasks as $task){

        $type = $task['type'];

        if($type=="at") {
            $scheduler->raw($task['raw'])->at($task['value']);

        }elseif ($type=="daily"){
            if($task['value']==""){
                $scheduler->raw($task['raw'])->daily();
            }else{
                $scheduler->raw($task['raw'])->daily($task['value']);
            }

        }elseif ($type=="hourly"){
            if($task['value']!=""){
                $scheduler->raw($task['raw'])->hourly($task['value']);
            }else{
                $scheduler->raw($task['raw'])->hourly();
            }

        }elseif($type=="everyMinute"){
            if($task['value']==""){
                $scheduler->raw($task['raw'])->everyMinute();
            }else{
                $scheduler->raw($task['raw'])->everyMinute($task['value']);
            }

        }elseif($type=="sunday"){
            if($task['value']==""){
                $scheduler->raw($task['raw'])->sunday();
            }else{
                $scheduler->raw($task['raw'])->sunday($task['value']);
            }
        }elseif($type=="monday"){
            if($task['value']==""){
                $scheduler->raw($task['raw'])->monday();
            }else{
                $scheduler->raw($task['raw'])->monday($task['value']);
            }
        }
        elseif($type=="tuesday"){
            if($task['value']==""){
                $scheduler->raw($task['raw'])->tuesday();
            }else{
                $scheduler->raw($task['raw'])->tuesday($task['value']);
            }
        }
        elseif($type=="wednesday"){
            if($task['value']==""){
                $scheduler->raw($task['raw'])->wednesday();
            }else{
                $scheduler->raw($task['raw'])->wednesday($task['value']);
            }
        }
        elseif($type=="thursday"){
            if($task['value']==""){
                $scheduler->raw($task['raw'])->thursday();
            }else{
                $scheduler->raw($task['raw'])->thursday($task['value']);
            }
        }
        elseif($type=="friday"){
            if($task['value']==""){
                $scheduler->raw($task['raw'])->friday();
            }else{
                $scheduler->raw($task['raw'])->friday($task['value']);
            }
        }elseif($type=="saturday"){
            if($task['value']==""){
                $scheduler->raw($task['raw'])->saturday();
            }else{
                $scheduler->raw($task['raw'])->saturday($task['value']);
            }
        }elseif($type=="january"){
            if($task['value']==""){
                $scheduler->raw($task['raw'])->january();
            }else{
                $scheduler->raw($task['raw'])->january($task['value']);
            }
        }elseif($type=="february"){
            if($task['value']==""){
                $scheduler->raw($task['raw'])->february();
            }else{
                $scheduler->raw($task['raw'])->february($task['value']);
            }
        }elseif($type=="march"){
            if($task['value']==""){
                $scheduler->raw($task['raw'])->march();
            }else{
                $scheduler->raw($task['raw'])->march($task['value']);
            }
        }elseif($type=="april"){
            if($task['value']==""){
                $scheduler->raw($task['raw'])->april();
            }else{
                $scheduler->raw($task['raw'])->april($task['value']);
            }
        }elseif($type=="may"){
            if($task['value']==""){
                $scheduler->raw($task['raw'])->may();
            }else{
                $scheduler->raw($task['raw'])->may($task['value']);
            }
        }elseif($type=="june"){
            if($task['value']==""){
                $scheduler->raw($task['raw'])->june();
            }else{
                $scheduler->raw($task['raw'])->june($task['value']);
            }
        }elseif($type=="july"){
            if($task['value']==""){
                $scheduler->raw($task['raw'])->july();
            }else{
                $scheduler->raw($task['raw'])->july($task['value']);
            }
        }elseif($type=="august"){
            if($task['value']==""){
                $scheduler->raw($task['raw'])->august();
            }else{
                $scheduler->raw($task['raw'])->august($task['value']);
            }
        }elseif($type=="september"){
            if($task['value']==""){
                $scheduler->raw($task['raw'])->september();
            }else{
                $scheduler->raw($task['raw'])->september($task['value']);
            }
        }elseif($type=="october"){
            if($task['value']==""){
                $scheduler->raw($task['raw'])->october();
            }else{
                $scheduler->raw($task['raw'])->october($task['value']);
            }
        }elseif($type=="november"){
            if($task['value']==""){
                $scheduler->raw($task['raw'])->november();
            }else{
                $scheduler->raw($task['raw'])->november($task['value']);
            }
        }elseif($type=="december"){
            if($task['value']==""){
                $scheduler->raw($task['raw'])->december();
            }else{
                $scheduler->raw($task['raw'])->december($task['value']);
            }
        }




    }

    return $scheduler;

}

/**
 * Always add the update task.
 **/
$tasks = array();
#$tasks[] = array("raw"=>"osbox update web","type"=>"hourly","value"=>"");
$tasks[] = array("raw"=>"osbox update web","type"=>"everyHour","value"=>"");
#$tasks[] = array("raw"=>"echo 'yes'>>/var/log/php_errors.log ","type"=>"at","value"=>"* * * * *");
#$tasks[] = array("raw"=>"echo 'yes!'>>/var/log/php_errors.log ","type"=>"everyMinute","value"=>"");


/**
 * Add the tasks from the database.
 **/
if( file_exists("/etc/osbox/db/osbox.db") ){
    // read tasks from the database.
    //$tasks[] = array();
}
/*
$tasks = array(
    array("raw"=>"osbox update","type"=>"hourly","value"=>"22:00"),
    array("raw"=>"osbox disable group 4","type"=>"at","value"=>"* * * * *"),
    array("raw"=>"osbox disable group 4","type"=>"daily","value"=>"22:03"),
    array("raw"=>"osbox enable group 4","type"=>"daily","value"=>"22:05")
);
*/


// "/var/run/osbox-scheduler.pid"





$pid = getmypid();
echo "Running under pid $pid\n";
$taskId = Swoole\Timer::tick((1000*60), "tick", $tasks );




