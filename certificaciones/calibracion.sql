drop schema calibracion cascade;
create schema calibracion;

CREATE OR REPLACE FUNCTION array_median(numeric[])
  RETURNS numeric AS
$$
    SELECT CASE WHEN array_upper($1,1) = 0 THEN null ELSE asorted[ceiling(array_upper(asorted,1)/2.0)] END
    FROM (SELECT ARRAY(SELECT ($1)[n] FROM generate_series(1, array_upper($1, 1)) AS n
    WHERE ($1)[n] IS NOT NULL
    ORDER BY ($1)[n]
) As asorted) As foo ;
$$
  LANGUAGE 'sql' IMMUTABLE;

CREATE AGGREGATE median(numeric) (
      SFUNC=array_append,
      STYPE=numeric[],
      FINALFUNC=array_median
    );

-- subsample around s_i of size k
create or replace function subsample_i(s_id integer, s_ch integer, s_i numeric, k integer)
returns table(s_j numeric, p_j numeric)
as $$
select s_i as s_j, p_i as p_j
from certificaciones.sample
order by abs($3 - s_i)
limit $4
$$
language sql
;

create or replace function subsample_i_with_0(s_id integer, s_ch integer, s_i numeric, k integer)
returns table(s_j numeric, p_j numeric)
as $$
select * from subsample_i($1, $2, $3, $4)
union
select 0,0
$$
language sql
;

create or replace function quotient_average(s_id integer, s_ch integer) -- es el que se usa ahora: cociente de medias
returns numeric as $$
select avg(p_i)/avg(s_i) as q_a
from certificaciones.sample
where s_id = $1 and s_ch = $2
$$ language sql
;

create or replace function quotient_median(s_id integer, s_ch integer) -- cociente de medianas
returns numeric as $$
select median(p_i)/median(s_i) as q_m
from certificaciones.sample
where s_id = $1 and s_ch = $2
$$ language sql
;

create or replace function average_quotients(s_id integer, s_ch integer) -- media de cocientes
returns numeric as $$
select avg(p_i/s_i) as a_q
from certificaciones.sample
where s_id = $1 and s_ch = $2 and s_i != 0
$$ language sql
;

create or replace function median_quotients(s_id integer, s_ch integer) -- mediana de cocientes
returns numeric as $$
select median(p_i/s_i) as a_m
from certificaciones.sample
where s_id = $1 and s_ch = $2 and s_i != 0
$$ language sql
;

create or replace function moving_average(s_id integer, s_ch integer, s_i numeric, k integer) -- moving average, media movil de tamaño k
returns numeric
as $$
select avg(p_j)/avg(s_j) as b from subsample_i_with_0($1, $2, $3, $4)
$$
language sql
;

