select s_ch, avg(factor) from sensors_factors where s_id<200 group by s_ch;

select s_id, sensor, i, o, i-o as delta, factor_i, factor_o from 
(select s_id, round(avg(corrected)) as i, factor as factor_i
  from meassures natural join sensors_factors
  where s_id < 200 and s_ch = 1
  group by s_id,factor) as i
natural join
(select s_id, round(avg(corrected)) as o, factor as factor_o
  from meassures natural join sensors_factors
  where s_id < 200 and s_ch = 2
  group by s_id,factor) as o
natural join 
sensors
order by delta
;

/* valores originalmente corregido por Cristian
 s_id |                          sensor                           |  i  |  o  | delta | factor_i | factor_o
------+-----------------------------------------------------------+-----+-----+-------+----------+----------
    5 | Sensor 5,  N1 - Uriburu Acceso Puntera Uriburu Juleriaque |  17 |  38 |   -21 | 1.040000 | 1.100000
    1 | Sensor 1,  PB Acceso Vicente Lopez McCafe                 | 220 | 227 |    -7 | 0.850000 | 0.810000
    9 | Sensor 9,  N2 - Acceso Hall Ascensores 2 piso             |  12 |  15 |    -3 | 1.120000 | 1.500000
    8 | Sensor 8,  N1 - Acceso Ascensores 1 piso                  |  20 |  22 |    -2 | 1.100000 | 1.020000
    2 | Sensor 2,  PB Acceso Escalera Mec nica                    |  91 |  80 |    11 | 1.000000 | 1.000000
    3 | Sensor 3,  PB Acceso Hall Ascensores                      |  59 |  42 |    17 | 0.960000 | 0.910000
    4 | Sensor 4,  N1 - Uriburu Acceso Puntera Uriburu Lacoste    |  96 |  70 |    26 | 0.960000 | 1.000000
    6 | Sensor 6,  N1 - Junin Acceso Puntera Junin Grimoldi       | 142 |  97 |    45 | 1.100000 | 1.090000
   10 | Sensor 10, N3 - Acceso Hall Ascensores 3 piso             |  70 |  25 |    45 | 1.110000 | 1.020000
(9 rows)

urbixrecoleta=# select * from bkn_sensor_factor where sensor_id<200 order by sensor_id, type_code;
 factor_id | sensor_id | type_code | factor_value | start_date | end_date |                         comment
-----------+-----------+-----------+--------------+------------+----------+---------------------------------------------------------
        20 |         1 |         1 |     0.850000 | 2015-05-01 |          | certificación 2015-06-03 merodeo!
        21 |         1 |         2 |     0.810000 | 2015-05-01 |          | certificación 2015-06-03 merodeo!
         4 |         2 |         1 |     1.000000 | 2015-05-01 |          | certificación 2015-06-03 error 0%
         5 |         2 |         2 |     1.000000 | 2015-05-01 |          | certificación 2015-05-27 error 1%
         6 |         3 |         1 |     0.960000 | 2015-05-01 |          | certificación 2015-06-10 error 4%
         7 |         3 |         2 |     0.910000 | 2015-05-01 |          | certificación 2015-06-10 error 10%
        18 |         4 |         1 |     0.960000 | 2015-05-01 |          | certificación 2015-06-03 error 4%
        19 |         4 |         2 |     1.000000 | 2015-05-01 |          | certificación 2015-06-03 error 0%
        16 |         5 |         1 |     1.040000 | 2015-05-01 |          | certificación 2015-06-03 error -4%
        17 |         5 |         2 |     1.100000 | 2015-05-01 |          | certificación 2015-06-03 error -9%
        14 |         6 |         1 |     1.100000 | 2015-05-01 |          | certificación 2015-05-27 error -9%
        15 |         6 |         2 |     1.090000 | 2015-05-01 |          | certificación 2015-06-03 error -8%
         8 |         8 |         1 |     1.100000 | 2015-05-01 |          | certificación 2015-06-03 error -0.9%
         9 |         8 |         2 |     1.020000 | 2015-05-01 |          | certificación 2015-05-27 error -0.2%
        10 |         9 |         1 |     1.120000 | 2015-05-01 |          | certificación 2015-05-27 error -11%
        11 |         9 |         2 |     1.500000 | 2015-05-01 |          | certificación 2015-05-27 error -49% muestra muy pequeña
        12 |        10 |         1 |     1.110000 | 2015-05-01 |          | certificación 2015-05-27 error -10%
        13 |        10 |         2 |     1.020000 | 2015-05-01 |          | certificación 2015-05-27 error -2%
(18 rows)

*/


-- los habremos puesto al revés?
--update bkn_sensor_factor set factor_value=1/factor_value where sensor_id<200;

-- balanceamos accesos preservando los ingresos!!!
update bkn_sensor_factor set factor_value=1.2 where sensor_id=1 and type_code=2;
update bkn_sensor_factor set factor_value=1.1 where sensor_id=3 and type_code=2;


update bkn_sensor_factor set factor_value=1.3 where sensor_id=2 and type_code=2;
update bkn_sensor_factor set factor_value=1.4 where sensor_id=4 and type_code=2;

update bkn_sensor_factor set factor_value=1.3 where sensor_id=5 and type_code=2;
update bkn_sensor_factor set factor_value=1.4 where sensor_id=6 and type_code=2;
update bkn_sensor_factor set factor_value=1.4 where sensor_id=10 and type_code=2;

update bkn_sensor_factor set factor_value=1.2 where sensor_id=8 and type_code=2;
update bkn_sensor_factor set factor_value=1.2 where sensor_id=9 and type_code=2;

select s_id, i, o, i-o as delta, factor_i, factor_o from
(select s_id, round(avg(corrected)) as i, factor as factor_i
  from meassures natural join sensors_factors
  where s_id < 200 and s_ch = 1
  group by s_id,factor) as i
natural join
(select s_id, round(avg(corrected)) as o, factor as factor_o
  from meassures natural join sensors_factors
  where s_id < 200 and s_ch = 2
  group by s_id,factor) as o
natural join
sensors
order by delta
;




