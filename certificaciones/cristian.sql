-- para DB sistema_urbix

create schema cristian;
set search_path to cristian, public;

create or replace function eventos_por_cam(idcamara integer, desde timestamp, hasta timestamp) 
returns table (idcamara integer, idbox integer, "timestamp" timestamp with time zone, alias text, box text) as $$
select idcamara, idbox
, timestamp with time zone 'epoch' + evento * interval '1 second' as timestamp
, alias, box
from eventos
join boxes on idbox = boxes.id
where idcamara = $1
and extract(epoch from $2::timestamp with time zone) <= eventos.evento
and eventos.evento <= extract(epoch from $3::timestamp with time zone)
order by timestamp 
$$
security definer
stable language sql
;
grant execute on function eventos_por_cam(idcamara integer, desde timestamp, hasta timestamp) to cristian;
comment on function eventos_por_cam(idcamara integer, desde timestamp, hasta timestamp)
  is 'devuelve la lista de eventos de la cámara entre los timestamp especificados';

create or replace function eventos_por_cam(idcamara integer, desde timestamp, sincro interval, hasta timestamp) 
returns table (idcamara integer, idbox integer, "timestamp" timestamp with time zone, alias text, box text) as $$
select idcamara, idbox
, timestamp with time zone 'epoch' + evento * interval '1 second' + $3 as timestamp
, alias, box
from eventos
join boxes on idbox = boxes.id
where idcamara = $1
and extract(epoch from ($4::timestamp with time zone + $3)) <= eventos.evento
and eventos.evento <= extract(epoch from ($4::timestamp with time zone + $3))
order by timestamp 
$$
stable language sql
;
grant execute on function eventos_por_cam(idcamara integer, desde timestamp, sincro interval, hasta timestamp) to cristian;
comment on function eventos_por_cam(idcamara integer, desde timestamp, sincro interval, hasta timestamp)
  is 'devuelve la lista de eventos de la cámara entre los timestamp especificados usando un intervalo de sincronización';



