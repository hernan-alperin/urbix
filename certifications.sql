
-- samples
select 
  round((manual/extract('seconds' from intervalo))::numeric,2) as caudal,
  (manual-sensor)::numeric/manual as error
from medicion_urbixcam
order by caudal, error
;

-- distribution
select
  (manual/extract('seconds' from intervalo)) as caudal,
  count(*) as count,
  min((manual-sensor)::numeric/manual) as min_error,
  max((manual-sensor)::numeric/manual) as max_error,
  avg((manual-sensor)::numeric/manual) as avg_error,
  stddev((manual-sensor)::numeric/manual) as stddev_error
from medicion_urbixcam
group by caudal
order by caudal
;



