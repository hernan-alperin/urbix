begin;
drop schema if exists private cascade;
create schema private;
set search_path to private, public, urbix;

-- view meassures para tener acceso dinámico a las mediciones.
drop view if exists meassures cascade; 
create view meassures as
select sensor_id as s_id, type_code as s_ch, status, 
  measure_time as timestamp, original_value as original, value, original_value*factor_value as corrected
from bkn_measure 
natural join bkn_measure_data
join bkn_sensor_factor
using (sensor_id, type_code)
where measure_time between start_date and end_date 
or start_date <= measure_time and end_date is null
;
comment on view meassures is 'vista armada por joins de las mediciones de los sensores del sistema';
comment on column meassures.s_id is 'sensor_id';
comment on column meassures.s_ch is 'canal del sensor: el campo ''type_code'' de ''bkn_measure_data''';
comment on column meassures.status is 'estado del sensor: 0 ok, 1 sin conectividad, 2 (?), 3 (?), 4 cuenta por debajo delo real. ver documentadión';
comment on column meassures.timestamp is 'hora en que se inició la medición';
comment on column meassures.original is 'conteo original del sensor';
comment on column meassures.value is 'valor corregido por el sistema estático usando formula_engine()';
comment on column meassures.corrected is 'volor corregido dinámicamente. para ser usado en el modelo dinámico';
-- ejemplo: select * from meassures where date(timestamp)='2015-06-22' order by timestamp, s_id, s_ch ;

drop view if exists sensors cascade;
create view sensors as
select sensor_id as s_id, 'sin descripción'::character varying as sensor, access_code as a_id, branch_code as b_id, organization_code as c_id
from bkn_sensor
;
comment on view sensors is 'vista armada para acceso sencillo y significativo a los sensores del sistema';
comment on column sensors.s_id is 'sensor_id';
comment on column sensors.sensor is 'descripción del sensor. campo ''description'' de la tabla ''bkn_sensor''';
comment on column sensors.a_id is 'código de acceso asociado o donde está ubicado el snsor. ''access_code'' de la tabla ''bkn_sensor''';
comment on column sensors.b_id is 'código del branch asociado al sensor. ''branch_code'' de la tabla ''bkn_sensor''';
comment on column sensors.c_id is 'código de la company u organization asociada al sensor. ''organization_code'' de la tabla ''bkn_sensor''';
-- check it out: select * from sensors order by s_id;

drop  view if exists sensors_factors cascade;
create view sensors_factors as
select sensor_id as s_id, --description as sensor, 
  type_code as s_ch, factor_value as factor,
  start_date, end_date, comment
from bkn_sensor
natural join bkn_sensor_factor
;
comment on view sensors_factors is 'vista armada para acceso sencillo y significativo a los factores usados para corregir las medixciones de los sensores del sistema con el registro temporal';
comment on column sensors_factors.s_id is 'sensor_id';
comment on column sensors_factors.s_ch is 'canal del sensor: el campo ''type_code'' de ''bkn_measure_data''';
comment on column sensors_factors.factor is 'factor de corrección de la medición del sensor. ''factor_value'' de la tabla ''bkn_sensor_factor''';
comment on column sensors_factors.start_date is 'inicio del período de validez del factor de corrección. igual campo de la tabla ''bkn_sensor_factor''';
comment on column sensors_factors.end_date is 'fin del período de validez del factor de corrección. igual campo de la tabla ''bkn_sensor_factor''';
comment on column sensors_factors.comment is 'comentario explicativo del por qué del factor o su modificación. igual campo de la tabla ''bkn_sensor_factor''';
-- check it out: select * from sensors_factors ;

drop view if exists variables cascade;
create view variables as
select variable_id as v_id, description as variable, public
from bkn_variable
;
comment on view variables is 'vista armada para acceso sencillo y significativo a los ids y a los nombres de las variables';
comment on column variables.v_id is 'integer indentificador de la variable: ''variable_id'' de la tabla ''bkn_variable''';
comment on column variables.variable is 'nombre de la variable. ''description'' de la tabla ''bkn_variable''';
comment on column variables.public is 'campo ''public'' de la tabla ''bkn_variable''. no está clara su función';
-- check it out: select * from variables ;

drop view if exists variables_formulas cascade;
create view variables_formulas as
select variables.*, active_formula_id, formula_id, bkn_formula.name as formula
from variables
full join bkn_active_formula
on v_id=variable_id
join bkn_formula
using (formula_id)
order by v_id
;
comment on view variables_formulas is 'relación entre las variables y las fórmulas que se usan para calcularlas';
-- check it out: select * from variables_formulas ;

drop view if exists variables_factors cascade;
create view variables_factors as
select v_id, active_formula_id, value::numeric as factor,
  start_date, end_date
from variables_formulas
natural join
bkn_active_formula
join bkn_active_formula_param
using (active_formula_id)
where formula_param_id % 100 = 0 -- param_id mod 0 (100) corresponde a factores
;
-- check it out: select * from variables_factors;

-- these views are for dealing with current model to search how variables connect to sensors using formulas
-- by access_code (now a_id)

drop view if exists variables_accesses cascade;
create view variables_accesses as
select v_id, variable, formula, value::integer as a_id, chanel
from variables_formulas
natural join (
  select *
  from bkn_active_formula_param
  where formula_param_id = 101
  ) as vars_with_access
join (
  select active_formula_id, active_formula_param_id as rec_id_way, value::int as chanel  from bkn_active_formula_param
  where formula_param_id = 102
) as chanel
using (active_formula_id)
where formula_id=1
;
-- check it out: select * from variables_accesses order by v_id ;

