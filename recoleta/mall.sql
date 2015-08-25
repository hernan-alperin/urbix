-- creación de esquema de desarrollo de vistas según modelo ER propuesto

create schema mall;
set search_path to mall, urbix, public;

drop view variables cascade;
create view variables as
select variable_id, description, branch_id as branch
from bkn_variable
order by description
;
select * from variables
;

drop view sensors cascade;
create view sensors as
select sensor_id, description, access_code as access, branch_code as branch
from bkn_sensor
order by description
;
select * from sensors
;

drop view sensors_factors;
create view sensors_factors as
select sensor_id, description, type_code, access_code as access, round(factor_value,2) as factor
from bkn_sensor
natural join bkn_sensor_factor
order by description, type_code
;
select * from sensors_factors
;

drop view variables_formulas;
create view variables_formulas as
select variables.*, active_formula_id, formula_id
from variables 
natural full join bkn_active_formula
order by variable_id
;
select * from variables_formulas
;

create view meassures as
select * 
from bkn_measure natural join bkn_measure_data
;

drop view variables_accesses cascade;
create view variables_accesses as
select variables_formulas.*, value::integer as access, active_formula_param_id as rec_id_acc
from variables_formulas 
natural full join (
  select * 
  from bkn_active_formula_param
  where formula_param_id = 101
  ) as vars_with_access
order by description, formula_param_id, value
;
select * from variables_accesses
;

drop view variables_accesses_factors;
create view variables_accesses_factors as
select variables_accesses.*, factor, rec_id_factor
from variables_accesses
full join (
  select active_formula_id, active_formula_param_id as rec_id_factor, value as factor
  from bkn_active_formula_param
  where formula_param_id = 100
) as factors
using (active_formula_id)
;   
select * from variables_accesses_factors
;   

-- creando funciones para acceder a las variables
-- y vistas

drop view variables_sensors;
create view variables_sensors as
select variables_accesses.description as variable, variable_id as v_id, variables_accesses.branch as v_branch,
  access, sensors.branch as s_branch, 
  sensor_id as s_id, sensors.description as sensor
from variables_accesses
full join sensors
using (access)
;
select * from variables_sensors;

-- revisar...
drop view sensors_meassures;
create view sensors_meassures as
select sensors.*, meassures.type_code, measure_time, meassures.original_value*factor_value as meassure
from sensors
join meassures
using (sensor_id)
join bkn_sensor_factor
using (sensor_id, type_code)
;
select * from sensors_meassures where measure_time='2015-06-22 23:00:00';


---- test
select sensor_id, 
  case 
    when type_code=1 then description||' in'
    when type_code=2 then description||' out'
  end as "medición sumarizada del 2015-06-15", 
  round(sum(meassure)) as meassure
from sensors_meassures
where date(measure_time)='2015-06-15'
group by sensor_id, description, type_code
order by sensor_id, type_code
;

drop view variables_meassures;
create view variables_meassures as
select v_id, 
  case 
    when variable is null then 'medicion de sensores sin variable asignada'
    else variable
  end, sensors_meassures.type_code, measure_time, sum(meassure) as meassure
from variables_sensors
join sensors_meassures
on sensor_id = s_id
group by v_id, variable, measure_time, type_code
;
select * from variables_meassures limit 10;

select v_id, variable, type_code, sum(meassure) 
from variables_meassures
where date(measure_time)='2015-06-15'
group by v_id, variable, type_code
order by v_id, type_code 
;





-- creando funciones para acceder a las mediciones 
-- por sensor y pares de sensores

drop function meassures_sensor(sensor text);
create or replace function meassures_sensor(sensor text) 
returns
table (data_id int, type_code int, time_lapse timestamp, datum numeric) 
as $$
  select data_id, type_code, measure_time as time_lapse, value as datum
  from meassures
  where 's_'||(sensor_id::text)=$1
$$
language sql
stable
;

select * from (
  select type_code, time_lapse, datum as "s_6" from meassures_sensor('s_6')
) as s_6
natural join (
  select type_code, time_lapse, datum as "s_7" from meassures_sensor('s_7')
) as s_7
;


CREATE TABLE test (x INT[]);
INSERT INTO test VALUES ('{1,2,3,4,5}');

SELECT x AS array_pre_pop,
       x[array_lower(x,1) : array_upper(x,1)-1] AS array_post_pop, 
       x[array_upper(x,1)] AS popped_value 
FROM test;

SELECT x AS array_pre_shift,
       x[array_lower(x,1)] AS shifted_value,
       x[array_lower(x,1)+1 : array_upper(x,1)] AS array_post_shift
FROM test;




create or replace function meassures_sensor(sensor int, start_timestamp timestamp, end_timestamp timestamp)
returns 
table (data_id int, type_code int, time_lapse timestamp, datum numeric)
as $$
  select *
  from meassures_sensor($1)
  where time_lapse between $2 and $3
$$
language sql
stable
;

drop function meassures_sensor_pair(sensor_0 int, sensor_1 int);
create or replace function meassures_sensor_pair(sensor_0 int, sensor_1 int)
returns table (time_lapse timestamp, type_code int, s_0_data_id int, s_1_data_id int, s_0 numeric, s_1 numeric)
as $$
  select 
    s_0.time_lapse as "timestamp", 
    s_0.type_code as "as in/out", 
    s_0.data_id as s_0_data_id, s_1.data_id as s_1_data_id, 
    s_0.datum as s_0, s_1.datum as s_1 
  from meassures_sensor($1) as "s_"||($1::text) 
  join meassures_sensor($2) as "s_"||($2::text)
  using (time_lapse,type_code)
  order by time_lapse,type_code
$$
language sql
stable
;

select * from meassures_sensor_pair(6,7);


---------------- ARREGLO hecho en agg-biyemas (pasar luego a otro archivo)
--simular/imputar/craer datos estimados 
--para sensor faltante a partir de otro sensor
drop view access_7 cascade;
create view access_7 as
select s_7.data_id, s_6.measure_time, s_6.value as s_6, s_7.value as s_7, s_6.type_code
from meassures s_6
join meassures s_7
on s_6.measure_time = s_7.measure_time
and s_6.sensor_id = 6 and s_7.sensor_id = 7 --los 2 sensores del acceso 7
and s_6.type_code = s_7.type_code
;


begin;
update bkn_measure_data
set value = 0.13*s_6
from access_7
where bkn_measure_data.value is null or bkn_measure_data.value = 0 
and bkn_measure_data.data_id = access_7.data_id
and bkn_measure_data.type_code = 1 --in
;
update bkn_measure_data
set value = 0.35*s_6
from access_7
where bkn_measure_data.value is null or bkn_measure_data.value = 0
and bkn_measure_data.data_id = access_7.data_id
and bkn_measure_data.type_code = 2 --out
;

select * from access_7
;
--commit;

