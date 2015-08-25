
drop function balance();
create or replace function balance()
returns table (i integer, hora character varying, ingresos integer, egresos integer, ocupacion integer)
as $$
drop sequence i cascade; 
drop table transit cascade;
create sequence i; -- secuencia y tabla temporaria deberían desaparecer una vez cerrada la sesión
create table transit as -- junta de ingresos y egresos
with movimientos as (select * from
  (select working_hour_text(date_trunc('hour', timestamp)::time,v_id) as hora, (round(avg(meassure)))::integer as "in"
  from variables_meassures
  where v_id=1
  group by hora) as ingresos
natural full join
  (select working_hour_text(date_trunc('hour', timestamp)::time,v_id) as hora, (round(avg(meassure)))::integer as "out"
  from variables_meassures
  where v_id=40
  group by hora) as egresos
order by hora
)
select nextval('i')-1 as i,* from movimientos
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

select * from balance;
$$
language sql
;




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


