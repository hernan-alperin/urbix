begin;
drop schema if exists private cascade;
create schema private;
set search_path to private, public, urbix;

-- crear indices necesarios para que el cálculo de las variables sea eficiente:
drop index if exists urbix.bkn_measure_sensor_id;
create index bkn_measure_sensor_id on urbix.bkn_measure (sensor_id);
drop index if exists urbix.bkn_measure_time_sensor_id;
create index bkn_measure_time_sensor_id on urbix.bkn_measure (measure_time, sensor_id);
drop index if exists urbix.bkn_measure_time_hour;
create index bkn_measure_time_hour on urbix.bkn_measure (date_part('hour',measure_time));


-- view measures para tener acceso dinámico a las mediciones.
create view measures as
select sensor_id as s_id, type_code as s_ch, status, 
  measure_time as timestamp, original_value as original, value, 
  original_value*(case when factor_value is null then 1 else factor_value end) as corrected
from urbix.bkn_measure 
natural join urbix.bkn_measure_data
left join urbix.bkn_sensor_factor
using (sensor_id, type_code)
where measure_time between start_date and end_date 
or start_date <= measure_time and end_date is null -- (?) hace falta o la lines siguien lo subsume, dejémoslo para clarificar.

or end_date is null -- caso que no exista registro
;
-- ejemplo: select * from measures where date(timestamp)='2015-06-22' order by timestamp, s_id, s_ch ;

create view sensors as
select sensor_id as s_id, description as sensor, access_code as a_id, branch_code as b_id, organization_code as c_id
from urbix.bkn_sensor
;
-- check it out: select * from sensors order by s_id;

create view sensors_factors as
select sensor_id as s_id, description as sensor, 
  type_code as s_ch, factor_value as factor,
  start_date, end_date, comment
from urbix.bkn_sensor
natural join urbix.bkn_sensor_factor
;
-- check it out: select * from sensors_factors ;

create view variables as
select variable_id as v_id, description as variable, public
from urbix.bkn_variable
;
-- check it out: select * from variables ;

create view variables_formulas as
select variables.*, active_formula_id, formula_id, urbix.bkn_formula.name as formula
from variables
full join urbix.bkn_active_formula
on v_id=variable_id
join urbix.bkn_formula
using (formula_id)
order by v_id
;
-- check it out: select * from variables_formulas ;

create view variables_factors as
select v_id, active_formula_id, value::numeric as factor,
  start_date, end_date
from variables_formulas
natural join
urbix.bkn_active_formula
join urbix.bkn_active_formula_param
using (active_formula_id)
where formula_param_id % 100 = 0 -- param_id mod 0 (100) corresponde a factores
;
-- check it out: select * from variables_factors;

-- these views are for dealing with current model to search how variables connect to sensors using formulas
-- by access_code (now a_id)

create view variables_accesses as
select v_id, variable, formula, value::integer as a_id, chanel
from variables_formulas
natural join (
  select *
  from urbix.bkn_active_formula_param
  where formula_param_id = 101
  ) as vars_with_access
join (
  select active_formula_id, active_formula_param_id as rec_id_way, value::int as chanel  from urbix.bkn_active_formula_param
  where formula_param_id = 102
) as chanel
using (active_formula_id)
where formula_id=1
;
-- check it out: select * from variables_accesses order by v_id ;

create view variables_sensors_accesses as
select variable, v_id, a_id, s_id, chanel as s_ch, sensor
from variables_accesses
join sensors
using (a_id)
;
-- check it out: select * from variables_sensors_accesses order by v_id;

create view variables_branches as
select v_id, variable, formula, value::integer as b_id, chanel
from variables_formulas
join (
  select *
  from urbix.bkn_active_formula_param
  where formula_param_id = 201
  ) as vars_with_branch
using (active_formula_id)
join (
  select active_formula_id, active_formula_param_id as rec_id_way, value::int as chanel 
  from urbix.bkn_active_formula_param
  where formula_param_id = 202
) as chanel
using (active_formula_id)
where formula_id=2
;
-- check it out: select * from variables_branches ;

create view variables_sensors_branches as
select variable, v_id, b_id, s_id, chanel as s_ch, sensor
from variables_branches
join sensors
using (b_id)
;
-- check it out: select * from variables_sensors_branches order by s_id, v_id, b_id ;

create view variables_companies as
select v_id, variable, formula, value::integer as c_id, chanel
from variables_formulas
join (
  select *
  from urbix.bkn_active_formula_param
  where formula_param_id = 201
  ) as vars_with_branch
using (active_formula_id)
join (
  select active_formula_id, active_formula_param_id as rec_id_way, value::int as chanel from urbix.bkn_active_formula_param
  where formula_param_id = 202
) as chanel
using (active_formula_id)
where formula_id=13
;
-- check it out: select * from variables_companies ;

create view variables_sensors_companies as
select variable, v_id, c_id, s_id, chanel as s_ch, sensor
from variables_companies
join sensors
using (c_id)
;
-- check it out: select * from variables_sensors_companies order by c_id, v_id, s_id ;

