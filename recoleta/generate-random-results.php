<?php
include_once("poisson.php");
/*
alpe@sandbox:~/urbix/recoleta$ psql -h urbix-desarrollo.thin-hippo.net -U urbix urbixrecoleta -c '\d bkn_result'
                                      Table "urbix.bkn_result"
   Column    |            Type             |                        Modifiers
-------------+-----------------------------+---------------------------------------------------------
 result_id   | integer                     | not null default nextval('bkn_result_id_seq'::regclass)
 variable_id | integer                     | not null
 time        | timestamp without time zone | not null
 data        | numeric(10,4)               |
Indexes:
    "bkn_result_pk1" PRIMARY KEY, btree (result_id)
    "bkn_result_time_idx" btree ("time")
    "bkn_result_variable_idx" btree (variable_id)
Foreign-key constraints:
    "bkn_variable_bkn_result_fk" FOREIGN KEY (variable_id) REFERENCES bkn_variable(variable_id)

*/

$variables = array(6,8,10,12,14,16,18,20,22,24);
// todo hacer consulta para saber id reales 

$numberOfVariables = sizeof($variables);

$startingDay = '2015-05-01';
$diff1Day = new DateInterval('P1D');
$startDate = new DateTime($startingDay);
$endDate = new DateTime();

$openHours = new DateTime('09:00');
$closeHours = new DateTime('24:00');
$diff1Hour = new DateInterval('PT1H');

$result_id = 0;
for ($day = clone $startDate; $day<$endDate; $day->add($diff1Day)) {
  for ($hour = clone $openHours; $hour<$closeHours; $hour->add($diff1Hour)) {
    for ($i=0; $i<$numberOfVariables; $i++) {
      $time = $day->format("Y-m-d ").$hour->format("H:i");
      $data = poisson();
      $bkn_result[] = "$result_id\t$variables[$i]\t$time\t$data";
      $result_id++;
    }
  }
}

/*
// check results
for ($i=0; $i<10; $i++) echo $bkn_measure[$i]."\n";
echo "----\n";
for ($i=0; $i<10; $i++) echo $bkn_measure_data[$i]."\n";
*/

echo "truncate bkn_result cascade;\n";
echo "copy bkn_result from stdin;\n";
while ($record=array_shift($bkn_result)) echo "$record\n";
echo "\.\n";

?>
