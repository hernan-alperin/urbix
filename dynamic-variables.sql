set search_path to private, public, urbix;
-- creando funciones para acceder a las variables 
-- function to access to variable_estimations to build complex queries using expression languand through php parsing
drop function if exists estimations_variable(variable character varying) cascade;
create or replace function estimations_variable(variable character varying)
returns
table ("timestamp" timestamp, estimation numeric)
as $$
  select timestamp, estimation
  from variables_estimations
  where 'v_'||(v_id::character varying)=$1
$$
language sql
stable
;

drop function if exists estimations_variable(v_id integer) cascade;
create or replace function estimations_variable(v_id integer)
returns
table ("timestamp" timestamp, estimation numeric)
as $$
  select timestamp, estimation
  from variables_estimations
  where v_id=$1
$$
language sql
stable
;


/*
check it out: 
select * from estimations_variable('v_52') where date(timestamp)='2015-07-01'; -- egresos predio

select timestamp, hora, ingresos, egresos, ingresos-egresos as desbalance 
from (
  select timestamp, working_hour_text(timestamp::time,51) as hora, estimation as ingresos
  from estimations_variable(51)) as "ingresos predio"
natural join (
  select timestamp, working_hour_text(timestamp::time,52) as hora, estimation as egresos
  from estimations_variable(52)) as "egresos predio"
where date(timestamp)='2015-07-01'
;
*/

drop function if exists desbalance(v_1 integer, v_2 integer) cascade;
create or replace function desbalance(v_1 integer, v_2 integer)
returns
table ("timestamp" timestamp, hora character varying, ingresos numeric, egresos numeric, desbalance numeric)
as $$
select timestamp, hora, ingresos, egresos, ingresos-egresos as desbalance 
from (
  select timestamp, working_hour_text(timestamp::time,$1) as hora, estimation as ingresos
  from estimations_variable($1)) as v_1
natural join (
  select timestamp, working_hour_text(timestamp::time,$2) as hora, estimation as egresos
  from estimations_variable($2)) as v_2
$$
language sql
stable
;

--/* check it out:
select * from desbalance(51,52)
where date(timestamp)='2015-07-01'
order by hora
;
--*/


drop function if exists desbalance("timestamp" timestamp, v_1 integer, v_2 integer) cascade;
create or replace function desbalance("timestamp" timestamp, v_1 integer, v_2 integer)
returns
table ("timestamp" timestamp, hora character varying, ingresos numeric, egresos numeric, desbalance numeric)
as $$
select timestamp, hora, ingresos, egresos, ingresos-egresos as desbalance
from (
  select timestamp, working_hour_text(timestamp::time,$2) as hora, estimation as ingresos
  from estimations_variable($2)) as v_1
natural join (
  select timestamp, working_hour_text(timestamp::time,$3) as hora, estimation as egresos
  from estimations_variable($3)) as v_2
where timestamp=$1
$$
language sql
stable
;

--/* check it out:
select * from desbalance('2015-07-01 10:00',51,52)
;
--*/

drop function if exists occupation("timestamp" timestamp, v_1 integer, v_2 integer) cascade;
create or replace function occupation("timestamp" timestamp, v_1 integer, v_2 integer)
returns numeric
as $$
select sum(desbalance)
from desbalance($2,$3)
group by timestamp
--having date(timestamp)=date($1) and (timestamp::time)<($1::time)
$$
language sql
stable
;

--/* check it out:
select * from occupation('2015-07-01 5:00:00',51,52);
select * from occupation('2015-07-01 6:00:00',51,52);
select * from occupation('2015-07-01 7:00:00',51,52);
select * from occupation('2015-07-01 8:00:00',51,52);
select * from occupation('2015-07-01 9:00:00',51,52);
select * from occupation('2015-07-01 10:00',51,52);
--*/
-------------------------



drop function if exists desbalance("timestamp" timestamp, v_1 integer, v_2 integer) cascade;
create or replace function desbalance("timestamp" timestamp, v_1 integer, v_2 integer)
returns numeric
as $$
select ingresos-egresos as desbalance
from (
  select estimation as ingresos
  from estimations_variable($2)) as v_1
natural join (
  select estimation as egresos
  from estimations_variable($3)) as v_2
where timestamp=$1
$$
language sql
stable
;

select hora, sum(desbalance("timestamp",51,52))
from desbalance(51,52)
where date(timestamp)='2015-07-01'
group by hora
order by hora
;



-----------------------------