drop view if exists variables_sensors_accesses cascade;
create view variables_sensors_accesses as
select variable, v_id, a_id, s_id, chanel as s_ch, sensor
from variables_accesses
join sensors
using (a_id)
;
comment on view variables_sensors_accesses is 'relación entre las variables, los sensores y los accesos';
comment on column variables_sensors_accesses.a_id is 'identificador del acceso';
-- check it out: select * from variables_sensors_accesses order by v_id;

drop view if exists variables_branches cascade;
create view variables_branches as
select v_id, variable, formula, value::integer as b_id, chanel
from variables_formulas
join (
  select *
  from bkn_active_formula_param
  where formula_param_id = 201
  ) as vars_with_branch
using (active_formula_id)
join (
  select active_formula_id, active_formula_param_id as rec_id_way, value::int as chanel 
  from bkn_active_formula_param
  where formula_param_id = 202
) as chanel
using (active_formula_id)
where formula_id=2
;
-- check it out: select * from variables_branches ;

drop view if exists variables_sensors_branches cascade;
create view variables_sensors_branches as
select variable, v_id, b_id, s_id, chanel as s_ch, sensor
from variables_branches
join sensors
using (b_id)
;
comment on view variables_sensors_branches is 'relación entre las variables, los sensores y los branches/sucursales. en este caso usado para Mall';
comment on column variables_sensors_branches.b_id is 'identificador del branch/sucursal (Mall)';
-- check it out: select * from variables_sensors_branches order by s_id, v_id, b_id ;

drop view if exists variables_companies cascade;
create view variables_companies as
select v_id, variable, formula, value::integer as c_id, chanel
from variables_formulas
join (
  select *
  from bkn_active_formula_param
  where formula_param_id = 201
  ) as vars_with_branch
using (active_formula_id)
join (
  select active_formula_id, active_formula_param_id as rec_id_way, value::int as chanel from bkn_active_formula_param
  where formula_param_id = 202
) as chanel
using (active_formula_id)
where formula_id=13
;
-- check it out: select * from variables_companies ;

drop view if exists variables_sensors_companies cascade;
create view variables_sensors_companies as
select variable, v_id, c_id, s_id, chanel as s_ch, sensor
from variables_companies
join sensors
using (c_id)
;
comment on view variables_sensors_companies is 'relación entre las variables, los sensores y los companies/organization. en este caso usado para Predio';
comment on column variables_sensors_companies.c_id is 'identificador de la company (Predio)';
-- check it out: select * from variables_sensors_companies order by c_id, v_id, s_id ;

drop view if exists variables_sensors cascade;
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
comment on view variables_sensors is 'relación entre las variables y los sensores';
-- check it out: select * from variables_sensors order by v_id;

drop view if exists variables_estimations cascade;
create view variables_estimations as
select variable, v_id, timestamp, sum(corrected)*factor as estimation
from variables_sensors
join meassures
using(s_id, s_ch)
natural join variables_factors
group by v_id, variable, timestamp, factor
;
comment on view variables_estimations is 'estimaciones/cálculos dinámicos de las variables';

/*
-- check it out: 
select * from variables_estimations where date(timestamp)='2015-07-10' and extract(hour from timestamp) between 10 and 24 and v_id=8 order by timestamp ;
select * from variables_sensors where v_id=8; 
select * from meassures where date(timestamp)='2015-07-10' and extract(hour from timestamp) between 10 and 24 and s_id=1 and s_ch=1 order by timestamp ; 
:
select v_id, variable, round(sum(estimation)) as estimation from variables_estimations where date(timestamp)='2015-07-10' and extract(hour from timestamp) between 10 and 24 group by v_id, variable order by estimation ;
*/

-- creando funciones para acceder a las mediciones 
-- por sensor y pares de sensores
-- function to access meassurements by sensor to build complex queries using expression languand through php parsing
drop  function if exists meassures_sensor(sensor character varying) cascade;
create or replace function meassures_sensor(sensor character varying)
returns
table (s_ch int, "timestamp" timestamp, meassure numeric)
as $$
  select s_ch, timestamp, corrected as meassure
  from meassures
  where 's_'||(s_id::character varying)=$1
$$
language sql
stable
;

-- función para saber la jornada correspondiente a la estimación de una variable (para jornadas que se extienden después de las 24hs)
drop  function if exists working_day(meassure_time timestamp, v_id integer) cascade;
create or replace function working_day(meassure_time timestamp, v_id integer) --para saber la jornada laboral
returns date
as $$
  select 
  case when $1 >= (select date($1) + workday_start from bkn_variable where variable_id=$2) 
       then $1::date
       when $1::time < (select workday_start + (workday_duration||' hours')::interval from bkn_variable where variable_id=$2)
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

select timestamp, meassure as ingresos
from variables_estimations
where v_id=1 and working_day(timestamp,v_id)='2015-07-01'
order by timestamp
;
*/

-- función para mostrar y ordenar las horas
drop  function if exists working_hour_text(time, v_id integer) cascade;
create or replace function working_hour_text(time, v_id integer)
returns character varying
as $$
  select 
  case
    when $1 >= (select workday_start from bkn_variable where variable_id=$2) 
      then '= '||$1::character varying
    when $1 < (select workday_start + (workday_duration||' hours')::interval from bkn_variable where variable_id=$2)
      then '> '||$1::character varying
    when $1 >= (select workday_start - '3 hours'::interval from bkn_variable where variable_id=$2)
      then '- '||$1::character varying
    else
       'X '||$1::character varying
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
from meassures
where date_trunc('hour', timestamp) != timestamp
order by timestamp, s_id, s_ch 
;

*/


commit;





