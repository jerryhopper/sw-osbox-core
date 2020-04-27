<?php



require __DIR__ . '/../vendor/autoload.php';






Swoole \Timer::set([
    'enable_coroutine' => true,
]);

$count = 0;
function tick($timerid, $taskObjects)
{
    global $count;
    $count++;


    // https://github.com/peppeocchi/php-cron-scheduler
    // Create a new scheduler
    $scheduler = new Scheduler();

    // ... configure the scheduled jobs (see below) ...

    // Let the scheduler execute jobs which are due.
    $scheduler->run();




    //var_dump($count);
    //go(function() {
        //$ret = Swoole\Coroutine\System::exec("ls -latr");
        //print_r($ret);
        //print_r(Swoole\Timer::list() );
    //});

    if($count >= 25)
    {
        Swoole\Timer::clear($timerid);
    }
}



$taskId = Swoole\Timer::tick(1000, "tick",$tasks);


die();



/*






echo "TimerID = ".$x."\n";
//print_r($x);

#print_r(Swoole\Timer::list() );
#print_r(Swoole\Timer::info());
#print_r(Swoole\Timer::stats());

die();

echo "start\n";


$data['startTime'] = time()+15;;
$data['endTime'] = $data['startTime']+60;
$data['action']="disable";;
$data['group']= 4;
$data['list']= "bla";


class taskObject {

    private $startTime;
    private $endTime;
    private $action;
    private $group;
    private $list;


    function setStartTime($value){
        $this->startTime = $value;
    }
    function setEndTime($value){
        $this->endTime = $value;
    }
    function setAction($value){
        $this->action = $value;
    }
    function setGroup($value){
        $this->group = $value;
    }
    function setList($value){
        $this->list = $value;
    }
    function __get($name)
    {
        // TODO: Implement __get() method.
        if ( property_exists(this,$name)){
            return $this->$name;
        }
        throw new Exception("property does not exist.");
    }
}




if ($data['action']=='disable'){
   $action1="disable";
   $action2="enable";
}else{
    $action1="enable";
    $action2="disable";
}

$sleepstart = ($data['startTime'] -time());
$sleepend = $data['endTime']-time();

$action =$data['action'];
$group = $data['group'];


echo $action1." list ".$data['list']." group ".$data['group']." ".date(DATE_RFC2822,$data['startTime'])."\n";

echo $action2." list ".$data['list']." group ".$data['group']." ".date(DATE_RFC2822,$data['endTime'])."\n";





$run = new Swoole\Coroutine\Scheduler;




$run->add(function () {
    global $sleepstart;
    Co::sleep($sleepstart);
    //echo $startTime-time();
    echo "Done 1.\n";
});

$run->add(function () {
    global $sleepend;

    Co::sleep($sleepend);
    echo "Done 2.\n";
});
$run->start();


die();


/*
# multiple conexts

$run = new Swoole\Coroutine\Scheduler;

$run->add(function () {
    echo "Waiting until start-time."

    Swoole\Coroutine::sleep($startTime-time());
    echo "Start!\n";
});


$run->add(function () {
    Swoole\Coroutine::sleep($endTime-time());
    echo "End!\n";
});


$run->start();

# or

Co\run(function() {
    Swoole\Coroutine::sleep(1);
    echo "Done.\n";
});


exit;

/*

recurring true/false

sun mon tue wed thu fri sat sun

start-time end-time

* /




Swoole \Timer::set([
    'enable_coroutine' => true,
]);

$count = 0;
function run($timerid, $param)
{
    global $count;
    $count++;
    var_dump($count);
    if($count >= 10)
    {
        Swoole\Timer::clear($timerid);
    }
}


$x= Swoole\Timer::tick(1000, "run",["startTime"=>0, "endTime"=>10]);


print_r($x);

die();
*/

