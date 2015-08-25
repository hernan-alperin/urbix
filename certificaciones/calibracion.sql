create table curva_de_calibracion as
with delta as (select 1 as delta)
select 
  sensor/60 as q_s,   
  round(-(sensor+delta-sensor)/(manual-delta),2) up,
  round(-(manual-sensor)/manual,2) as relerr,
  round(-(manual-delta-sensor)/(manual-delta),2) down
from sampling, delta
where s_ch=2
order by q_s
;

drop function calibrate(numeric);
create function calibrate(numeric)
returns character varying
as $$
with borders as (select min(q_s) as min, max(q_s) as max from curva_de_calibracion)
select 
  case
    when $1/60 < least(0.5,min) then 'zero' -- q < q_min
    when $1/60 < min then 'interpolo a zero'
    when $1/60 < max then 'promedio movil'
    else 'extrapolo'
  end
from borders
$$
language sql
;

drop function lower(integer, numeric);
create function lower(integer, numeric)
returns setof numeric
as $$
select sensor
from sampling
where sensor <= $2
order by sensor desc
limit $1
$$
language sql
;

select lower(3,100);



---
create function moving_average(numeric)
returns numeric
as $$
  select avg(medicion)
  from sampling
  where medicion
$$
language sql
;

