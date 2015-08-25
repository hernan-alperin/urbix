<?php
echo strtotime("now"), "\n";
echo strtotime("10 September 2000"), "\n";
echo strtotime("+1 day"), "\n";
echo strtotime("+1 week"), "\n";
echo strtotime("+1 week 2 days 4 hours 2 seconds"), "\n";
echo strtotime("next Thursday"), "\n";
echo strtotime("last Monday"), "\n";

$time = date('H:i', strtotime('+1 hour'));

echo "-----------------\n";

$d0 = new DateTime('2014-03-29 08:00:00');
$diff1Day = new DateInterval('PT1H');
print_r($d0);

?>
