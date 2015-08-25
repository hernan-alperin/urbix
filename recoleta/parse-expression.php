<?php
// expression defines a variable from the sensors
// example: v_1 := s_1_i + s_2_i - s_3_o/2

$example = 'v_1 := s_1_i + s_2_i - s_3_o/2';
$example = 'v_1 := round(s_1_i + s_2_i - s_3_o/2)';

list($var_name,$var_definition) = preg_split('/ *:= */',$example);
$ok = preg_match_all('/s_\d+_[io]/',$var_definition,$matches);
$sensors=$matches[0];

if ($ok) { // there is at least one
  $sql="select timestamp, $var_definition as \"$var_name\" from \n";
  $sensor = substr($s=$sensors[0],0,-2);
  $sql.="  (select timestamp, meassure as \"$s\" from meassures_sensor('$sensor') where type_code = ";
  switch (substr($s,-1)) {
    case 'i': $sql.='1'; break;
    case 'o': $sql.='2'; break;
  }
  $sql.=") as $s\n";
  for ($i=1; $i<count($sensors); $i++) { // for the 2nd and on it must be joined
    $s=$sensors[$i];
    $sql.="natural join\n";
    $sensor = substr($s,0,-2);
    $sql.="  (select timestamp, meassure as \"$s\" from meassures_sensor('$sensor') where type_code = ";
    switch (substr($s,-1)) {
      case 'i': $sql.='1'; break;
      case 'o': $sql.='2'; break;
    }
    $sql.=") as $s\n";
  }
  $sql.=";\n";
}

print($sql);
?>
