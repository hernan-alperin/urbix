<?php
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

?>
