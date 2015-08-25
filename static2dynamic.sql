-- distributio dow

select day, count(distinct date(time)) as cantidad_dias_por_dia_de_semana
  from 
bkn_variable join bkn_result using (variable_id) join ftn_time_period on date(bkn_result.time) = ftn_time_period.date
  where 
 bkn_variable.variable_id = 51  and  date(time) between date('2015/06/01') and date('2015/08/16')
 
    and  extract(hour from time) between extract(hour from workday_start) and extract(hour from workday_start) + workday_duration
  group by day, workday_duration, day_of_week, day_colour
  order by day_of_week
;


select day, count(distinct ftn_time_period.date) as cantidad_dias_por_dia_de_semana
from
variables_estimations
join ftn_time_period
on working_day(timestamp, 51) = ftn_time_period.date 
where v_id = 51 and ftn_time_period.date between date('2015/06/01') and date('2015/08/16')
group by day, day_of_week
order by day_of_week
;


----

select day, round(sum(data)) as totales_por_dia_de_semana, day_colour
  from 
bkn_variable join bkn_result using (variable_id) join ftn_time_period on date(bkn_result.time) = ftn_time_period.date
  where 
 bkn_variable.variable_id = 51  and  date(time) between date('2015/08/01') and date('2015/08/07')
 
    and  extract(hour from time) between extract(hour from workday_start) and extract(hour from workday_start) + workday_duration 
-- aca hay un bug hour<24 pero 10+16 da 26...
  group by day, workday_duration, day_of_week, day_colour
  order by day_of_week

;

select day, round(sum(estimation)) as totales_por_dia_de_semana
from
variables_estimations
join ftn_time_period
on working_day(timestamp, 51) = ftn_time_period.date
where v_id = 51 and ftn_time_period.date between date('2015/08/01') and date('2015/08/07')
group by day, day_of_week
order by day_of_week
;


select timestamp, data, estimation
from bkn_result
join variables_estimations
on time = timestamp and v_id=variable_id
where data!=estimation and v_id=51 and variable_id=51
order by timestamp desc
limit 20
;




