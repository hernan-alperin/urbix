<?php
/*
urbixrecoleta=# \d bkn_measure
                                       Table "urbix.bkn_measure"
    Column     |            Type             |                        Modifiers                         
---------------+-----------------------------+----------------------------------------------------------
 measure_id    | integer                     | not null default nextval('bkn_measure_id_seq'::regclass)
 sensor_id     | integer                     | not null
 creation_date | timestamp without time zone | not null default now()
 measure_time  | timestamp without time zone | not null
 refresh       | boolean                     | not null default true
Indexes:
    "bkn_measure_pk" PRIMARY KEY, btree (measure_id)
    "bkn_measure_date_measure_time" btree (date(measure_time))
    "bkn_measure_measure_time_idx" btree (measure_time)
    "bkn_measure_refresh" btree (refresh)
Foreign-key constraints:
    "bkn_sensor_bkn_measure_fk" FOREIGN KEY (sensor_id) REFERENCES bkn_sensor(sensor_id)
Referenced by:
    TABLE "bkn_measure_data" CONSTRAINT "bkn_measure_masure_data_fk" FOREIGN KEY (measure_id) REFERENCES bkn_measure(measure_id)

                                 Table "urbix.bkn_measure_data"
     Column     |     Type      |                           Modifiers                           
----------------+---------------+---------------------------------------------------------------
 data_id        | integer       | not null default nextval('bkn_measure_data_id_seq'::regclass)
 measure_id     | integer       | not null
 type_code      | integer       | not null
 value          | numeric(10,4) | not null
 status         | integer       | not null
 original_value | numeric(10,4) | 
Indexes:
    "bkn_measure_data_pk" PRIMARY KEY, btree (data_id)
    "bkn_measure_data_measure_id" btree (measure_id)
Foreign-key constraints:
    "bkn_measure_masure_data_fk" FOREIGN KEY (measure_id) REFERENCES bkn_measure(measure_id)
Triggers:
    value_calibrated BEFORE INSERT OR UPDATE ON bkn_measure_data FOR EACH ROW EXECUTE PROCEDURE measure_calibrated()

*/

for ($i=1; $i<17; $i++) $sensors[] = $i;
// todo hacer consulta para saber id reales FOREIGN KEY (sensor_id) REFERENCES bkn_sensor(sensor_id)

$numberOfSensors = sizeof($sensors);

$startingDay = '2015-05-01';
//$numberOfDays = 10;
$diff1Day = new DateInterval('P1D');
$startDate = new DateTime($startingDay);
//$endDate = clone $startDate;
//$plusNumberOfDays = new DateInterval("P${numberOfDays}D");
//$endDate->add($plusNumberOfDays);
$endDate = new DateTime(); //now


$openHours = new DateTime('09:00');
$closeHours = new DateTime('24:00');
$diff1Hour = new DateInterval('PT1H');

function poisson($lambda = 200) {// gets a poisson randomly generated number
  $k = 0; $p = 1; $L = exp(-$lambda);
  while ($p>$L) {
    $k++;
    $u = rand()/getrandmax();
    $p *= $u;
  }
  return $k-1;
}

/* check distribution
function average($arr) {
  if (!is_array($arr)) return 0;
  return array_sum($arr)/count($arr);
}
function variance($aValues, $bSample = false){
  $fMean = array_sum($aValues) / count($aValues);
  $fVariance = 0.0;
  foreach ($aValues as $i) {
    $fVariance += pow($i - $fMean, 2);
  }
  $fVariance /= ( $bSample ? count($aValues) - 1 : count($aValues) );
  return $fVariance;
}
echo average($results)."\n";
echo variance($results)."\n";
*/
$meassure_id = 0;
$meassure_data_id = 0;
for ($day = clone $startDate; $day<$endDate; $day->add($diff1Day)) {
  for ($hour = clone $openHours; $hour<$closeHours; $hour->add($diff1Hour)) {
    for ($i=0; $i<$numberOfSensors; $i++) {
      $meassure_time = $day->format("Y-m-d ").$hour->format("H:i");
      $creationHour = clone $hour;
      $creationHour->add(new DateInterval('PT1H10M'));
      $creation_time = $day->format("Y-m-d ").$creationHour->format("H:i");
      $bkn_measure[] = "$meassure_id\t$sensors[$i]\t$creation_time\t$meassure_time\tt";
      $in_value = poisson();
      // 5 means simulated and set real_value to null
      $bkn_measure_data[] = "$meassure_data_id\t$meassure_id\t1\t$in_value\t5\t\N";
      $meassure_data_id++;
      $out_value = poisson();
      $bkn_measure_data[] = "$meassure_data_id\t$meassure_id\t2\t$out_value\t5\t\N";
      $meassure_data_id++;
      $meassure_id++;
    }
  }
}

/*
// check results
for ($i=0; $i<10; $i++) echo $bkn_measure[$i]."\n";
echo "----\n";
for ($i=0; $i<10; $i++) echo $bkn_measure_data[$i]."\n";
*/

echo "truncate bkn_measure cascade;\n";
echo "copy bkn_measure from stdin;\n";
while ($record=array_shift($bkn_measure)) echo "$record\n";
echo "\.\n";
echo "copy bkn_measure_data from stdin;\n";
while ($record=array_shift($bkn_measure_data)) echo "$record\n";
echo "\.\n";
echo "select formula_engine();\n";

?>
