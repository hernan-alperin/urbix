select * from 
 (select time, data as "1"
  from bkn_result
  where '2015-01-01' <= time and time <= '2015-05-05'
  and variable_id = 1) as f1
full join
 (select time, data as "2"
  from bkn_result
  where '2015-01-01' <= time and time <= '2015-05-05'
  and variable_id = 2) as f2
using (time)
full join
 (select time, data as "82"
  from bkn_result
  where '2015-01-01' <= time and time <= '2015-05-05'
  and variable_id = 8) as f8
using (time)
full join
 (select time, data as "12"
  from bkn_result
  where '2015-01-01' <= time and time <= '2015-05-05'
  and variable_id = 12) as f12
using (time)
full join
 (select time, data as "14"
  from bkn_result
  where '2015-01-01' <= time and time <= '2015-05-05'
  and variable_id = 14) as f14
using (time)
full join
 (select time, data as "16"
  from bkn_result
  where '2015-01-01' <= time and time <= '2015-05-05'
  and variable_id = 16) as f16
using (time)
;