create view variables_sensors as 
select variable, v_id, s_id, s_ch, sensor
from variables_sensors_accesses
union
select variable, v_id, s_id, s_ch, sensor
from variables_sensors_branches
union
select variable, v_id, s_id, s_ch, sensor
from variables_sensors_companies
;
-- check it out: select * from variables_sensors order by v_id;

create view variables_estimations as
select variable, v_id, timestamp, sum(corrected)*factor as estimation
from variables_sensors
join measures
using(s_id, s_ch)
natural join variables_factors
group by v_id, variable, timestamp, factor
;

/*
-- check it out: 
select * from variables_estimations where date(timestamp)='2015-07-10' and extract(hour from timestamp) between 10 and 24 and v_id=8 order by timestamp ;
select * from variables_sensors where v_id=8; 
select * from measures where date(timestamp)='2015-07-10' and extract(hour from timestamp) between 10 and 24 and s_id=1 and s_ch=1 order by timestamp ; 
:
select v_id, variable, round(sum(estimation)) as estimation from variables_estimations where date(timestamp)='2015-07-10' and extract(hour from timestamp) between 10 and 24 group by v_id, variable order by estimation ;
*/

-- creando funciones para acceder a las mediciones 
-- por sensor y pares de sensores
-- function to access measurements by sensor to build complex queries using expression languand through php parsing
create or replace function measures_sensor(sensor character varying)
returns
table (s_ch int, "timestamp" timestamp, measure numeric)
as $$
  select s_ch, timestamp, corrected as measure
  from measures
  where 's_'||(s_id::character varying)=$1
$$
language sql
stable
;

-- función para saber la jornada correspondiente a la estimación de una variable (para jornadas que se extienden después de las 24hs)
create or replace function working_day(measure_time timestamp, v_id integer) --para saber la jornada laboral
returns date
as $$
  select 
  case when $1 >= (select date($1) + workday_start from urbix.bkn_variable where variable_id=$2) 
       then $1::date
       when $1::time < (select workday_start + (workday_duration||' hours')::interval from urbix.bkn_variable where variable_id=$2)
       then ($1 - '1 day'::interval)::date
       else null 
  end
$$
language sql
stable
;

/* ejemplos usando la función anterior y usando 'with' para definir un select local

with hours as (select '2015-01-01 '||generate_series(0,23,1)::text||':00' as hour)
select hour, working_day(hour::timestamp,1) as working_day
from hours;

select working_day(timestamp,v_id), sum(estimation) "ingresos totales por jornada"
from variables_estimations 
where v_id=1
group by working_day(timestamp,v_id)
order by working_day(timestamp,v_id)
;

select timestamp, measure as ingresos
from variables_estimations
where v_id=1 and working_day(timestamp,v_id)='2015-07-01'
order by timestamp
;
*/

-- función para mostrar y ordenar las horas
create or replace function working_hour_text(timestamp, v_id integer)
returns character varying
as $$
  select 
  case
    when $1::time >= (select workday_start from urbix.bkn_variable where variable_id=$2) 
      then '= '||substr($1::character varying,12,2)
    when $1::time < (select workday_start + (workday_duration||' hours')::interval from urbix.bkn_variable where variable_id=$2)
      then '> '||substr($1::character varying,12,2)
    when $1::time >= (select workday_start - '3 hours'::interval from urbix.bkn_variable where variable_id=$2)
      then '- '||substr($1::character varying,12,2)
    else
       'X '||substr($1::character varying,12,2)
  end
$$
language sql
stable
;

/* ejemplo

-- validación que la cantidad de horas sea 24 (que no haya horas espureas)
select working_hour_text(timestamp::time,v_id), avg(estimation) as "promedio de ingresos"
from variables_estimations
where v_id=1
group by working_hour_text(timestamp::time,v_id)
order by working_hour_text(timestamp::time,v_id)
;

-- buscar horas espureas
select timestamp, s_id, s_ch, status
from measures
where date_trunc('hour', timestamp) != timestamp
order by timestamp, s_id, s_ch 
;

*/


commit;

create or replace function working_time("timestamp" timestamp, v_id integer)
returns boolean
as $$
  select
  case
    when $1::time >= (select workday_start from urbix.bkn_variable where variable_id=$2)
      then true
    when $1::time < (select workday_start + (workday_duration||' hours')::interval from urbix.bkn_variable where variable_id=$2)
      then true
    when $1::time >= (select workday_start - '3 hours'::interval from urbix.bkn_variable where variable_id=$2)
      then false
    else
       false
  end
$$
language sql
stable
;

create view variables_estimations_by_day as
select v_id, sum(estimation) as estimation, 
  date, day, day_of_week, day_colour as day_color
from variables_estimations
join ftn_time_period
on working_day(timestamp, v_id)=date
where working_time(timestamp, v_id)
group by v_id, date, day, day_of_week, day_colour 
;
-- select * from variables_estimations_by_day limit 20;



