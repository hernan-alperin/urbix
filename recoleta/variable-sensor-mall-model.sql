-- creación de esquema de desarrollo de vistas según modelo ER propuesto

create schema mall;
set search_path to mall, urbix, public;

drop view variables cascade;
create view variables as
select variable_id as v_id, description as variable, company_id as c_id, public
from bkn_variable
;
select * from variables
;

drop view sensors cascade;
create view sensors as
select sensor_id as s_id, description as sensor, access_code as a_id, branch_code as b_id, organization_code as c_id
from bkn_sensor
;
select * from sensors
;

drop view sensors_factors;
create view sensors_factors as
select sensor_id as s_id, description as sensor, type_code as way, access_code as a_id, round(factor_value,2) as factor
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
full join bkn_active_formula
on v_id=variable_id
order by v_id
;
select * from variables_formulas
;

drop view meassures; 
create view meassures as
select sensor_id as s_id, measure_time as timestamp, type_code as way, 
  status, original_value as original, value, original_value*factor_value as corrected
from bkn_measure 
natural join bkn_measure_data
join bkn_sensor_factor
using (sensor_id, type_code)
where measure_time between start_date and end_date 
or start_date <= measure_time and end_date is null
;
select * from meassures
where date(timestamp)='2015-06-22'
order by timestamp, s_id, way
;


-- these views are for dealing with current model to search how variables connect to sensors using formulas
-- by access_code (now a_id)

drop view variables_accesses cascade;
create view variables_accesses as
select variables_formulas.*, value::integer as a_id, active_formula_param_id as rec_id_acc
from variables_formulas
natural full join (
  select *
  from bkn_active_formula_param
  where formula_param_id = 101
  ) as vars_with_access
order by variable, formula_param_id, value
;
select * from variables_accesses
;

drop view variables_accesses_factors;
create view variables_accesses_factors as
select variables_accesses.*, factor, rec_id_factor
from variables_accesses
full join (
  select active_formula_id, active_formula_param_id as rec_id_factor, value::numeric as factor
  from bkn_active_formula_param
  where formula_param_id = 100
) as factors
using (active_formula_id)
;
select * from variables_accesses_factors
;

drop view variables_accesses_way;
create view variables_accesses_way as
select variables_accesses.*, way, rec_id_way
from variables_accesses
full join (
  select active_formula_id, active_formula_param_id as rec_id_way, value::int as way  from bkn_active_formula_param
  where formula_param_id = 102
) as way
using (active_formula_id)
;
select * from variables_accesses_way
order by way
;

drop view variables_sensors;
create view variables_sensors as
select variable, v_id, variables_accesses.c_id as v_c_id,
  a_id, sensors.b_id as s_b_id,
  s_id, sensor
from variables_accesses
full join sensors
using (a_id)
;
select * from variables_sensors;



-- done by asuming sensor-way aligns with access-way   
-- must use formula_param
drop view variables_meassures;
create view variables_meassures as
select v_id,
  case
    when variable is null then 'medicion de sensores sin variable asignada'
    else variable
  end, way, timestamp, sum(corrected) as meassure
from variables_accesses_way
join sensors
using (a_id)
join meassures
using(s_id,way)
group by v_id, variable, timestamp, way
;
select * from variables_meassures limit 10;

select v_id, variable, way, sum(meassure)
from variables_meassures
where date(timestamp)='2015-06-15'
group by v_id, variable, way
order by v_id, way
;


-- creando funciones para acceder a las mediciones 
-- por sensor y pares de sensores
-- function to access meassurements by sensor to build complex queries using expression languand through php parsing
drop function meassures_sensor(sensor text);
create or replace function meassures_sensor(sensor text)
returns
table (way int, "timestamp" timestamp, meassure numeric)
as $$
  select way, timestamp, corrected as meassure
  from meassures
  where 's_'||(s_id::text)=$1
$$
language sql
stable
;





