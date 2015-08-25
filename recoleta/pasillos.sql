delete from bkn_variable where variable_id=41;
insert into bkn_variable
select 41,'N1 Escalera Mecánica descenso acceso in', creation_date,end_date,branch_id,sensor_type_code,access_code,latitude,longitude,workday_start,workday_duration,sector_id,variable_type_code,public,hall_id
from bkn_variable
where variable_id=30;

delete from bkn_variable where variable_id=42;
insert into bkn_variable
select 42,'PB Escalera Mecánica descenso acceso out', creation_date,end_date,branch_id,sensor_type_code,access_code,latitude,longitude,workday_start,workday_duration,sector_id,variable_type_code,public,hall_id
from bkn_variable
where variable_id=30;

---

delete from bkn_active_formula_param where active_formula_id>99; 
delete from bkn_active_formula where active_formula_id>99;
delete from bkn_variable where variable_id>99;

insert into bkn_variable
select 100, 'pasillo N1 Maria Cher', creation_date,end_date,branch_id,sensor_type_code,access_code,latitude,longitude,workday_start,workday_duration,sector_id,variable_type_code,public,hall_id
from bkn_variable
where variable_id=30;


insert into bkn_variable
select 102,'pasillo N1 Key Bizkeyne', creation_date,end_date,branch_id,sensor_type_code,access_code,latitude,longitude,workday_start,workday_duration,sector_id,variable_type_code,public,hall_id
from bkn_variable
where variable_id=30;
  
insert into bkn_variable
select 104,'pasillo N2 Estancia Chiripa', creation_date,end_date,branch_id,sensor_type_code,access_code,latitude,longitude,workday_start,workday_duration,sector_id,variable_type_code,public,hall_id
from bkn_variable
where variable_id=30;

insert into bkn_variable
select 106,'pasillo N2 Maxime', creation_date,end_date,branch_id,sensor_type_code,access_code,latitude,longitude,workday_start,workday_duration,sector_id,variable_type_code,public,hall_id
from bkn_variable
where variable_id=30;


insert into bkn_variable
select 108,'pasillo N3 Cristobal Colon', creation_date,end_date,branch_id,sensor_type_code,access_code,latitude,longitude,workday_start,workday_duration,sector_id,variable_type_code,public,hall_id
from bkn_variable
where variable_id=30;

insert into bkn_variable
select 110,'pasillo N3 Mamuschka', creation_date,end_date,branch_id,sensor_type_code,access_code,latitude,longitude,workday_start,workday_duration,sector_id,variable_type_code,public,hall_id
from bkn_variable
where variable_id=30;



insert into bkn_active_formula values (100, 1, 100,'2015-01-01','2015-01-01',null);
insert into bkn_active_formula values (102, 1, 102,'2015-01-01','2015-01-01',null);
insert into bkn_active_formula values (104, 1, 104,'2015-01-01','2015-01-01',null);
insert into bkn_active_formula values (106, 1, 106,'2015-01-01','2015-01-01',null);
insert into bkn_active_formula values (108, 1, 108,'2015-01-01','2015-01-01',null);
insert into bkn_active_formula values (110, 1, 110,'2015-01-01','2015-01-01',null);


/*
urbixrecoleta=# select * from variables_formulas where v_id>99;
 v_id |          variable           | b_id | public | active_formula_id | formula_id 
------+-----------------------------+------+--------+-------------------+------------
  100 | pasillo N1 Maria Cher       |    1 | t      |               100 |          1
  102 | pasillo N1 Key Bizkeyne     |    1 | t      |               102 |          1
  104 | pasillo N2 Estancia Chiripa |    1 | t      |               104 |          1
  106 | pasillo N2 Maxime           |    1 | t      |               106 |          1
  108 | pasillo N3 Cristobal Colon  |    1 | t      |               108 |          1
  110 | pasillo N3 Mamuschka        |    1 | t      |               110 |          1
(6 rows)

urbixrecoleta=# select * from sensors where s_id > 200;
 s_id |           sensor            | a_id | b_id 
------+-----------------------------+------+------
  250 | pasillo N3 Mamuschka        |   15 |    2
  241 | pasillo N1 Maria Cher       |    8 |    2
  242 | pasillo N1 Key Bizkeyne     |    9 |    2
  246 | pasillo N2 Estancia Chiripa |   11 |    2
  247 | pasillo N2 Maxime           |   12 |    2
  249 | pasillo N3 Cristobal Colon  |   14 |    2
(6 rows)

urbixrecoleta=# select * from bkn_formula_param;
 param_id | formula_id |    description    | value | type_code 
----------+------------+-------------------+-------+-----------
      100 |          1 | factor            | 1     |         2
      101 |          1 | acceso            |       |      1000
      102 |          1 | tipo              | 1     |      1001

urbixrecoleta=# select * from bkn_active_formula_param where active_formula_id=30;
 active_formula_param_id | active_formula_id | formula_param_id | value 
-------------------------+-------------------+------------------+-------
                     132 |                30 |              100 | 1
                     133 |                30 |              102 | 2
                     134 |                30 |              110 | 0
                     136 |                30 |              101 | 16
(4 rows)


*/
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),106,100,1);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),106,101,12);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),106,102,1);

insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),108,100,1);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),108,101,14);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),108,102,1);

insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),110,100,1);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),110,101,15);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),110,102,1);

insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),100,100,1);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),100,101,8);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),100,102,1);

insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),102,100,1);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),102,101,9);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),102,102,1);

insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),104,100,1);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),104,101,11);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),104,102,1);

update bkn_measure set refresh=true where sensor_id>200;
select formula_engine();



