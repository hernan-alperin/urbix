select * from (
  select value as "in PB-EM",  measure_time 
  from bkn_measure 
  natural full join bkn_measure_data 
  where sensor_id = 2 and type_code = 1 
  ) as ins_2
  natural full join ( 
  select value as "out PB-EM",  measure_time
  from bkn_measure
  natural full join bkn_measure_data
  where sensor_id = 2 and type_code = 2
  ) as outs_2
  natural full join (
  select value as "in PB-HA",  measure_time 
  from bkn_measure 
  natural full join bkn_measure_data 
  where sensor_id = 3 and type_code = 1 
  ) as ins_3
  natural full join ( 
  select value as "out PB-HA",  measure_time
  from bkn_measure
  natural full join bkn_measure_data
  where sensor_id = 3 and type_code = 2
  ) as outs_3
  natural full join (
  select value as "in PB-VL",  measure_time 
  from bkn_measure 
  natural full join bkn_measure_data 
  where sensor_id = 1 and type_code = 1 
  ) as ins_1
  natural full join ( 
  select value as "out PB-VL",  measure_time
  from bkn_measure
  natural full join bkn_measure_data
  where sensor_id = 1 and type_code = 2
  ) as outs_a1
  natural full join (
  select value as "in N1-UL",  measure_time 
  from bkn_measure 
  natural full join bkn_measure_data 
  where sensor_id = 4 and type_code = 1 
  ) as ins_4
  natural full join ( 
  select value as "out N1-UL",  measure_time
  from bkn_measure
  natural full join bkn_measure_data
  where sensor_id = 4 and type_code = 2
  ) as outs_4
  natural full join (
  select value as "in N1-UJ",  measure_time 
  from bkn_measure 
  natural full join bkn_measure_data 
  where sensor_id = 5 and type_code = 1 
  ) as ins_5
  natural full join ( 
  select value as "out N1-UJ",  measure_time
  from bkn_measure
  natural full join bkn_measure_data
  where sensor_id = 5 and type_code = 2
  ) as outs_5
  natural full join (
  select value as "in N1-HA",  measure_time 
  from bkn_measure 
  natural full join bkn_measure_data 
  where sensor_id = 8 and type_code = 1 
  ) as ins_8
  natural full join ( 
  select value as "out N1-HA",  measure_time
  from bkn_measure
  natural full join bkn_measure_data
  where sensor_id = 8 and type_code = 2
  ) as outs_8
  natural full join (
  select value as "in N2-HA",  measure_time
  from bkn_measure
  natural full join bkn_measure_data
  where sensor_id = 9 and type_code = 1
  ) as ins_9
  natural full join (
  select value as "out N2-HA",  measure_time
  from bkn_measure
  natural full join bkn_measure_data
  where sensor_id = 9 and type_code = 2
  ) as outs_9



--natural full join (
--  select sensor_id, description
--  from bkn_sensor) as sensors
order by measure_time desc
;


