drop view v_meassures;
create view v_meassures as
select to_char(time,'Day') as dia, to_char(time,'DD/MM/YY') as fecha, to_char(time,'HH:00') as periodo, * from
 (select time, data as "4"
  from bkn_result
  where '2015-01-01' <= time and time < '2015-05-01'
  and variable_id = 4) as f4
full join
 (select time, data as "5"
  from bkn_result
  where '2015-01-01' <= time and time < '2015-05-01'
  and variable_id = 5) as f5
using (time)
full join
 (select time, data as "6"
  from bkn_result
  where '2015-01-01' <= time and time < '2015-05-01'
  and variable_id = 6) as f6
using (time)
full join
 (select time, data as "7"
  from bkn_result
  where '2015-01-01' <= time and time < '2015-05-01'
  and variable_id = 7) as f7
using (time)
full join
 (select time, data as "8"
  from bkn_result
  where '2015-01-01' <= time and time < '2015-05-01'
  and variable_id = 8) as f8
using (time)
full join
 (select time, data as "9"
  from bkn_result
  where '2015-01-01' <= time and time < '2015-05-01'
  and variable_id = 9) as f9
using (time)
full join
 (select time, data as "10"
  from bkn_result
  where '2015-01-01' <= time and time < '2015-05-01'
  and variable_id = 10) as f10
using (time)
full join
 (select time, data as "11"
  from bkn_result
  where '2015-01-01' <= time and time < '2015-05-01'
  and variable_id = 11) as f11
using (time)
order by time
;


copy (select * from v_meassures) to stdout;

