-- si es la primera vez que se corre se crean, si no da error ... por eso fuera del begin-commit
create schema backup;  
create schema authorization cristian;
create table cristian.log (
  "table" character varying,
  modified timestamp,
  id bigint,
  original numeric
);
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
---- evitar repeticiones
insert into backup.mediciones_sensor select * from cristian.mediciones_sensor except select * from backup.mediciones_sensor;
insert into backup.mediciones_urbixcam select * from cristian.mediciones_urbixcam except select * from backup.mediciones_urbixcam;
----
begin;
set search_path to cristian, private;

comment on schema cristian is 'schema para acceso de las necesidades del usuario cristian';
set search_path to cristian, private;

drop view if exists cristian.meassures cascade;
drop view if exists cristian.sensors cascade;
drop view if exists cristian.sensors_factors cascade;
drop view if exists cristian.variables_factors cascade;
drop view if exists cristian.variables_estimations cascade;

create view cristian.meassures as 
select meassures.s_id, sensor, meassures.s_ch, meassures.status, meassures.timestamp, 
  meassures.original, meassures.value, meassures.corrected
from private.meassures
natural join private.sensors;
create view cristian.sensors as select * from private.sensors;
create view cristian.sensors_factors as select * from private.sensors_factors;
create view cristian.variables as select * from private.variables;
create view cristian.variables_factors as select * from private.variables_factors;
create view cristian.variables_estimations as select * from private.variables_estimations;
create view cristian.variables_accesses as select * from private.variables_accesses;

grant select on cristian.meassures to cristian;
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
  from private.meassures
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
  from private.meassures
  where s_id=$1 and private.working_day(timestamp,$1)=$2 -- todo: chequear que esté ajustado a jornada laboral
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
  from private.meassures
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
create or replace function imputar_variable(v_id integer, "timestamp" timestamp, valor numeric)
returns void
as $$
declare
  result_id bigint;
begin
  select result_id into result_id
  from urbix.bkn_result
  where variable_id=$1 and time=$2; 
  return;
end;
$$
language plpgsql
security definer
;
grant execute on function imputar_variable(v_id integer, "timestamp" timestamp, valor numeric) to cristian;
comment on function imputar_variable(v_id integer, "timestamp" timestamp, valor numeric)
  is 'calcula el valor de una variable para una fecha dada. devuelve una tabla';


commit;

