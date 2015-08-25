CREATE OR REPLACE FUNCTION "urbix"."fm_branch_factor_customer" 
("p_measure_id" integer, "p_sensor_id" integer, "p_formula_id" integer, "p_active_formula_id" integer, "p_variable_id" integer) RETURNS void AS $$ 
DECLARE
     r_factor real;
     r_noncustomer real;
     r_branch int4;
     r_tipo int4;
     r_time timestamp;
     r_value real;
     r_neto_preapertura real;
     r_desde_hora real;
     r_hasta_hora real;
     r_neto_s1_hora real;
   
BEGIN
    -- Las formulas deben actualizar el registro si existe o crearlo.
    -- Parametros.
    r_branch := get_formula_param( p_active_formula_id, 201, null )::int4;
    r_tipo := get_formula_param( p_active_formula_id, 202, null )::int4;

    -- valido los datos y tomo el tiempo de medicion
    -- que es lo que liga las formulas con los resultados en este caso.
    select bkn_measure.measure_time into r_time
    from bkn_sensor, bkn_measure
    where
        bkn_sensor.sensor_id = p_sensor_id
        and bkn_measure.sensor_id = bkn_sensor.sensor_id
        and bkn_measure.measure_id = p_measure_id
        and bkn_sensor.branch_code = r_branch;
    if not found
    then
        return;
    end if;

    -- Defino la ventana de pre-apertura que quiero tomar indicando hora desde y hasta.
    r_desde_hora:= '06';
    r_hasta_hora:= '09';
    
    -- Si el periodo actual r_time coincide con la hora de finalizacion del periodo de preapertura calcula el neto y lo guarda en r_neto_preapertura
    if extract(hour from r_time)= r_hasta_hora then
      select (select round(sum(value)) from bkn_measure a, bkn_measure_data b 
      where a.measure_id=b.measure_id and extract(hour from measure_time) between r_desde_hora and r_hasta_hora and date(measure_time)=date(r_time) and type_code=1
      and a.sensor_id not in (2) and a.sensor_id < 200
      group by date(measure_time)) - (select round(sum(value)) as out from bkn_measure a, bkn_measure_data b 
      where a.measure_id=b.measure_id and extract(hour from measure_time) between r_desde_hora and r_hasta_hora and date(measure_time)=date(r_time) and type_code=2
      and a.sensor_id not in (2) and a.sensor_id < 200
      group by date(measure_time)) into r_neto_preapertura
      from bkn_measure a, bkn_measure_data b 
      where a.measure_id=b.measure_id LIMIT 1;
    end if;


  -- sumo todas las mediciones del tipo r_tipo y de todos los accesos excepto el sensor 1 que corresponde a pasillos y escaleras mencanicas
    select sum( bkn_measure_data.value ) into r_value
    from bkn_sensor
    join bkn_measure using(sensor_id)
    natural join bkn_measure_data
    where
    bkn_sensor.branch_code = r_branch
    and bkn_measure.measure_time = r_time
    and bkn_measure_data.type_code = r_tipo
    and bkn_sensor.sensor_id not in (2) and bkn_sensor.sensor_id < 200
    ;

    r_noncustomer := get_formula_param(p_active_formula_id, 210, r_time )::real; -- Valor que se restara del total calculado. (no clientes)
    r_factor := get_formula_param( p_active_formula_id, 200, r_time )::real;
    r_value := (r_value * r_factor) - r_noncustomer;

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
$$
LANGUAGE "plpgsql" COST 100
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
