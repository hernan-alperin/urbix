-- si es la primera vez que se corre se crean, si no da error ... por eso fuera del begin-commit
create schema backup;  
create schema authorization cristian;
drop table cristian.log;
create table cristian.variables_corregidas (
  v_id integer,
  timestamp timestamp,
  original_value numeric,
  new_value numeric,
  when_modified timestamp,
  who_modified character varying,
  observaciones character varying
);
grant select on cristian.variables_corregidas to cristian; 
comment on table cristian.variables_corregidas 
  is 'tabla con las correcciones de las variables, imputación de datos cuando el valor calculado no es confiable';
create table cristian.mediciones_corregidas (
  s_id integer,
  s_ch integer,
  timestamp timestamp,
  original_value numeric,
  new_value numeric,
  when_modified timestamp,
  who_modified character varying,
  observaciones character varying
);
grant select on cristian.mediciones_corregidas to cristian;
comment on table cristian.mediciones_corregidas
  is 'tabla con las correcciones de las mediciones de los sensores, imputación de datos cuando la medición no fue confiable';
create table cristian.mediciones_sensor(
    id serial,
    s_id integer,
    fecha date,
    hora time with time zone,
    intervalo interval,
    sensor_in numeric,
    sensor_out numeric,
    manual_in numeric,
    manual_out numeric
);
alter table cristian.mediciones_sensor owner to cristian;
create table cristian.mediciones_urbixcam(
    id serial,
    s_id integer,
    fecha date,
    hora time with time zone,
    intervalo interval,
    sensor numeric,
    manual numeric
);
alter table cristian.mediciones_urbixcam owner to cristian;
create table cristian.mediciones_accesos (
    id serial,
    a_id integer,
    fecha date,
    hora time with time zone,
    intervalo interval,
    sensor_uno_in numeric,
    sensor_uno_out numeric,
    sensor_dos_in numeric,
    sensor_dos_out numeric,
    manual_in numeric,
    manual_out numeric
);
alter table cristian.mediciones_accesos owner to cristian;
----
create table backup.mediciones_sensor as select * from cristian.mediciones_sensor;
create table backup.mediciones_urbixcam as select * from cristian.mediciones_urbixcam;
create table backup.mediciones_accesos as select * from cristian.mediciones_accesos;
create table backup.variables_fixed as select * from cristian.variables_corregidas;
create table backup.measures_fixed as select * from cristian.mediciones_corregidas;
---- evitar repeticiones backup incremental
insert into backup.mediciones_sensor select * from cristian.mediciones_sensor except select * from backup.mediciones_sensor;
insert into backup.mediciones_urbixcam select * from cristian.mediciones_urbixcam except select * from backup.mediciones_urbixcam;
insert into backup.measures_fixed select * from cristian.mediciones_corregidas except select * from backup.measures_fixed;
insert into backup.variables_fixed select * from cristian.variables_corregidas except select * from backup.variables_fixed;
----
begin;
set search_path to cristian, private;

comment on schema cristian is 'schema para acceso de las necesidades del usuario cristian';
set search_path to cristian, private;

drop view if exists cristian.meassures cascade;
drop view if exists cristian.measures cascade;
drop view if exists cristian.sensors cascade;
drop view if exists cristian.sensors_factors cascade;
drop view if exists cristian.variables cascade;
drop view if exists cristian.variables_factors cascade;
drop view if exists cristian.variables_estimations cascade;
drop view if exists cristian.variables_accesses;

create view cristian.measures as 
select measures.s_id, sensor, measures.s_ch, measures.status, measures.timestamp, 
  measures.original, measures.value, measures.corrected
from private.measures
natural join private.sensors;
create view cristian.sensors as select * from private.sensors;
create view cristian.sensors_factors as select * from private.sensors_factors;
create view cristian.variables as select * from private.variables;
create view cristian.variables_factors as select * from private.variables_factors;
create view cristian.variables_estimations as select * from private.variables_estimations;
create view cristian.variables_accesses as select * from private.variables_accesses;

grant select on cristian.measures to cristian;
grant select on cristian.sensors to cristian;
grant select on cristian.sensors_factors to cristian;
grant select on cristian.variables to cristian;
grant select on cristian.variables_factors to cristian;
grant select on cristian.variables_estimations to cristian;
grant select on cristian.variables_accesses to cristian;

drop function if exists leer_sensor(s_id integer, s_ch integer, "timestamp" timestamp);
create or replace function leer_sensor(s_id integer, s_ch integer, "timestamp" timestamp)
-- s_id identificador del sensor ver vista sensors
-- s_ch typecode identificador del canal del sensor
-- timestamp momento de lectura del sensor
returns record 
as $$
  select original, value, corrected
  from private.measures
  where s_id=$1 and s_ch=$2 and "timestamp"=$3::timestamp
$$
language sql
security definer
stable
;
grant execute on function leer_sensor(s_id integer, s_ch integer, "timestamp" timestamp) to herman;
grant execute on function leer_sensor(s_id integer, s_ch integer, "timestamp" timestamp) to cristian;
comment on function leer_sensor(s_id integer, s_ch integer, "timestamp" timestamp)
  is 'calcula la medición de un sensor para un momento dado. devuelve un rgistro con valores original, value de sistema y dynamically corrected';

drop function if exists leer_sensor(s_id integer, fecha date);
create or replace function leer_sensor(s_id integer, fecha date)
-- s_id identificador del sensor ver vista sensors
-- devuelve todos los canales
-- fecha para la lectura del sensor, usa jornada laboral
returns table(s_ch integer, "timestamp" timestamp, original numeric, value numeric, corrected numeric)
as $$
  select s_ch, timestamp, original, value, corrected
  from private.measures
  where s_id=$1 and private.working_day(timestamp,$1)=$2 
  order by s_ch, timestamp
