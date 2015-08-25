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
from (select time, data as "IN BIYEMAS v_id=1" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 1) as v1

full join (select time, data as "OUT BIYEMAS - v_id=2" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 2) as v2
using (time)
full join (select time, data as "OCUPACION TOTAL - v_id=3" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 3) as v3
using (time)
full join (select time, data as "OCUPACION BINGO - v_id=4" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 4) as v4
using (time)
full join (select time, data as "OCUPACION TOTAL - v_id=5" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 5) as v5
using (time)
full join (select time, data as "IN BINGO BIYEMAS - v_id=6" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 6) as v6
using (time)
full join (select time, data as "OUT BINGO BIYEMAS - v_id=7" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 7) as v7
using (time)
full join (select time, data as "INGRESOS PUESTO 1 - v_id=8" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 8) as v8
using (time)
full join (select time, data as "EGRESOS PUESTO 1 - v_id=9" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 9) as v9
using (time)
full join (select time, data as "INGRESOS VALET PARKING - v_id=10" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 10) as v10
using (time)
full join (select time, data as "EGRESOS VALET PARKING - v_id=11" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 11) as v11
using (time)
full join (select time, data as "INGRESOS PUESTO 3 - v_id=12" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 12) as v12
using (time)
full join (select time, data as "EGRESOS PUESTO 3 - v_id=13" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 13) as v13
using (time)
full join (select time, data as "ING.P3 - ARCO SEGURIDAD - v_id=14" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 14) as v14
using (time)
full join (select time, data as "EGR.P3 - ARCO SEGURIDAD - v_id=15" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 15) as v15
using (time)
full join (select time, data as "ING.P1 - ARCO SEGURIDAD - v_id=16" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 16) as v16
using (time)
full join (select time, data as "EGR.P1 - ARCO SEGURIDAD - v_id=17" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 17) as v17
using (time)
full join (select time, data as "NETO VALET PARKING - v_id=18" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 18) as v18
using (time)
full join (select time, data as "INGRESOS SECTOR VIP - v_id=19" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 19) as v19
using (time)
full join (select time, data as "EGRESOS SECTOR VIP - v_id=20" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 20) as v20
using (time)
full join (select time, data as "ING. PUBLICO SECTOR VIP - v_id=21" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 21) as v21
using (time)
full join (select time, data as "EGR. PUBLICO SECTOR VIP - v_id=22" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 22) as v22
using (time)
full join (select time, data as "IN KANDIKO - v_id=23" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 23) as v23
using (time)
full join (select time, data as "IN REBISCO - v_id=24" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 24) as v24
using (time)
full join (select time, data as "IN BINGO KANDIKO - v_id=25" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 25) as v25
using (time)
full join (select time, data as "IN BINGO REBISCO - v_id=26" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 26) as v26
using (time)
full join (select time, data as "IN CLIENTES BIYEMAS (ARCOS) - v_id=27" from bkn_result 
 where '2015-01-01' <= time and time <= '2015-05-01' 
 and variable_id = 27) as v27
using (time)
order by time;
