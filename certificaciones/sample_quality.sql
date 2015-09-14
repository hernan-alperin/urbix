drop schema certificaciones cascade;
create schema certificaciones;
set search_path to certificaciones, private, urbix;
grant usage on schema certificaciones to herman;
grant usage on schema certificaciones to cristian;
grant execute on all functions in schema certificaciones to herman;
grant execute on all functions in schema certificaciones to cristian;

-- mover tablas de vistas de cristian a schema certificaciones
create or replace view sampling as
select id, s_id, 1 as s_ch, fecha + hora as timestamp, intervalo*60 as minutos, sensor_in as sensor, manual_in as manual
from cristian.mediciones_sensor
union
select id, s_id, 2 as s_ch, fecha + hora as timestamp, intervalo*60, sensor_out as sensor, manual_out as manual
from cristian.mediciones_sensor
union
select id, s_id, 1 as s_ch, fecha + hora as timestamp, intervalo*60, sensor, manual
from cristian.mediciones_urbixcam
;

create or replace view sample as
select id, s_id, s_ch, sensors.sensor,
  sampling.sensor/extract('minutes' from minutos)::numeric as s_i, manual/extract('minutes' from minutos)::numeric as p_i
from sampling
join private.sensors
using (s_id)
;
grant select on sample to herman;

create or replace function round(double precision, integer) returns numeric 
as $$ select round($1::numeric, $2) $$ immutable language sql;

create or replace function floor(numeric, numeric, integer) returns numeric 
as $$ select round($2*floor($1/$2),$3) $$ immutable language sql;

create or replace function ceil(numeric, numeric, integer) returns numeric 
as $$ select round($2*ceil($1/$2),$3) $$ immutable language sql;

drop view if exists sample_inside_quality;
create or replace view sample_inside_quality as
with params as (select 1/10::numeric as grain)
select s_id, s_ch, count(*) as size
  , floor(min(s_i), grain, 1) as bottom, ceil(max(s_i), grain, 1) as top 
  , ceil(max(s_i), grain, 1) - floor(min(s_i), grain, 1) as width
from sample
natural join params
group by s_id, s_ch, grain
order by s_id, s_ch
;
--select * from sample_inside_quality;

create or replace function under(numeric, numeric) returns numeric
as $$ select case when $1 < $2 then $2 - $1 else null end $$ immutable language sql;

create or replace function over(numeric, numeric) returns numeric
as $$ select under($2,$1) $$ immutable language sql;

create or replace function inside(numeric, numeric, numeric) returns numeric
as $$ select case when $2 < $1 and $1 < $3 then least($1 - $2, $3 - $1) else null end $$ immutable language sql;

drop view if exists sample_representativeness;
create or replace view sample_representativeness as
with params as (select 60 as minutes)
select s_id, s_ch
  , round(count(under(value/minutes, bottom))/count(*)::numeric*100) as under
  , round(count(inside(value/minutes, bottom, top))/count(*)::numeric*100) as inside
  , round(count(over(value/minutes, top))/count(*)::numeric*100) as over
from sample_inside_quality
natural join measures
natural join params
where original > 3/60
group by s_id, s_ch, minutes
order by s_id, s_ch
;
--select * from sample_representativeness;

drop view if exists sample_quality;
create or replace view sample_quality as
select *, 
  case 
    when (sample_inside_quality.size < 16 or sample_representativeness.over > 20 or sample_representativeness.under > 30) 
      then 
        case 
          when (sample_inside_quality.size < 16) then ('faltan '||16 - size||' mediciones')
          else ('faltan mediciones')
        end
    when (sample_representativeness.over > 20 and sample_representativeness.under > 30) 
      then (' con caudales por arriba de '||top||' y por abajo de '||bottom||' personas por minuto.')
    when (sample_representativeness.over > 20) then (' con caudales por arriba de '||top||' personas por minuto.') 
    when (sample_representativeness.under > 30) then (' con caudales por abajo de '||bottom||' personas por minuto.')
    else 'ok'
  end as certificado
from sample_inside_quality
natural join sample_representativeness
;
grant select on sample_quality to herman;
grant select on sample_quality to cristian;
comment on view sample_quality is 'medidas de calidad de la muestra';
comment on column sample_quality.size is 'tamaño de la muestra';


--select * from sample_quality;
