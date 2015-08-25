select * from bkn_variable;

insert into bkn_variable
select 30,'IN ACCESOS PUNTERA JUNIN',creation_date,end_date,branch_id,sensor_type_code,access_code,latitude,longitude,workday_start,workday_duration,sector_id,variable_type_code,public,hall_id
from bkn_variable
where variable_id=18
;

insert into bkn_variable
select 31,'IN ACCESOS PUNTERA URIBURU',creation_date,end_date,branch_id,sensor_type_code,access_code,latitude,longitude,workday_start,workday_duration,sector_id,variable_type_code,public,hall_id
from bkn_variable
where variable_id=12
;


select * from bkn_active_formula;

insert into bkn_active_formula 
 (active_formula_id , formula_id , variable_id ,    creation_date    , start_date , end_date )
values
(17,1,30,'2015-01-01','2015-01-01',null)
;


insert into bkn_active_formula
 (active_formula_id , formula_id , variable_id ,    creation_date    , start_date , end_date )
values
(18,1,31,'2015-01-01','2015-01-01',null)
;

insert into bkn_active_formula_param
(active_formula_id, formula_param_id, value)
select 17, formula_param_id, value
from bkn_active_formula_param
where active_formula_id =7
;

insert into bkn_active_formula_param
(active_formula_id, formula_param_id, value)
select 18, formula_param_id, value
from bkn_active_formula_param
where active_formula_id =7
;

update bkn_active_formula_param set value = 6 where active_formula_param_id=94;
update bkn_active_formula_param set value = 4 where active_formula_param_id=99;


select variable_id, description, active_formula_id, value from
bkn_variable
full join bkn_active_formula using (variable_id)
full join bkn_active_formula_param using (active_formula_id)
where formula_param_id =101
;

