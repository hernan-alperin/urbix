drop function occupation();
create function occupation()
returns table (hora text, ingresos bigint, egresos bigint, ocupacion bigint, "desbalance porcentual" numeric)
as $$
begin
set search_path to private, public, urbix;
drop view if exists balance;
drop table if exists transit cascade; 
create temporary sequence i; 
create temporary table transit as -- junta de ingresos y egresos
select nextval('i')-1 as i,*
from 
  (select working_hour_text(date_trunc('hour', timestamp)::time,v_id) as hora, (round(avg(estimation)))::integer as "in"
  from variables_estimations
  where v_id=51
  group by hora) as ingresos
natural full join
  (select working_hour_text(date_trunc('hour', timestamp)::time,v_id) as hora, (round(avg(estimation)))::integer as "out"
  from variables_estimations
  where v_id=52 
  group by hora) as egresos
order by hora
;

create or replace temporary view balance as
with recursive estado(i,hora,ingresos,egresos,ocupacion) as ( -- tabla recursiva.
    values (0::bigint,null,0,0,0) -- caso base todo en cero hora nula
  union all (
    select i+1, transit.hora, "in", "out", greatest("in" - "out" + ocupacion, 0) -- incrementa secuencia (?)
    from estado
    join transit
    using(i)
  )
)
select i, estado.hora, ingresos, egresos, ocupacion 
from estado
;
drop sequence if exists i cascade;
return query 
select balance.hora, balance.ingresos, balance.egresos, balance.ocupacion, null
--  case when ingresos!=0 then round(100*(ingresos - egresos)/ingresos) else 'NaN' end 
  as "desbalance porcentual"
from balance
where balance.hora is not null or balance.hora!=''
union
select 'total', sum(balance.ingresos), sum(balance.egresos), sum(balance.ingresos - balance.egresos), 
  case when sum(balance.ingresos)!=0 then round(100*sum(balance.ingresos - balance.egresos)/sum(balance.ingresos))::numeric
  else 'NaN' end
from balance
order by hora;
end; 
$$
language plpgsql
;
select * from occupation();

