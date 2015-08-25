select min(evento), max(evento)
from eventos
;

    min     |    max
------------+------------
 1438570858 | 1439930882

select (1439930882 - 1438570858)/60/60/24;
15 dias...
select extract('epoch' from '5 minutes'::interval);
300
está en segundos

en dev

        min        |        max
-------------------+-------------------
 1382461700.000000 | 1435003021.000000

select (max(evento)-min(evento))/60/60/24
from eventos
;

608 dias

select count(*)
from eventos
where evento between inicio and inicio+299
and inicio in (select generate_series(1382461700,1435003021,300))
;

create function slot_count(bigint)
returns bigint
as $$
select count(*)
from eventos
where evento between $1 and $1+299
$$
language sql
;

select slot_count(slot) from (
  select generate_series(1382461700,1435003021,300) as slot
) as slots
;

super lento
otro dividir por can de segundos

select count(*)
from eventos
group by evento/60 -- cada minuto
order by count desc
limit 10
;







