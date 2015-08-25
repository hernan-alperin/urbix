set search_path to herman, private; 

begin;
drop function if exists actualizar_factor_sensor(s_id integer, s_ch integer, factor_nuevo numeric, desde timestamp);
create or replace function actualizar_factor_sensor(s_id integer, s_ch integer, factor_nuevo numeric, desde timestamp)
-- s_id sensor_id
-- s_ch sensor chanel o type_code en geeral 1=in 2=out
returns 
 table (s_id integer, s_ch integer, factor numeric, start_date date, end_date date)
as $$
  update urbix.bkn_sensor_factor set end_date = $4 where sensor_id=$1 and type_code=$2 and end_date is null;
  insert into urbix.bkn_sensor_factor (sensor_id, type_code, factor_value, start_date, end_date) values ($1, $2, $3, $4, null);
  select sensor_id, type_code, factor_value, start_date, end_date from urbix.bkn_sensor_factor
$$
language sql
security definer
volatile
;
grant execute on function actualizar_factor_sensor(s_id integer, s_ch integer, factor_nuevo numeric, desde timestamp) to herman;
comment on function actualizar_factor_sensor(s_id integer, s_ch integer, factor_nuevo numeric, desde timestamp)
  is 'actualiza el factor para un sensor en un canal a partir de la fecha indicada';
commit;

/*  para recuperar un valor después de testear la función
update urbix.bkn_sensor_factor set end_date = null where factor_id=12;
delete from urbix.bkn_sensor_factor where factor_id > 30;
*/

begin;
drop function if exists leer_sensor(s_id integer, s_ch integer, "timestamp" timestamp);
create or replace function leer_sensor(s_id integer, s_ch integer, "timestamp" timestamp)
-- s_id identificador del sensor ver vista sensors
-- s_ch typecode identificador del canal del sensor
-- timestamp momento de lectura del sensor
returns numeric
as $$
  select corrected 
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
  is 'calcula la medición de un sensor para un momento dado. devuelve un número';
commit;

begin;
drop function if exists leer_sensor(s_id integer, fecha date);
create or replace function leer_sensor(s_id integer, fecha date)
-- s_id identificador del sensor ver vista sensors
-- devuelve todos los canales
-- fecha para la lectura del sensor, usa jornada laboral
returns table(s_ch integer, "timestamp" timestamp, lectura numeric)
as $$
  select s_ch, timestamp, corrected
  from private.meassures
  where s_id=$1 and private.working_day(timestamp,$1)=$2 -- todo: chequear que esté ajustado a jornada laboral
  order by s_ch, timestamp
$$
language sql
security definer
stable
;
grant execute on function leer_sensor(s_id integer, fecha date) to herman;
comment on function leer_sensor(s_id integer, fecha date)
  is 'lee el valor de un sensor para una fecha dada. devuelve una tabla con las mediciones de todos sus canales';
commit;

begin;
drop function if exists leer_sensor(s_id integer, desde date, hasta date);
create or replace function leer_sensor(s_id integer, desde date, hasta date)
-- s_id identificador del sensor ver vista sensors
-- fechas desde y hasta para la lectura del sensor
returns table(s_ch integer, "timestamp" timestamp, lectura numeric)
as $$
  select s_ch, timestamp, corrected
  from private.meassures
  where s_id=$1 and private.working_day(timestamp,$1) between $2 and $3 -- todo: chequear que esté ajustado a jornada laboral
  order by s_ch, timestamp
$$
language sql
security definer
stable
;
grant execute on function leer_sensor(s_id integer, desde date, hasta date) to herman;
comment on function leer_sensor(s_id integer, desde date, hasta date)
  is 'calcula el valor de una sensor entre las fechas dadas. devuelve una tabla con las mediciones de todos sus canales';
commit;



begin;
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
grant execute on function calcular_variable(v_id integer, "timestamp" timestamp) to herman;
comment on function calcular_variable(v_id integer, "timestamp" timestamp)
  is 'calcula el valor de una variable para un momento dado. devuelve un número';
commit;

begin;
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
grant execute on function calcular_variable(v_id integer, fecha date) to herman;
comment on function calcular_variable(v_id integer, fecha date)
  is 'calcula el valor de una variable para una fecha dada. devuelve una tabla';
commit;

begin;
drop function if exists calcular_variable(v_id integer, desde date, hasta date);
create or replace function calcular_variable(v_id integer, desde date, hasta date)
-- v_id identificador de variable ver vista variables
-- fechas desde y hasta para el cálculo de la variable
returns table("timestamp" timestamp, calculo numeric)
as $$
  select timestamp, estimation
  from private.variables_estimations
  where v_id=$1 and private.working_day(timestamp,$1) between $2 and $3 -- todo: chequear que esté ajustado a jornada laboral
  order by timestamp
$$
language sql
security definer
stable
;
grant execute on function calcular_variable(v_id integer, desde date, hasta date) to herman;
comment on function calcular_variable(v_id integer, desde date, hasta date)
  is 'calcula el valor de una variable entre las fechas dadas. devuelve una tabla';
commit;

begin;
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
grant execute on function calcular_variable(v_id integer, fecha date) to herman;
comment on function calcular_variable(v_id integer, fecha date)
  is 'calcula el valor de una variable para una fecha dada. devuelve una tabla';
commit;
                                     



