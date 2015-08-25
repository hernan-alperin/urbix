CREATE OR REPLACE FUNCTION urbix.fm_access_factor(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
     r_factor real;
     r_access int4;
     r_tipo int4;
     r_time timestamp;
     r_value real;
BEGIN
    -- Las formulas deben actualizar el registro si existe o crearlo.
    -- Parametros.
    r_access := get_formula_param( p_active_formula_id, 101, null )::int4;
    r_tipo := get_formula_param( p_active_formula_id, 102, null )::int4;

    -- valido los datos y tomo el tiempo de medicion
    -- que es lo que liga las formulas con los resultados en este caso.
    select bkn_measure.measure_time into r_time
    from bkn_sensor, bkn_measure
    where
        bkn_sensor.sensor_id = p_sensor_id
        and bkn_measure.sensor_id = bkn_sensor.sensor_id
        and bkn_measure.measure_id = p_measure_id
        and bkn_sensor.access_code = r_access;
    if not found
    then
        return;
    end if;

    -- sumo todas las mediciones del tipo r_tipo y del acceso dado para un instante de medicion dado.
    select sum( bkn_measure_data.value ) into r_value
    from bkn_sensor
    join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
    join bkn_measure_data on bkn_measure_data.measure_id = bkn_measure.measure_id
    where
        bkn_sensor.access_code = r_access
        and bkn_measure.measure_time = r_time
        and bkn_measure_data.type_code = r_tipo;
    if not found
    then
        r_value := 0;
    end if;

    r_factor := get_formula_param( p_active_formula_id, 100, r_time )::real;
    r_value := r_value * r_factor;

    -- insert or update.
    lock table bkn_result;
    update bkn_result
    set data = r_value
    where
        variable_id = p_variable_id
        and time = r_time;
    if not found
    then
        insert into bkn_result( variable_id, time, data )
        values ( p_variable_id, r_time, r_value );
    end if;
END;
$function$
