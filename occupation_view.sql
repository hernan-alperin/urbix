set search_path to private, urbix;
drop view if exists balance;
create view balance as 
with 
  recursive estado(i,hora,ingresos,egresos,ocupacion) as ( -- tabla recursiva.
    values (0::bigint,null,0,0,0) -- caso base todo en cero hora nula
  union all (
    select i, movimientos.hora, "in", "out", greatest("in" - "out" + ocupacion, 0) from
    --select i, movimientos.hora, "in", "out", greatest("in" - "out", 0) from
      (
      select row_number() over(order by hora) as i, * from
        (select working_hour_text(date_trunc('hour', timestamp)::time,v_id) as hora, (round(avg(estimation)))::integer as "in"
        from variables_estimations
        where v_id=1
        group by hora) as ingresos
      natural full join
        (select working_hour_text(date_trunc('hour', timestamp)::time,v_id) as hora, (round(avg(estimation)))::integer as "out"
        from variables_estimations
        where v_id=40
        group by hora) as egresos
      ) as movimientos
    join estado
    using(i)
  )
)
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
