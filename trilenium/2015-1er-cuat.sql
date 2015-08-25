create or replace function dia_semana(date) returns
text as'
select case extract(dow from $1)
            when 1 then ''Lunes''
            when 2 then ''Martes''
            when 3 then ''Miercoles''
            when 4 then ''Jueves''
            when 5 then ''Viernes''
            when 6 then ''Sabado''
            else ''Domingo''
       end;
' language 'sql' immutable;

drop table feriados;
create table feriados (feriado date);
copy feriados from stdin;
'2015-01-01'
'2015-02-17'
'2015-03-24'
'2015-04-02'
'2015-05-01'
'2015-05-25'
'2015-06-20'
'2015-07-09'
'2015-08-17'
\.

create or replace function feriado(date) returns
text as'
select case when ($1 in (select * from feriados)) then ''S'' 
            else ''N'' 
       end;
' language 'sql' immutable;

set search_path to urbix, public;

drop view v_meassures;
create view v_meassures as
select feriado(date(time)) as feriado,
       dia_semana(date(time)) as dia, 
       to_char(time,'DD/MM/YY') as fecha, 
       to_char(time,'HH:00') as periodo, 
       * 
from
 (select time, data as "4"
  from bkn_result
  where '2015-01-01' <= time and time <= '2015-05-01'
  and variable_id = 4) as f4
full join
 (select time, data as "5"
  from bkn_result
  where '2015-01-01' <= time and time <= '2015-05-01'
  and variable_id = 5) as f5
using (time)
full join
 (select time, data as "6"
  from bkn_result
  where '2015-01-01' <= time and time <= '2015-05-01'
  and variable_id = 6) as f6
using (time)
full join
 (select time, data as "7"
  from bkn_result
  where '2015-01-01' <= time and time <= '2015-05-01'
  and variable_id = 7) as f7
using (time)
full join
 (select time, data as "8"
  from bkn_result
  where '2015-01-01' <= time and time <= '2015-05-01'
  and variable_id = 8) as f8
using (time)
full join
 (select time, data as "9"
  from bkn_result
  where '2015-01-01' <= time and time <= '2015-05-01'
  and variable_id = 9) as f9
using (time)
full join
 (select time, data as "10"
  from bkn_result
  where '2015-01-01' <= time and time <= '2015-05-01'
  and variable_id = 10) as f10
using (time)
full join
 (select time, data as "11"
  from bkn_result
  where '2015-01-01' <= time and time <= '2015-05-01'
  and variable_id = 11) as f11
using (time)
order by time
;


copy (select * from v_meassures) to stdout;

