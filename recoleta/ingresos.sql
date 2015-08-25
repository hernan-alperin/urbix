select * from (
  select round(value) as "in PB-EM",  measure_time 
  from bkn_measure 
  natural full join bkn_measure_data 
  where sensor_id = 2 and type_code = 1 
  ) as ins_2
  natural full join (
  select round(value) as "in PB-HA",  measure_time 
  from bkn_measure 
  natural full join bkn_measure_data 
  where sensor_id = 3 and type_code = 1 
  ) as ins_3
  natural full join (
  select round(value) as "in PB-VL",  measure_time 
  from bkn_measure 
  natural full join bkn_measure_data 
  where sensor_id = 1 and type_code = 1 
  ) as ins_1
  natural full join (
  select round(value) as "in N1-UL",  measure_time 
  from bkn_measure 
  natural full join bkn_measure_data 
  where sensor_id = 4 and type_code = 1 
  ) as ins_4
  natural full join (
  select round(value) as "in N1-UJ",  measure_time 
  from bkn_measure 
  natural full join bkn_measure_data 
  where sensor_id = 5 and type_code = 1 
  ) as ins_5
  natural full join (
  select round(value) as "in N1-JG",  measure_time 
  from bkn_measure 
  natural full join bkn_measure_data 
  where sensor_id = 6 and type_code = 1 
  ) as ins_6
  natural full join (
  select round(value) as "in N1-JS",  measure_time 
  from bkn_measure 
  natural full join bkn_measure_data 
  where sensor_id = 7 and type_code = 1 
  ) as ins_7
  natural full join (
  select round(value) as "in N1-HA",  measure_time 
  from bkn_measure 
  natural full join bkn_measure_data 
  where sensor_id = 8 and type_code = 1 
  ) as ins_8
  natural full join (
  select round(value) as "in N2-HA",  measure_time
  from bkn_measure
  natural full join bkn_measure_data
  where sensor_id = 9 and type_code = 1
  ) as ins_9



where measure_time::text like '%00:00'
order by measure_time desc
;


