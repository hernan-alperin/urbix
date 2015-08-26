drop view sampling;
create or replace view sampling as
select s_id, 1 as s_ch, fecha + hora as timestamp, intervalo*60 as minutos, sensor_in as sensor, manual_in as manual
from cristian.mediciones_sensor
union
select s_id, 2 as s_ch, fecha + hora as timestamp, intervalo*60, sensor_out as sensor, manual_out as manual
from cristian.mediciones_sensor
union
select s_id, 1 as s_ch, fecha + hora as timestamp, intervalo*60, sensor, manual
from cristian.mediciones_urbixcam
;

drop view sample;
create or replace view sample as
select s_id, s_ch, 
  sensor/extract('minutes' from minutos) as s_i, manual/extract('minutes' from minutos) as p_i
from sampling
;

select round(p_i) as q, avg((p_i-s_i)/p_i/s_i) as b_hat, stddev((p_i-s_i)/p_i/s_i) as b_hat_dev, count(*)
from sample
group by round(p_i)
order by round(p_i)
;

select round(p_i) as q, count(*),
  avg(1/(1/s_i-0.033)) as p_hat, avg(p_i - 1/(1/s_i-0.033)) as epsilon_hat 
from sample
group by round(p_i)
order by round(p_i)
;


-- media movil global
create or replace function subsample_i(s_i numeric, k integer)
returns table(s_j numeric, p_j numeric) 
as $$
select s_i::numeric as s_j, p_i::numeric as p_j
from (select s_i, p_i from sample union select 0, 0) as s_adding_0
order by abs($1 - s_i)
limit $2
$$
language sql
;
--select * from subsample_i(4,7);

-- media movil para sensor s_id
create or replace function subsample_i(s_id integer, s_ch integer, s_i numeric, k integer)
returns table(s_j numeric, p_j numeric)
as $$
select s_i::numeric as s_j, p_i::numeric as p_j
from (
  select s_i, p_i 
  from sample
  where s_id = $1 and s_ch = $2
  union select 0, 0
) as s_adding_0
order by abs($3 - s_i)
limit $4
$$
language sql
;
--select * from subsample_i(247,1,4,3);

-- actually done
create or replace view actually_done as
select s_i, p_i, a*s_i as p_i_hat, p_i - a*s_i as error_i
from sample, (
  select avg(p_i)/avg(s_i) as a 
  from sample
  where s_id = 247 and s_ch = 1) as avg
where s_id = 247 and s_ch = 1
order by s_i
;

select sum(abs(error_i)) from actually_done;

-- moving average
create or replace function moving_average(s_id integer, s_ch integer, s_i numeric, k integer)
returns numeric
as $$
select b*$3
from (select avg(p_j)/avg(s_j) as b from subsample_i($1, $2, $3, $4)) as subsample_i_k
$$
language sql
;


create function moving_average_k_error(s_id integer, s_ch integer, k integer)
returns table(error numeric)
as $$
with params as (select $1 as s_id, $2 as s_ch, $3 as k)
select 
  p_i::numeric - moving_average(s_id, s_ch, s_i::numeric, k) as error_i
from sample
natural join params
order by s_i
$$
language sql
;


select null as k, round(sum(abs(error_i))::numeric,3) as sum_e_1, round(sum(error_i^2)::numeric,3) as sum_e_2, round(max(abs(error_i))::numeric,3) as e_inf from actually_done
union
select 3, round(sum(abs(error)),3) as sum_e_1, round(sum(error^2),3) as sum_e_2, round(max(abs(error)),3) as e_inf from moving_average_k_error(247,1,3)
union
select 4, round(sum(abs(error)),3) as sum_e_1, round(sum(error^2),3) as sum_e_2, round(max(abs(error)),3) as e_inf from moving_average_k_error(247,1,4)
union
select 5, round(sum(abs(error)),3) as sum_e_1, round(sum(error^2),3) as sum_e_2, round(max(abs(error)),3) as e_inf from moving_average_k_error(247,1,5)
union
select 7, round(sum(abs(error)),3) as sum_e_1, round(sum(error^2),3) as sum_e_2, round(max(abs(error)),3) as e_inf from moving_average_k_error(247,1,7)
union
select 8, round(sum(abs(error)),3) as sum_e_1, round(sum(error^2),3) as sum_e_2, round(max(abs(error)),3) as e_inf from moving_average_k_error(247,1,8)
order by k
;

