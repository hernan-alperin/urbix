set search_path to private, urbix;
drop function if exists foo();
create function foo() 
returns table (i bigint, hora character varying, "in" integer, "out" integer)
as $$
select row_number() over (order by hora), * from 
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
$$
language sql
;

drop function if exists bar(bigint);
create function bar(bigint) 
returns bigint
as $$
select sum("in"-"out") from foo()
where i<=$1
$$
language sql
;

select i,hora,"in","out",bar(i) from foo()
;






