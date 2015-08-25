begin;
/*
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

 s_id |                          sensor                           | a_id | b_id 
------+-----------------------------------------------------------+------+------
    1 | Sensor 1,  PB Acceso Vicente Lopez McCafe                 |    2 |    3
    3 | Sensor 3,  PB Acceso Hall Ascensores                      |    1 |    3

 v_id |                    variable                    | b_id | public 
------+------------------------------------------------+------+--------
    6 | PB Ascensores Hall acceso in                   |    1 | t
    8 | PB Vicente Lopez McCafe acceso in              |    1 | t
   33 | PB Vicente Lopez McCafe acceso out             |    1 | t
   34 | PB Ascensores Hall acceso out                  |    1 | t


*/


select * from bkn_active_formula where variable_id in (6,8,33,34);

insert into bkn_active_formula values (1, 1, 6,'2015-01-01','2015-01-01',null);
insert into bkn_active_formula values (2, 1, 8,'2015-01-01','2015-01-01',null);
insert into bkn_active_formula values (3, 1, 33,'2015-01-01','2015-01-01',null);
insert into bkn_active_formula values (4, 1, 34,'2015-01-01','2015-01-01',null);

insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),1,100,1);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),1,101,1);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),1,102,1);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),3,100,1);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),3,101,2);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),3,102,2);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),2,100,1);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),2,101,2);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),2,102,1);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),4,100,1);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),4,101,1);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),4,102,2);





truncate bkn_result;
update bkn_measure set refresh=true;
select formula_engine();


commit;

begin;
set search_path to mall, urbix, public;
delete from bkn_result where variable_id between 51 and 71;
delete from bkn_active_formula_param where active_formula_id between 51 and 71; 
delete from bkn_active_formula where active_formula_id between 51 and 71;
delete from bkn_variable where variable_id between 51 and 71;

update bkn_sensor set organization_code = 0 where sensor_id>200 or sensor_id=2;

insert into bkn_variable
select 51,'Ingresos Totales Predio (PB y Niveles 1, 2, 3)', creation_date,end_date,branch_id,sensor_type_code,access_code,latitude,longitude,workday_start,workday_duration,sector_id,variable_type_code,public,hall_id
from bkn_variable
where variable_id=1;

insert into bkn_variable
select 52,'Egresos Totales Predio (PB y Niveles 1, 2, 3)', creation_date,end_date,branch_id,sensor_type_code,access_code,latitude,longitude,workday_start,workday_duration,sector_id,variable_type_code,public,hall_id
from bkn_variable
where variable_id=40;



/*
urbixrecoleta=# \d bkn_active_formula
                                         Table "urbix.bkn_active_formula"
      Column       |            Type             |                            Modifiers                            
-------------------+-----------------------------+-----------------------------------------------------------------
 active_formula_id | integer                     | not null default nextval('bkn_active_formula_id_seq'::regclass)
 formula_id        | integer                     | not null
 variable_id       | integer                     | not null
 creation_date     | timestamp without time zone | not null default now()
 start_date        | date                        | not null
 end_date          | date                        | 
Indexes:
    "bkn_active_formula_pk" PRIMARY KEY, btree (active_formula_id)
Foreign-key constraints:
    "bkn_formula_bkn_active_formula_fk" FOREIGN KEY (formula_id) REFERENCES bkn_formula(formula_id)
    "bkn_variable_bkn_active_formula_fk" FOREIGN KEY (variable_id) REFERENCES bkn_variable(variable_id)
Referenced by:
    TABLE "bkn_active_formula_param" CONSTRAINT "bkn_active_formula_bkn_variable_param_fk" FOREIGN KEY (active_formula_id) REFERENCES bkn_active_formula(active_formula_id)

active_formula_id | formula_id | variable_id |    creation_date    | start_date | end_date
*/

insert into bkn_active_formula values (51, 13, 51,'2015-01-01','2015-01-01',null);
insert into bkn_active_formula values (52, 13, 52,'2015-01-01','2015-01-01',null);

/*
 param_id | formula_id |    description    | value | type_code 
----------+------------+-------------------+-------+-----------
      100 |          1 | factor            | 1     |         2
      101 |          1 | acceso            |       |      1000
      102 |          1 | tipo              | 1     |      1001
      200 |          2 | factor            | 1     |         2
      201 |          2 | sucursal          |       |      1002
      202 |          2 | tipo              | 1     |      1001

\d bkn_active_formula_param
         Column          |          Type           |                               Modifiers                               
-------------------------+-------------------------+-----------------------------------------------------------------------
 active_formula_param_id | integer                 | not null default nextval('bkn_active_formula_param_id_seq'::regclass)
 active_formula_id       | integer                 | not null
 formula_param_id        | integer                 | not null
 value                   | character varying(4000) | 
Indexes:
    "bkn_active_formula_param_pk" PRIMARY KEY, btree (active_formula_param_id)
    "bkn_active_formula_param_idx" UNIQUE, btree (active_formula_id, formula_param_id)
Foreign-key constraints:
    "bkn_active_formula_bkn_variable_param_fk" FOREIGN KEY (active_formula_id) REFERENCES bkn_active_formula(active_formula_id)
    "bkn_param_bkn_active_param_fk" FOREIGN KEY (formula_param_id) REFERENCES bkn_formula_param(param_id)
Referenced by:
    TABLE "bkn_active_formula_param_x_time_filter" CONSTRAINT "bkn_active_formula_param_bkn_active_formula_param_x_filter_fk" FOREIGN KEY (active_formula_param_id) REFERENCES bkn_active_formula_param(active_formula_param_id)

*/

insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),51,200,1);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),51,201,1);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),51,202,1);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),52,200,1);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),52,201,1);
insert into bkn_active_formula_param values (nextval('bkn_active_formula_param_id_seq'::regclass),52,202,2);


commit;

UPDATE bkn_measure SET  refresh = true;-- where  measure_time>='2015-07-01'; 
select formula_engine();


