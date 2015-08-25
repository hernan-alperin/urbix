drop sequence i cascade; drop table transit cascade; -- las elimino si se está en la misma sesión
create temporary sequence i; -- secuencia y tabla temporaria deberían desaparecer una vez cerrada la sesión
create temporary table transit as -- junta de ingresos y egresos
with movimientos as (select * from
  (select working_hour_text(date_trunc('hour', timestamp)::time,v_id) as hora, (round(avg(estimation)))::integer as "in"
  from variables_estimations
  where v_id=1
  group by hora) as ingresos
natural full join
  (select working_hour_text(date_trunc('hour', timestamp)::time,v_id) as hora, (round(avg(estimation)))::integer as "out"
  from variables_estimations
  where v_id=40
  group by hora) as egresos
order by hora
)
select nextval('i')::integer-1 as i,* from movimientos
;

create or replace view balance as 
with recursive estado(i,hora,ingresos,egresos,ocupacion) as ( -- tabla recursiva.
    values (0,null,0,0,0) -- caso base todo en cero hora nula
  union all (
    select i+1, transit.hora, "in", "out", greatest("in" - "out" + ocupacion, 0) -- incrementa secuencia (?)
    from estado
    join transit
    using(i)
    where i<25
  )
)
--select h, "in", "out", ocupacion 
select i, hora, ingresos, egresos, ocupacion
from estado;

select hora, ingresos, egresos, ocupacion, null 
--  case when ingresos!=0 then round(100*(ingresos - egresos)/ingresos) else 'NaN' end 
  as "desbalance porcentual" 
from balance
where hora is not null or hora!=''
union
select '| total', sum(ingresos), sum(egresos), sum(ingresos - egresos), 
  case when sum(ingresos)!=0 then round(100*sum(ingresos - egresos)/sum(ingresos))
  else 'NaN' end
from balance
order by hora 
;

-- rebalanceo
update bkn_active_formula_param set value=1 where formula_param_id % 100 = 0 and active_formula_id=33; -- active formula egresos mall 


---- un test_day en particular
drop sequence i cascade; drop table transit cascade;
create temporary sequence i;
create temporary table transit as
with test_days as (select '2015-07-18'::date as test_day),
  movimientos as (select * from
  (select working_hour_text(date_trunc('hour', timestamp)::time,v_id) as hora, (round(avg(estimation)))::integer as "in"
  from variables_estimations, test_days
  where v_id=51 and timestamp::date=test_day
  group by hora) as ingresos
natural full join
  (select working_hour_text(date_trunc('hour', timestamp)::time,v_id) as hora, (round(avg(estimation)))::integer as "out"
  from variables_estimations, test_days
  where v_id=52 and timestamp::date=test_day
  group by hora) as egresos
order by hora
)
select nextval('i')::integer-1 as i,* from movimientos
;

create or replace view balance as
with recursive estado(i,hora,ingresos,egresos,ocupacion) as (
    values (0,null,0,0,0)
  union all (
    select i+1, transit.hora, "in", "out", "in" - "out" + ocupacion
    from estado
    join transit
    using(i)
    where i<25
  )
)
select * from estado;


select hora, ingresos, egresos, ocupacion, null 
--  case when ingresos!=0 then round(100*(ingresos - egresos)/ingresos) else 'NaN' end 
  as "desbalance porcentual" 
from balance
where hora is not null or hora!=''
union
select '| total', sum(ingresos), sum(egresos), sum(ingresos - egresos), 
  case when sum(ingresos)!=0 then round(100*sum(ingresos - egresos)/sum(ingresos))
  else 'NaN' end
from balance
order by hora 
;


