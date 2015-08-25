insert into bkn_variable
(description, creation_date, end_date, branch_id, sensor_type_code, access_code, latitude, longitude, workday_start, workday_duration, sector_id, variable_type_code, public)
values
('PB Vicente Lopez McCafe acceso out', '2015-05-15 00:00:00', null, 1, 2, 1, 0.000, 0.000, '09:00:00', 14, 1, 2, true )
;

insert into bkn_active_formula
(formula_id, variable_id, creation_date, start_date, end_date)
values
(1, 33, '2015-01-01', '2015-01-01', null);
;

insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 26, 100, 1) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 26, 102, 2) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 26, 110, 0) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 26, 201, 1) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 26, 101, 2) ;

---
insert into bkn_variable
(description, creation_date, end_date, branch_id, sensor_type_code, access_code, latitude, longitude, workday_start, workday_duration, sector_id, variable_type_code, public)
values
('PB Ascensores Hall acceso out', '2015-05-15 00:00:00', null, 1, 2, 1, 0.000, 0.000, '09:00:00', 14, 1, 2, true )
;

insert into bkn_active_formula
(formula_id, variable_id, creation_date, start_date, end_date)
values
(1, 34, '2015-01-01', '2015-01-01', null);
;

select * from bkn_active_formula where variable_id=34;

insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 27, 100, 1) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 27, 102, 2) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 27, 110, 0) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 27, 201, 1) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 27, 101, 1) ;

insert into bkn_variable
(description, creation_date, end_date, branch_id, sensor_type_code, access_code, latitude, longitude, workday_start, workday_duration, sector_id, variable_type_code, public)
values
('N1 Ascensores Hall acceso out', '2015-05-15 00:00:00', null, 1, 2, 1, 0.000, 0.000, '09:00:00', 14, 1, 2, true )
;

insert into bkn_active_formula
(formula_id, variable_id, creation_date, start_date, end_date)
values
(1, 35, '2015-01-01', '2015-01-01', null);
;

select * from bkn_active_formula where variable_id=35;

insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 28, 100, 1) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 28, 102, 2) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 28, 110, 0) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 28, 201, 1) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 28, 101, 10) ;


insert into bkn_variable
(description, creation_date, end_date, branch_id, sensor_type_code, access_code, latitude, longitude, workday_start, workday_duration, sector_id, variable_type_code, public)
values
('N2 Ascensores Hall acceso out', '2015-05-15 00:00:00', null, 1, 2, 1, 0.000, 0.000, '09:00:00', 14, 1, 2, true )
;

insert into bkn_active_formula
(formula_id, variable_id, creation_date, start_date, end_date)
values
(1, 36, '2015-01-01', '2015-01-01', null);
;

insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 29, 100, 1) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 29, 102, 2) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 29, 110, 0) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 29, 201, 1) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 29, 101, 13) ;


insert into bkn_variable
(description, creation_date, end_date, branch_id, sensor_type_code, access_code, latitude, longitude, workday_start, workday_duration, sector_id, variable_type_code, public)
values
('N3 Ascensores Hall acceso out', '2015-05-15 00:00:00', null, 1, 2, 1, 0.000, 0.000, '09:00:00', 14, 1, 2, true )
;

insert into bkn_active_formula
(formula_id, variable_id, creation_date, start_date, end_date)
values
(1, 37, '2015-01-01', '2015-01-01', null);
;

insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 30, 100, 1) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 30, 102, 2) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 30, 110, 0) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 30, 201, 1) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 30, 101, 16) ;

insert into bkn_variable
(description, creation_date, end_date, branch_id, sensor_type_code, access_code, latitude, longitude, workday_start, workday_duration, sector_id, variable_type_code, public)
values
('N1 Junín puntera acceso out', '2015-05-15 00:00:00', null, 1, 2, 1, 0.000, 0.000, '09:00:00', 14, 1, 2, true )
;

insert into bkn_active_formula
(formula_id, variable_id, creation_date, start_date, end_date)
values
(1, 38, '2015-01-01', '2015-01-01', null);
;

insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 31, 100, 1) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 31, 102, 2) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 31, 110, 0) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 31, 201, 1) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 31, 101, 7) ;

insert into bkn_variable
(description, creation_date, end_date, branch_id, sensor_type_code, access_code, latitude, longitude, workday_start, workday_duration, sector_id, variable_type_code, public)
values
('N1 Uriburu puntera acceso out', '2015-05-15 00:00:00', null, 1, 2, 1, 0.000, 0.000, '09:00:00', 14, 1, 2, true )
;

insert into bkn_active_formula
(formula_id, variable_id, creation_date, start_date, end_date)
values
(1, 39, '2015-01-01', '2015-01-01', null);
;

insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 32, 100, 1) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 32, 102, 2) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 32, 110, 0) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 32, 201, 1) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 32, 101, 4) ;


insert into bkn_variable
(description, creation_date, end_date, branch_id, sensor_type_code, access_code, latitude, longitude, workday_start, workday_duration, sector_id, variable_type_code, public)
values
('Egresos totales sin no-clientes', '2015-05-15 00:00:00', null, 1, 2, 2, 0.000, 0.000, '09:00:00', 14, 1, 2, true )
;

select * from bkn_variable;

insert into bkn_active_formula
(formula_id, variable_id, creation_date, start_date, end_date)
values
(10, 40, '2015-01-01', '2015-01-01', null);
;
select * from bkn_active_formula;
select * from bkn_active_formula_param
where active_formula_id=16;



insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 33, 200, 1) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 33, 201, 1) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 33, 202, 2) ;
insert into bkn_active_formula_param (active_formula_id, formula_param_id, value) values ( 33, 210, 0) ;

-
