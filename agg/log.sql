select sensor_id, description
from bkn_sensor
;

/*
 sensor_id |                       description                        
-----------+----------------------------------------------------------
         5 | Sensor PUESTO 3 - Arco de seguridad - BIYEMAS
         3 | Sensor PUESTO 3 - BIYEMAS retirado 2015-01-26 14:00

urbixagg=# \d bkn_sensor_factor
                                        Table "urbix.bkn_sensor_factor"
    Column    |          Type          |                               Modifiers                               
--------------+------------------------+-----------------------------------------------------------------------
 factor_id    | integer                | not null default nextval('bkn_sensor_factor_factor_id_seq'::regclass)
 sensor_id    | integer                | not null
 type_code    | integer                | not null
 factor_value | numeric(10,6)          | not null default 1
 start_date   | date                   | not null default now()
 end_date     | date                   | 
 comment      | character varying(600) | 
Indexes:
    "bkn_sensor_factor_pk" PRIMARY KEY, btree (factor_id, sensor_id)


*/

select *
from bkn_sensor_factor
where sensor_id in (3,5)
;

/*
 factor_id | sensor_id | type_code | factor_value | start_date |  end_date  |                    comment                    
-----------+-----------+-----------+--------------+------------+------------+-----------------------------------------------
         5 |         3 |         1 |     1.000000 | 2013-01-03 |            | 
        14 |         3 |         2 |     0.970000 | 2014-01-01 |            | Factores surgidos de certificacin JULIO 2014.
         6 |         3 |         2 |     1.000000 | 2013-01-03 | 2014-01-01 | 
         8 |         5 |         2 |     1.040000 | 2013-01-03 | 2014-01-01 | 
        15 |         5 |         2 |     0.970000 | 2014-01-01 | 2015-05-19 | Factores surgidos de certificacin JULIO 2014.
         7 |         5 |         1 |     1.000000 | 2013-01-03 | 2015-05-19 | 
        17 |         5 |         2 |     1.040000 | 2015-04-15 |            | recalibracion por obras 2015-01-26 - 2015-04
        18 |         5 |         1 |     1.050000 | 2015-04-15 |            | recalibracion por obras 2015-01-26 - 2015-04
*/

begin;
update bkn_sensor_factor
set factor_value = 1.04
where factor_id in (18)
;

commit;
 
--y mas... hay que hacer update de 3 valores de result

select variable_id, description
from bkn_variable
;
--           24 | IN REBISCO

select *
from bkn_result
where variable_id = 24
and (
   time = '2015-05-28 12:00'
or time = '2015-05-28 13:00'
or time = '2015-05-28 14:00'
)
;
/*
 result_id | variable_id |        time         |   data   
-----------+-------------+---------------------+----------
    691291 |          24 | 2015-05-28 12:00:00 | 160.2380
    691295 |          24 | 2015-05-28 13:00:00 |   8.5842
    691311 |          24 | 2015-05-28 14:00:00 | 166.9150
(3 rows)
*/
update bkn_result
set data = 221
where result_id = 691291
;

update bkn_result
set data = 301
where result_id = 691295
;
update bkn_result
set data = 283
where result_id = 691311
;


