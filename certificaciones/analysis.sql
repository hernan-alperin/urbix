create schema testing;
grant all on schema testing to herman;
set search_path to testing, public, calibracion, certificaciones;


create table methods (name character varying);
copy methods from stdin;
'quotient of averages'
'quotient of medians'
'average of quotients'
'median of quotients'
\.

create table k_s as
select generate_series(3,8,1)
union
select null
;

create view for_testing as
select * 
from methods, k_s
;

create or replace function subsample_without_i(s_id integer, s_ch integer, id integer, s_i numeric, k integer)
returns table(s_j numeric, p_j numeric)
as $$
select s_i as s_j, p_i as p_j
from certificaciones.sample
where id != $3
and s_id = $1 and s_ch = $2
order by abs($4 - s_i)
limit $5
$$
language sql
;

drop table errors cascade;
create table errors (s_id integer, s_ch integer, id integer,
  method character varying, k integer, error numeric);
grant select on errors to herman;

create or replace function quotient_averages(s_id integer, s_ch integer, id integer) --  como se hace ahora
returns numeric as $$
select avg(p_i)/avg(s_i) as b from certificaciones.sample where id != $3 and s_id = $1 and s_ch = $2
$$ language sql ;

create or replace function moving_quotient_averages(s_id integer, s_ch integer, id integer, s_i numeric, k integer) -- moving average, media movil de tamaño k
returns numeric as $$
select avg(p_j)/avg(s_j) as b from subsample_without_i($1, $2, $3, $4, $5)
$$ language sql ;

insert into errors select s_id, s_ch, id, 
  'moving_quotient_averages', 3, p_i/s_i - moving_quotient_averages(s_id, s_ch, id, s_i, 3)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'moving_quotient_averages', 4, p_i/s_i - moving_quotient_averages(s_id, s_ch, id, s_i, 4)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'moving_quotient_averages', 5, p_i/s_i - moving_quotient_averages(s_id, s_ch, id, s_i, 5)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'moving_quotient_averages', 6, p_i/s_i - moving_quotient_averages(s_id, s_ch, id, s_i, 6)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'moving_quotient_averages', 7, p_i/s_i - moving_quotient_averages(s_id, s_ch, id, s_i, 7)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'moving_quotient_averages', 8, p_i/s_i - moving_quotient_averages(s_id, s_ch, id, s_i, 8)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'quotient_averages', null, p_i/s_i - quotient_averages(s_id, s_ch, id)
from certificaciones.sample ;

create or replace function quotient_medians(s_id integer, s_ch integer, id integer) --  con medianas en vez de averages
returns numeric as $$
select median(p_i)/median(s_i) as b from certificaciones.sample where id != $3 and s_id = $1 and s_ch = $2
$$ language sql ;

create or replace function moving_quotient_medians(s_id integer, s_ch integer, id integer, s_i numeric, k integer) -- moving median, mediana movil de tamaño k
returns numeric as $$
select median(p_j)/median(s_j) as b from subsample_without_i($1, $2, $3, $4, $5)
$$ language sql ;

insert into errors select s_id, s_ch, id, 
  'moving_quotient_medians', 3, p_i/s_i - moving_quotient_medians(s_id, s_ch, id, s_i, 3)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'moving_quotient_medians', 4, p_i/s_i - moving_quotient_medians(s_id, s_ch, id, s_i, 4)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'moving_quotient_medians', 5, p_i/s_i - moving_quotient_medians(s_id, s_ch, id, s_i, 5)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'moving_quotient_medians', 6, p_i/s_i - moving_quotient_medians(s_id, s_ch, id, s_i, 6)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'moving_quotient_medians', 7, p_i/s_i - moving_quotient_medians(s_id, s_ch, id, s_i, 7)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'moving_quotient_medians', 8, p_i/s_i - moving_quotient_medians(s_id, s_ch, id, s_i, 8)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'quotient_medians', null, p_i/s_i - quotient_medians(s_id, s_ch, id)
from certificaciones.sample ;

