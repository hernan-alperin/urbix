comment on view meassures is 'vista armada por joins de las mediciones de los sensores del sistema';
comment on column meassures.s_id is 'sensor_id';
comment on column meassures.s_ch is 'canal del sensor: el campo ''type_code'' de ''urbix.bkn_measure_data''';
comment on column meassures.status is 'estado del sensor: 0 ok, 1 sin conectividad, 2 (?), 3 (?), 4 cuenta por debajo delo real. ver documentadión';
comment on column meassures.timestamp is 'hora en que se inició la medición';
comment on column meassures.original is 'conteo original del sensor';
comment on column meassures.value is 'valor corregido por el sistema estático usando formula_engine()';
comment on column meassures.corrected is 'volor corregido dinámicamente. para ser usado en el modelo dinámico';

comment on view sensors is 'vista armada para acceso sencillo y significativo a los sensores del sistema';
comment on column sensors.s_id is 'sensor_id';
comment on column sensors.sensor is 'descripción del sensor. campo ''description'' de la tabla ''urbix.bkn_sensor''';
comment on column sensors.a_id is 'código de acceso asociado o donde está ubicado el snsor. ''access_code'' de la tabla ''urbix.bkn_sensor''';
comment on column sensors.b_id is 'código del branch asociado al sensor. ''branch_code'' de la tabla ''urbix.bkn_sensor''';
comment on column sensors.c_id is 'código de la company u organization asociada al sensor. ''organization_code'' de la tabla ''urbix.bkn_sensor''';

comment on view sensors_factors is 'vista armada para acceso sencillo y significativo a los factores usados para corregir las medixciones de los sensores del sistema con el registro temporal';
comment on column sensors_factors.s_id is 'sensor_id';
comment on column sensors_factors.sensor is 'descripción del sensor. campo ''description'' de la tabla ''urbix.bkn_sensor''';
comment on column sensors_factors.s_ch is 'canal del sensor: el campo ''type_code'' de ''urbix.bkn_measure_data''';
comment on column sensors_factors.factor is 'factor de corrección de la medición del sensor. ''factor_value'' de la tabla ''urbix.bkn_sensor_factor''';
comment on column sensors_factors.start_date is 'inicio del período de validez del factor de corrección. igual campo de la tabla ''urbix.bkn_sensor_factor''';
comment on column sensors_factors.end_date is 'fin del período de validez del factor de corrección. igual campo de la tabla ''urbix.bkn_sensor_factor''';
comment on column sensors_factors.comment is 'comentario explicativo del por qué del factor o su modificación. igual campo de la tabla ''urbix.bkn_sensor_factor''';

comment on view variables is 'vista armada para acceso sencillo y significativo a los ids y a los nombres de las variables';
comment on column variables.v_id is 'integer indentificador de la variable: ''variable_id'' de la tabla ''urbix.bkn_variable''';
comment on column variables.variable is 'nombre de la variable. ''description'' de la tabla ''urbix.bkn_variable''';
comment on column variables.public is 'campo ''public'' de la tabla ''urbix.bkn_variable''. no está clara su función';

comment on view variables_formulas is 'relación entre las variables y las fórmulas que se usan para calcularlas';

comment on view variables_sensors_accesses is 'relación entre las variables, los sensores y los accesos';
comment on column variables_sensors_accesses.a_id is 'identificador del acceso';
comment on view variables_sensors_branches is 'relación entre las variables, los sensores y los branches/sucursales. en este caso usado para Mall';
comment on column variables_sensors_branches.b_id is 'identificador del branch/sucursal (Mall)';
comment on view variables_sensors_companies is 'relación entre las variables, los sensores y los companies/organization. en este caso usado para Predio';
comment on column variables_sensors_companies.c_id is 'identificador de la company (Predio)';

comment on view variables_sensors is 'relación entre las variables y los sensores';

comment on view variables_estimations is 'estimaciones/cálculos dinámicos de las variables';


