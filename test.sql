select day, round(avg(data)*workday_duration) as totdias, day_colour 
from bkn_variable o, bkn_result m, ftn_time_period n 
where date( m.time) = n.date 
and m.variable_id = o.variable_id 
and m.variable_id = 10 
and date(m.time) between date('2015/04/19') and date('2015/05/04') 
and extract(hour from time) between extract(hour from workday_start) and extract(hour from workday_start) + workday_duration 
group by day, workday_duration, day_of_week, day_colour 
order by day_of_week
;

select day, round(avg(data)*workday_duration) as totdias, day_colour from bkn_variable o, bkn_result m, ftn_time_period n where date( m.time) = n.date and m.variable_id = o.variable_id and m.variable_id = 10 and date(m.time) between date('2015/04/19') and date('2015/05/04') and extract(hour from time) between extract(hour from workday_start) and extract(hour from workday_start) + workday_duration group by day, workday_duration, day_of_week, day_colour order by day_of_week
;



select distribucion_dias.day, round(totales_por_dia_de_semana/cantidad_dias_por_dia_de_semana) as totdias, day_colour
from (
  select day, count(distinct date(time)) as cantidad_dias_por_dia_de_semana
  from 
bkn_variable join bkn_result using (variable_id) join ftn_time_period on date(bkn_result.time) = ftn_time_period.date
  where 
 bkn_variable.variable_id = 51  and 
 time between (date('2015/06/29') + workday_start::time) 
      and (date('2015/06/29') + workday_start::time + (workday_duration || ' hours')::interval)
 
    and  time between (date(time) + workday_start::time) and (date(time) + workday_start::time + (workday_duration || ' hours')::interval)
--  group by day, workday_duration, day_of_week, day_colour
  order by day_of_week
) as totales_por_dia_de_la_semana 
natural right join (
  select day, round(sum(data)) as totales_por_dia_de_semana, day_colour
  from bkn_variable join bkn_result using (variable_id) join ftn_time_period on date(bkn_result.time) = ftn_time_period.date
  where 
 bkn_variable.variable_id = 51  and 
 time between (date('2015/06/29') + workday_start::time) 
      and (date('2015/06/29') + workday_start::time + (workday_duration || ' hours')::interval)
 
    and  time between (date(time) + workday_start::time) and (date(time) + workday_start::time + (workday_duration || ' hours')::interval) 
--  group by day, workday_duration, day_of_week, day_colour
  order by day_of_week
) as distribucion_dias
;

-----------

select 'promedio' as serie, 
  extract(hour from time) as hora, 
  extract(hour from time)||'-'||extract(hour from (time + interval '1 hour')) as hs, 
  round(avg(data)) as valor 
from 
bkn_variable 
join bkn_result using (variable_id)
join ftn_time_period on date(time)=date
where  bkn_variable.variable_id = 51  
and time between ('2015-06-29'::date + '10:00'::time) and ('2015-06-29'::date + '10:00'::time + '16 hours'::interval)
and time between (date + '10:00'::time) and (date + '10:00'::time + '16 hours'::interval)
group by hora, bkn_variable.variable_id, hs 
order by hora
;

select hour
--, (time::date + '10:00'::time) as start, (time::date + '10:00'::time + '16 hours'::interval) as end
from (select (h||':00')::time as hour from generate_series(0,23,1) as h) as time
where hour between (hour + '10:00'::time) and (hour + '10:00'::time + '16 hours'::interval)
group by hora 
order by hora
;


