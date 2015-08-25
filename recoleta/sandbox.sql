select variable_id, code, bkn_variable.description, ums_code.description
from ums_code
full join bkn_variable
on code=variable_id
where type = 'VARIABLE_IN_ACCESS'
;


-- renombrar ums_code description acorde a lo que hay en bkn_variable
update ums_code
set description=bkn_variable.description
from bkn_variable
where code=variable_id
and type = 'VARIABLE_IN_ACCESS'
; 


-- ver que sensores se estan midiendo
select distinct sensor_id, description
from bkn_measure
natural join 
bkn_measure_data
natural join 
bkn_sensor
order by sensor_id
;

-- ver con que variables se relacionan
select vars.variable_id, vars.description, vars.active_formula_id, sens.sensor_id as sensor, sens.access_code
, meassures.description, meassures.sensor_id as meassuring 
from (
  select variable_id, var.description, form.active_formula_id, value as sensor_id
  from bkn_variable as var
  full join bkn_active_formula as form
  using (variable_id)
  join bkn_active_formula_param
  using (active_formula_id)
  where formula_param_id=101
  ) as vars
full join bkn_sensor as sens
on vars.sensor_id::integer=sens.sensor_id
full join (select distinct sensor_id, description, access_code, 'ok' as ok
  from bkn_measure
  natural join
  bkn_measure_data
  natural join
  bkn_sensor
  order by sensor_id) as meassures
on sens.sensor_id=meassures.sensor_id
;

-- ver que formulas hay que corregir
select forms.*, value
from bkn_active_formula as forms
join bkn_active_formula_param
using (active_formula_id)
where formula_param_id=101
;

-- corregiendo
select forms.*, params.*
from bkn_active_formula as forms
join bkn_active_formula_param as params
using (active_formula_id)
where formula_param_id=101
and variable_id in (24)
;

begin;
update bkn_active_formula_param
set value=10
where active_formula_param_id=52
;

select variable_id, description, forms.active_formula_id, params.*
from bkn_variable as vars
left join bkn_active_formula as forms
using (variable_id)
left join bkn_active_formula_param as params
using (active_formula_id)
where formula_param_id in (101,201)
;


truncate bkn_result;
update bkn_measure
set refresh = true
;
select formula_engine()
;

insert into bkn_active_formula_param (active_formula_id,formula_param_id,value) 
select distinct forms.active_formula_id, 101, 9999 from bkn_active_formula as forms
left join bkn_active_formula_param as params
using (active_formula_id)
where params.active_formula_id is null
;


select * from bkn_formula_param
;

insert into bkn_active_formula_param (active_formula_id,formula_param_id,value)
select distinct forms.active_formula_id, --variable_id, description, 
201, 1 as value from bkn_active_formula as forms
left join bkn_active_formula_param as params
using (active_formula_id)
full join bkn_variable
using (variable_id)
where params.value::integer!=9999
and variable_id!=1
;

select * from bkn_active_formula_param
where formula_param_id=201
;


-- el grafico de tortas
select a.variable_id, b.description, round(sum(data)) as ing_acceso 
from urbix.bkn_result a, urbix.bkn_variable b 
WHERE a.variable_id=b.variable_id 
and a.variable_id in (6,8,10,11,12,13,14,16,22,24,26) 
and date(time) between date('2015/05/12') and date('2015/05/27') 
and extract(hour from time) between '8' and '23' 
group by a.variable_id, b.description 
order by a.variable_id
;


select active_formula_param_id,variable_id, description
--, 201, 1 as value 
from bkn_active_formula as forms
left join bkn_active_formula_param as params
using (active_formula_id)
full join bkn_variable
using (variable_id)
where active_formula_id=201 --params.value::integer!=9999
;


select active_formula_id, active_formula_param_id, value as access_code, vars.variable_id, vars.description
from bkn_active_formula_param as params
natural join bkn_active_formula
right join bkn_variable as vars
on vars.variable_id=bkn_active_formula.variable_id
where formula_param_id=101
and vars.description ilike 'IN %'
order by active_formula_param_id
;


select * 
from ums_code
where type='VARIABLE_IN_ACCESS'
;


select sensor_id, access_code, description
from bkn_sensor as sens
join bkn_active_formula_param as params
on sens.access_code=params.value::integer
where formula_param_id=101
;

update bkn_active_formula_param
set value=16
where active_formula_param_id=56
;

select active_formula_id, active_formula_param_id, vars.variable_id, vars.description, sens.access_code as "access"
, sensor_id, sens.description
from (
select active_formula_id, active_formula_param_id, value as access_code, vars.variable_id, vars.description
from bkn_active_formula_param as params
natural join bkn_active_formula
right join bkn_variable as vars
on vars.variable_id=bkn_active_formula.variable_id
where formula_param_id=101
and vars.description ilike 'IN %'
order by active_formula_param_id
) as vars
join (
select sensor_id, access_code, description
from bkn_sensor as sens
join bkn_active_formula_param as params
on sens.access_code=params.value::integer
where formula_param_id=101
) as sens
on sens.access_code::integer=vars.access_code::integer
;

select active_formula_param_id,variable_id, description
from bkn_active_formula as forms
left join bkn_active_formula_param as params
using (active_formula_id)
full join bkn_variable
using (variable_id)
where formula_param_id=101 --params.value::integer!=9999
;



select * 
from bkn_active_formula as forms
natural join bkn_active_formula_param as params
where variable_id not in (select code from ums_code where type='VARIABLE_IN_ACCESS')
;

select *
from bkn_active_formula as forms
natural join bkn_active_formula_param as params
where variable_id in (select code from ums_code where type='VARIABLE_IN_ACCESS')
and formula_param_id=101
;



--------------------------

