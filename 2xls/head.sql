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