create or replace function average_quotients(s_id integer, s_ch integer, id integer) --  como se hace ahora
returns numeric as $$
select avg(p_i/s_i) as b from certificaciones.sample where id != $3 and s_id = $1 and s_ch = $2
$$ language sql ;

create or replace function moving_average_quotients(s_id integer, s_ch integer, id integer, s_i numeric, k integer) -- moving average, media movil de tamaño k
returns numeric as $$
select avg(p_j/s_j) as b from subsample_without_i($1, $2, $3, $4, $5)
$$ language sql ;

insert into errors select s_id, s_ch, id, 
  'moving_average_quotients', 3, p_i/s_i - moving_average_quotients(s_id, s_ch, id, s_i, 3)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'moving_average_quotients', 4, p_i/s_i - moving_average_quotients(s_id, s_ch, id, s_i, 4)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'moving_average_quotients', 5, p_i/s_i - moving_average_quotients(s_id, s_ch, id, s_i, 5)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'moving_average_quotients', 6, p_i/s_i - moving_average_quotients(s_id, s_ch, id, s_i, 6)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'moving_average_quotients', 7, p_i/s_i - moving_average_quotients(s_id, s_ch, id, s_i, 7)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'moving_average_quotients', 8, p_i/s_i - moving_average_quotients(s_id, s_ch, id, s_i, 8)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'average_quotients', null, p_i/s_i - average_quotients(s_id, s_ch, id)
from certificaciones.sample ;

create or replace function median_quotients(s_id integer, s_ch integer, id integer) --  con medianas en vez de averages
returns numeric as $$
select median(p_i/s_i) as b from certificaciones.sample where id != $3 and s_id = $1 and s_ch = $2
$$ language sql ;

create or replace function moving_median_quotients(s_id integer, s_ch integer, id integer, s_i numeric, k integer) -- moving median, mediana movil de tamaño k
returns numeric as $$
select median(p_j/s_j) as b from subsample_without_i($1, $2, $3, $4, $5)
$$ language sql ;

insert into errors select s_id, s_ch, id, 
  'moving_median_quotients', 3, p_i/s_i - moving_median_quotients(s_id, s_ch, id, s_i, 3)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'moving_median_quotients', 4, p_i/s_i - moving_median_quotients(s_id, s_ch, id, s_i, 4)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'moving_median_quotients', 5, p_i/s_i - moving_median_quotients(s_id, s_ch, id, s_i, 5)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'moving_median_quotients', 6, p_i/s_i - moving_median_quotients(s_id, s_ch, id, s_i, 6)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'moving_median_quotients', 7, p_i/s_i - moving_median_quotients(s_id, s_ch, id, s_i, 7)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'moving_median_quotients', 8, p_i/s_i - moving_median_quotients(s_id, s_ch, id, s_i, 8)
from certificaciones.sample ;
insert into errors select s_id, s_ch, id, 
  'median_quotients', null, p_i/s_i - median_quotients(s_id, s_ch, id)
from certificaciones.sample ;


create view errors_sumed as
select s_id, s_ch, method, k
  , round(sum(abs(error)),3)/(count(*)-1) as e_1, round(sqrt(sum(error^2)),3)/(count(*)-1) as e_2, round(max(abs(error)),3) as e_inf
from errors
group by s_id, s_ch, method, k
order by s_id, s_ch, e_1
;
comment on view errors_sumed is 'estimadores de normas de errores relativos calculando el error de cada elemento de la muestra usando la submuestra que excluye ese elemento';
comment on column  errors_sumed.e_1 is 'norma 1 : promedio muestral (dividido por n-1) de los módulos o valores absolutos de los errores';
comment on column errors_sumed.e_2 is 'norma 2 : promedio muestral de la raiz cuadrada de la suma de los cuadrados de los errores';
comment on column errors_sumed.e_inf is 'norma inf : el máximo de los módulos o valores absolutos de los errores';
grant select on errors_sumed to herman;

select s_id, s_ch, method, k, e_1
from errors_sumed
natural join 
 (select s_id, s_ch, min(e_1) as best 
  from errors_sumed
  group by s_id, s_ch) as bests
where e_1 = best
order by s_id, s_ch
;

 