$$
language sql
security definer
stable
;
grant execute on function leer_sensor(s_id integer, fecha date) to cristian;
comment on function leer_sensor(s_id integer, fecha date)
  is 'lee el valor de un sensor para una fecha dada. devuelve una tabla con las mediciones de todos sus canales';

drop function if exists leer_sensor(s_id integer, desde date, hasta date);
create or replace function leer_sensor(s_id integer, desde date, hasta date)
-- s_id identificador del sensor ver vista sensors
-- fechas desde y hasta para la lectura del sensor
returns table(s_ch integer, "timestamp" timestamp, original numeric, value numeric, corrected numeric)
as $$
  select s_ch, timestamp, original, value, corrected
  from private.measures
  where s_id=$1 and private.working_day(timestamp,$1) between $2 and $3 -- todo: chequear que esté ajustado a jornada laboral
  order by s_ch, timestamp
$$
language sql
security definer
stable
;
grant execute on function leer_sensor(s_id integer, desde date, hasta date) to cristian;
comment on function leer_sensor(s_id integer, desde date, hasta date)
  is 'calcula el valor de una sensor entre las fechas dadas. devuelve una tabla con las mediciones de todos sus canales';

drop function if exists calcular_variable(v_id integer, "timestamp" timestamp);
create or replace function calcular_variable(v_id integer, "timestamp" timestamp)
-- v_id identificador de variable ver vista variables
-- timestamp momento de cálculo de la variable
returns numeric
as $$
  select estimation
  from private.variables_estimations
  where v_id=$1 and "timestamp"=$2::timestamp
$$
language sql
security definer
stable
;
grant execute on function calcular_variable(v_id integer, "timestamp" timestamp) to cristian;
comment on function calcular_variable(v_id integer, "timestamp" timestamp)
  is 'calcula el valor de una variable para un momento dado. devuelve un número';

drop function if exists calcular_variable(v_id integer, fecha date);
create or replace function calcular_variable(v_id integer, fecha date)
-- v_id identificador de variable ver vista variables
-- fecha para el cálculo de la variable, usa jornada laboral
returns table("timestamp" timestamp, calculo numeric)
as $$
  select timestamp, estimation
  from private.variables_estimations
  where v_id=$1 and private.working_day(timestamp,$1)=$2 -- todo: chequear que esté ajustado a jornada laboral
  order by timestamp
$$
language sql
security definer
stable
;
grant execute on function calcular_variable(v_id integer, fecha date) to cristian;
comment on function calcular_variable(v_id integer, fecha date)
  is 'calcula el valor de una variable para una fecha dada. devuelve una tabla';

drop function if exists imputar_variable(v_id integer, "timestamp" timestamp, valor numeric);
drop function if exists fijar_variable(v_id integer, "timestamp" timestamp, valor numeric);
drop function if exists fijar_variable(v_id integer, "timestamp" timestamp, valor numeric, observacion character varying);
create or replace function fijar_variable(v_id integer, "timestamp" timestamp, valor numeric, observacion character varying)
returns table (
  v_id integer,
  "timestamp" timestamp,
  original_value numeric,
  new_value numeric,
  when_modified timestamp,
  who_modified character varying,
  observaciones character varying
)
as $$
  insert into cristian.variables_corregidas
  select $1, $2, estimation, $3, now(), 'cristian', $4
  from private.variables_estimations
  where v_id=$1 and timestamp=$2;
  select * from cristian.variables_corregidas order by when_modified desc
$$
volatile language sql
security definer
;
grant execute on function fijar_variable(v_id integer, "timestamp" timestamp, valor numeric, observacion character varying) to cristian;
comment on function fijar_variable(v_id integer, "timestamp" timestamp, valor numeric, observacion character varying)
  is 'corrige o imputa el valor de una variable para un timestamp dado';

create view private.corrected_variables_estimations as
select variable, v_id, timestamp
  , case when new_value is null then estimation else new_value end as estimation
from private.variables_estimations
natural full join cristian.variables_corregidas
;

drop function if exists fijar_medicion(s_id integer, s_ch integer, "timestamp" timestamp, valor numeric);
drop function if exists fijar_medicion(s_id integer, s_ch integer, "timestamp" timestamp, valor numeric, observacion character varying);
create or replace function fijar_medicion(s_id integer, s_ch integer, "timestamp" timestamp, valor numeric, observacion character varying)
returns table (
  s_id integer,
  s_ch integer,
  "timestamp" timestamp,
  original_value numeric,
  new_value numeric,
  when_modified timestamp,
  who_modified character varying,
  observaciones character varying
)
as $$
  insert into cristian.mediciones_corregidas
  select $1, $2, $3, value, $4, now(), 'cristian', $4
  from private.measures
  where s_id=$1 and s_ch = $2 and timestamp=$3;
  select * from cristian.mediciones_corregidas order by when_modified desc
$$
volatile language sql
security definer
;
grant execute on function fijar_medicion(s_id integer, s_ch integer, "timestamp" timestamp, valor numeric, observacion character varying) to cristian;
comment on function fijar_medicion(s_id integer, s_ch integer, "timestamp" timestamp, valor numeric, observacion character varying)
  is 'corrige o imputa el valor de una medicion para un timestamp dado';
commit;

create view private.corrected_measures as
select  timestamp, s_id, s_ch, original
  , case when new_value is null then corrected else new_value end as corrected
from measures
natural full join cristian.mediciones_corregidas
;


