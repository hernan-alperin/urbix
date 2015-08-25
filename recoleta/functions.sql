--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = urbix, pg_catalog;

--
-- Name: filter_match(integer, timestamp without time zone); Type: FUNCTION; Schema: urbix; Owner: urbix
--

CREATE FUNCTION filter_match(p_filter_id integer, p_time timestamp without time zone) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    p_filter record;
BEGIN
    if p_time is null
    then
        return true;
    end if;

    for p_filter in
        select  bkn_time_filter.filter_id,
                bkn_time_filter_x_time_range.range_not,
                bkn_time_filter_x_time_range.time_range_id
        from bkn_time_filter
        join bkn_time_filter_x_time_range on bkn_time_filter.filter_id = bkn_time_filter_x_time_range.filter_id
        where bkn_time_filter.filter_id = p_filter_id
    loop
        if not range_match( p_filter.time_range_id, p_filter.range_not, p_time )
        then
            return false;
        end if;
    end loop;

    return true;
END;
$$;


ALTER FUNCTION urbix.filter_match(p_filter_id integer, p_time timestamp without time zone) OWNER TO urbix;

--
-- Name: fm_access_factor(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: urbix; Owner: urbix
--

CREATE FUNCTION fm_access_factor(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION urbix.fm_access_factor(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) OWNER TO urbix;

--
-- Name: fm_access_factor_customer(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: urbix; Owner: urbix
--

CREATE FUNCTION fm_access_factor_customer(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
     r_factor real;
	 r_noncustomer real;
	 r_access int4;
     r_tipo int4;
     r_sensor bkn_sensor;
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


	r_noncustomer := get_formula_param(p_active_formula_id, 110, r_time )::real; -- Valor que se restara del total calculado. (no clientes)
    r_factor := get_formula_param( p_active_formula_id, 100, r_time )::real;
    r_value := (r_value - r_noncustomer)* r_factor;
	
	if(r_value < 0) then
		r_value := 0;
	end if;
	
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
$$;


ALTER FUNCTION urbix.fm_access_factor_customer(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) OWNER TO urbix;

--
-- Name: fm_branch_factor(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: urbix; Owner: urbix
--

CREATE FUNCTION fm_branch_factor(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
     r_factor real;
     r_branch int4;
     r_tipo int4;
     r_sensor bkn_sensor;
     r_time timestamp;
     r_value real;
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

    -- sumo todas las mediciones del tipo r_tipo y del acceso dado para un instante de medicion dado.
    select sum( bkn_measure_data.value ) into r_value
    from bkn_sensor
    join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
    join bkn_measure_data on bkn_measure_data.measure_id = bkn_measure.measure_id
    where
        bkn_sensor.branch_code = r_branch
        and bkn_measure.measure_time = r_time
        and bkn_measure_data.type_code = r_tipo;
    if not found
    then
        r_value := 0;
    end if;



    r_factor := get_formula_param( p_active_formula_id, 200, r_time )::real;
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
$$;


ALTER FUNCTION urbix.fm_branch_factor(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) OWNER TO urbix;

--
-- Name: fm_branch_factor_customer(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: urbix; Owner: urbix
--

CREATE FUNCTION fm_branch_factor_customer(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
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
	and a.sensor_id not in(51,52,53,10,101,102,103,104,11,12,111,112,200,201,202,203,204,205) group by date(measure_time)) - (select round(sum(value)) as out from bkn_measure a, bkn_measure_data b 
	where a.measure_id=b.measure_id and extract(hour from measure_time) between r_desde_hora and r_hasta_hora and date(measure_time)=date(r_time) and type_code=2
	and a.sensor_id not in(51,52,53,10,101,102,103,104,11,12,111,112,200,201,202,203,204,205) group by date(measure_time)) into r_neto_preapertura
	from bkn_measure a, bkn_measure_data b 
	where a.measure_id=b.measure_id LIMIT 1;
    end if;


	-- sumo todas las mediciones del tipo r_tipo y de todos los accesos excepto el sensor 1 que corresponde a Puesto 1
	    select sum( bkn_measure_data.value ) into r_value
	    from bkn_sensor
	    join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
	    join bkn_measure_data on bkn_measure_data.measure_id = bkn_measure.measure_id
	    where
		bkn_sensor.branch_code = r_branch
		and bkn_measure.measure_time = r_time
		and bkn_measure_data.type_code = r_tipo
		and bkn_sensor.sensor_id not in(1,51,52,53,10,101,102,103,104,11,12,111,112,200,201,202,203,204,205);
        
	
	 if (r_tipo = 1) then -- Si el tipo de dato es IN
		-- Calcula el neto por hora (in - out) del sensor de puesto 1 y lo guarda en r_neto_hora
		select (select round(value) from bkn_measure a, bkn_measure_data b 
		where a.measure_id=b.measure_id and  measure_time= r_time and sensor_id=1 and type_code=1)  
		-(select value from bkn_measure a, bkn_measure_data b 
		where a.measure_id=b.measure_id and measure_time= r_time and sensor_id=1 and type_code=2) 
		into r_neto_s1_hora from bkn_measure a, bkn_measure_data b where a.measure_id=b.measure_id;
			
		if extract(hour from r_time)<> r_hasta_hora then
			r_value:= r_neto_s1_hora + r_value; -- INGRESOS TOTALES (Formados por los ingresos de todos los sensores + el neto de puesto 1)
		else
			if (r_neto_preapertura >= 0) then
				r_value:= r_neto_preapertura;	-- Ingreso Neto por Puesto 1, en el periodo anterior a la apertura
			else
				r_value:= 0;
			end if;	
		end if;
	else -- Si el tipo de dato es OUT
		if extract(hour from r_time)<> r_hasta_hora then	
			r_value:= r_value;  	-- EGRESOS TOTALES
		else
			r_value:=0;		-- Egresos forzados a cero, en el periodo anterior a la apertura.
		end if;	
	end if;

	if not found
    then
        r_value := 0;
    end if;

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
$$;


ALTER FUNCTION urbix.fm_branch_factor_customer(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) OWNER TO urbix;

--
-- Name: fm_branch_factor_outside(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: urbix; Owner: urbix
--

CREATE FUNCTION fm_branch_factor_outside(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
     r_factor real;
     r_branch int4;
     r_tipo int4;
     r_time timestamp;
     r_value real;
	 r_value_s1 real;
	 r_value_s3 real;
	 r_value_s5 real;
	 r_value_s72 real;
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

    -- sumo todas las mediciones del tipo r_tipo y del acceso dado para un instante de medicion dado.
	if (r_tipo = 2) then  -- Si es egreso, suma el de todos los accesos menos el del sensor 2 (walmart-shopping) y 6 que es interno (Acceso a nivel 1)
			select bkn_measure_data.value * 1 into r_value_s1 -- SENSOR 1 -OUT (Acceso Parking - Shopping)
			from bkn_sensor
			join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
			join bkn_measure_data on bkn_measure_data.measure_id = bkn_measure.measure_id
			where
				bkn_sensor.branch_code = r_branch
				and bkn_measure.measure_time = r_time
				and bkn_measure_data.type_code = r_tipo
				and bkn_sensor.sensor_id = 1; 

			select bkn_measure_data.value * 1 into r_value_s3 -- SENSOR 3 -OUT (Acceso Av. Rosas)
			from bkn_sensor
			join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
			join bkn_measure_data on bkn_measure_data.measure_id = bkn_measure.measure_id
			where
				bkn_sensor.branch_code = r_branch
				and bkn_measure.measure_time = r_time
				and bkn_measure_data.type_code = r_tipo
				and bkn_sensor.sensor_id = 3; 

			select bkn_measure_data.value * 1 into r_value_s72 -- SENSOR 7 -OUT (Acceso Av. Rosas - linea id:2)
			from bkn_sensor
			join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
			join bkn_measure_data on bkn_measure_data.measure_id = bkn_measure.measure_id
			where
				bkn_sensor.branch_code = r_branch
				and bkn_measure.measure_time = r_time
				and bkn_measure_data.type_code = r_tipo
				and bkn_sensor.sensor_id = 72; 
			

			select bkn_measure_data.value * 1 into r_value_s5 -- SENSOR 5 -OUT (Acceso Parking)
			from bkn_sensor
			join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
			join bkn_measure_data on bkn_measure_data.measure_id = bkn_measure.measure_id
			where
				bkn_sensor.branch_code = r_branch
				and bkn_measure.measure_time = r_time
				and bkn_measure_data.type_code = r_tipo
				and bkn_sensor.sensor_id = 5; 

			r_value:= r_value_s1 + r_value_s3 + r_value_s72 + r_value_s5; -- EGRESOS TOTALES	

    else -- Si es ingreso, suma a todos los accesos menos el del sensor 2 y 6  (Acceso walmart - shopping e interno al nivel 1)
	
			select bkn_measure_data.value * 1 into r_value_s1 --SENSOR 1 - IN (Acceso Parking)
				from bkn_sensor
				join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
				join bkn_measure_data on bkn_measure_data.measure_id = bkn_measure.measure_id
				where
					bkn_sensor.branch_code = r_branch
					and bkn_measure.measure_time = r_time
					and bkn_measure_data.type_code = r_tipo
					and bkn_sensor.sensor_id = 1; 
			
			select bkn_measure_data.value * 1 into r_value_s3 --SENSOR 3 - IN (Acceso Av. Rosas)
				from bkn_sensor
				join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
				join bkn_measure_data on bkn_measure_data.measure_id = bkn_measure.measure_id
				where
					bkn_sensor.branch_code = r_branch
					and bkn_measure.measure_time = r_time
					and bkn_measure_data.type_code = r_tipo
					and bkn_sensor.sensor_id = 3;		

			select bkn_measure_data.value * 1 into r_value_s72 --SENSOR 7 - IN (Acceso Av. Rosas linea id:2)
				from bkn_sensor
				join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
				join bkn_measure_data on bkn_measure_data.measure_id = bkn_measure.measure_id
				where
					bkn_sensor.branch_code = r_branch
					and bkn_measure.measure_time = r_time
					and bkn_measure_data.type_code = r_tipo
					and bkn_sensor.sensor_id = 72; 
					

			select bkn_measure_data.value * 1 into r_value_s5 -- SENSOR 5 -OUT (Acceso Parking)
			from bkn_sensor
			join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
			join bkn_measure_data on bkn_measure_data.measure_id = bkn_measure.measure_id
			where
				bkn_sensor.branch_code = r_branch
				and bkn_measure.measure_time = r_time
				and bkn_measure_data.type_code = r_tipo
				and bkn_sensor.sensor_id = 5; 
			
			r_value:= r_value_s1 + r_value_s3 + r_value_s72 + r_value_s5; -- INGRESOS TOTALES
	
	end if;	
	
	if not found
    then
        r_value := 0;
    end if;



    r_factor := get_formula_param( p_active_formula_id, 200, r_time )::real;
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
$$;


ALTER FUNCTION urbix.fm_branch_factor_outside(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) OWNER TO urbix;

--
-- Name: fm_branch_imbalance_customer(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: urbix; Owner: urbix
--

CREATE FUNCTION fm_branch_imbalance_customer(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
     r_factor real;
     r_noncustomer real;
	 r_branch int4;
     r_tipo int4;
     r_time timestamp;
     r_value real;
     r_value_in real;
     r_value_out real;
     r_value_s1 real;
     r_value_s2 real;
     r_value_s3 real;
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

    -- sumo todas las mediciones del tipo r_tipo y del acceso dado para un instante de medicion dado.
--	if (r_tipo = 2) then  -- Si es egreso, suma el de todos los accesos.
			select bkn_measure_data.value * 0.91 into r_value_s1 -- SENSOR 1 -OUT
			from bkn_sensor
			join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
			join bkn_measure_data on bkn_measure_data.measure_id = bkn_measure.measure_id
			where
				bkn_sensor.branch_code = r_branch
				and bkn_measure.measure_time = r_time
				and bkn_measure_data.type_code = 2
				and bkn_sensor.sensor_id = 1; 

			select bkn_measure_data.value * 0.92 into r_value_s2 -- SENSOR 2 -OUT 
			from bkn_sensor
			join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
			join bkn_measure_data on bkn_measure_data.measure_id = bkn_measure.measure_id
			where
				bkn_sensor.branch_code = r_branch
				and bkn_measure.measure_time = r_time
				and bkn_measure_data.type_code = 2
				and bkn_sensor.sensor_id = 2;

			select bkn_measure_data.value * 1.19 into r_value_s3 -- SENSOR 3 -OUT 
			from bkn_sensor
			join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
			join bkn_measure_data on bkn_measure_data.measure_id = bkn_measure.measure_id
			where
				bkn_sensor.branch_code = r_branch
				and bkn_measure.measure_time = r_time
				and bkn_measure_data.type_code = 2
				and bkn_sensor.sensor_id = 3; 
				
			r_value_out:= r_value_s1 + r_value_s2 + r_value_s3;  -- EGRESOS TOTALES	

--    else -- Si es ingreso, suma a todos los accesos 
	
			select bkn_measure_data.value * 0.93 into r_value_s1 --SENSOR 1 - IN 
				from bkn_sensor
				join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
				join bkn_measure_data on bkn_measure_data.measure_id = bkn_measure.measure_id
				where
					bkn_sensor.branch_code = r_branch
					and bkn_measure.measure_time = r_time
					and bkn_measure_data.type_code = 1
					and bkn_sensor.sensor_id = 1; 
			
			select bkn_measure_data.value * 1.1 into r_value_s2 --SENSOR 2 - IN 
				from bkn_sensor
				join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
				join bkn_measure_data on bkn_measure_data.measure_id = bkn_measure.measure_id
				where
					bkn_sensor.branch_code = r_branch
					and bkn_measure.measure_time = r_time
					and bkn_measure_data.type_code = 1
					and bkn_sensor.sensor_id = 2;
					
			select bkn_measure_data.value * 0.985 into r_value_s3--SENSOR 3 - IN
				from bkn_sensor
				join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
				join bkn_measure_data on bkn_measure_data.measure_id = bkn_measure.measure_id
				where
					bkn_sensor.branch_code = r_branch
					and bkn_measure.measure_time = r_time
					and bkn_measure_data.type_code = 1
					and bkn_sensor.sensor_id = 3; 
					
			r_value_in:= r_value_s1 + r_value_s2 + r_value_s3; -- INGRESOS TOTALES
	
--	end if;	
	
	if not found
    then
        r_value := 0;
    end if;

    r_noncustomer := get_formula_param(p_active_formula_id, 210, r_time )::real; -- Valor que se restara del total calculado. (no clientes)
    r_factor := get_formula_param( p_active_formula_id, 200, r_time )::real;
    r_value := (r_value_in - r_value_out - r_noncustomer) * r_factor;

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
$$;


ALTER FUNCTION urbix.fm_branch_imbalance_customer(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) OWNER TO urbix;

--
-- Name: fm_branch_random(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: urbix; Owner: urbix
--

CREATE FUNCTION fm_branch_random(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
     r_factor real;
     r_factor_min real;
     r_factor_max real;
     r_branch int4;
     r_tipo int4;
     r_sensor bkn_sensor;
     r_time timestamp;
BEGIN
    -- Las formulas deben actualizar el registro si existe o crearlo.
    -- Parametros.
    r_branch := get_formula_param( p_active_formula_id, 501, null )::int4;
    r_tipo := get_formula_param( p_active_formula_id, 502, null )::int4;

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

    r_factor_min := get_formula_param( p_active_formula_id, 503, r_time )::real;
    r_factor_max := get_formula_param( p_active_formula_id, 504, r_time )::real;
    r_factor := r_factor_min + ( r_factor_max - r_factor_min ) * random();

    -- insert or update.
    lock table bkn_result;
    update bkn_result
    set data = r_factor
    where
        variable_id = p_variable_id
        and time = r_time;
    if not found
    then
        insert into bkn_result( variable_id, time, data )
        values ( p_variable_id, r_time, r_factor );
    end if;
END;
$$;


ALTER FUNCTION urbix.fm_branch_random(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) OWNER TO urbix;

--
-- Name: fm_branch_random_factor(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: urbix; Owner: urbix
--

CREATE FUNCTION fm_branch_random_factor(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
     r_factor real;
     r_factor_min real;
     r_factor_max real;
     r_branch int4;
     r_tipo int4;
     r_sensor bkn_sensor;
     r_time timestamp;
     r_value real;
BEGIN
    -- Las formulas deben actualizar el registro si existe o crearlo.
    -- Parametros.
    r_branch := get_formula_param( p_active_formula_id, 401, null )::int4;
    r_tipo := get_formula_param( p_active_formula_id, 402, null )::int4;

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

    -- sumo todas las mediciones del tipo r_tipo y del acceso dado para un instante de medicion dado.
    select sum( bkn_measure_data.value ) into r_value
    from bkn_sensor
    join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
    join bkn_measure_data on bkn_measure_data.measure_id = bkn_measure.measure_id
    where
        bkn_sensor.branch_code = r_branch
        and bkn_measure.measure_time = r_time
        and bkn_measure_data.type_code = r_tipo;
    if not found
    then
        r_value := 0;
    end if;



    r_factor_min := get_formula_param( p_active_formula_id, 403, r_time )::real;
    r_factor_max := get_formula_param( p_active_formula_id, 404, r_time )::real;
    r_factor := r_factor_min + ( r_factor_max - r_factor_min ) * random();
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
$$;


ALTER FUNCTION urbix.fm_branch_random_factor(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) OWNER TO urbix;

--
-- Name: fm_company_factor(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: urbix; Owner: urbix
--

CREATE FUNCTION fm_company_factor(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
     r_factor real;
     r_company int4;
     r_tipo int4;
     r_sensor bkn_sensor;
     r_time timestamp;
     r_value real;
BEGIN
    -- Las formulas deben actualizar el registro si existe o crearlo.
    -- Parametros.
    r_company := 1; -- ID 1 es siempre la company por default. Actualmente se utiliza una DB por company, lo cual este id, es siempre 1.
    r_tipo := get_formula_param( p_active_formula_id, 202, null )::int4;

    -- valido los datos y tomo el tiempo de medicion
    -- que es lo que liga las formulas con los resultados en este caso.
    select bkn_measure.measure_time into r_time
    from bkn_sensor, bkn_measure
    where
        bkn_sensor.sensor_id = p_sensor_id
        and bkn_measure.sensor_id = bkn_sensor.sensor_id
        and bkn_measure.measure_id = p_measure_id
        and bkn_sensor.organization_code = r_company;
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
        bkn_sensor.organization_code = r_company
        and bkn_measure.measure_time = r_time
        and bkn_measure_data.type_code = r_tipo;
    if not found
    then
        r_value := 0;
    end if;

    r_factor := get_formula_param( p_active_formula_id, 200, r_time )::real;
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
$$;


ALTER FUNCTION urbix.fm_company_factor(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) OWNER TO urbix;

--
-- Name: fm_factor(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: urbix; Owner: urbix
--

CREATE FUNCTION fm_factor(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
     r_factor real;
     r_acceso int4;
     r_tipo int4;
     r_sensor bkn_sensor;
     r_time timestamp;
     r_value real;
BEGIN
    -- Las formulas deben actualizar el registro si existe o crearlo.
    -- Parametros.
    r_acceso := get_formula_param( p_active_formula_id, 101, null )::int4;
    r_tipo := get_formula_param( p_active_formula_id, 102, null )::int4;

    -- valido los datos y tomo el tiempo de medicion
    -- que es lo que liga las formulas con los resultados en este caso.
    select bkn_measure.measure_time, bkn_measure_data.value into r_time, r_value
    from bkn_sensor, bkn_measure, bkn_measure_data
    where
        bkn_sensor.sensor_id = p_sensor_id
        and bkn_measure.sensor_id = bkn_sensor.sensor_id
        and bkn_measure.measure_id = p_measure_id
        and access_code = r_acceso
        and bkn_measure_data.measure_id = bkn_measure.measure_id
        and bkn_measure_data.type_code = r_tipo;
    if not found
    then
        return;
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
$$;


ALTER FUNCTION urbix.fm_factor(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) OWNER TO urbix;

--
-- Name: fm_ocupation(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: urbix; Owner: urbix
--

CREATE FUNCTION fm_ocupation(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
     r_factor real;
     r_set real;
     r_branch int4;
     r_sensor bkn_sensor;
     r_time timestamp;
     r_curr_ocupation real;
     r_result bkn_result;
     r_delta_ocupation real;
     r_refresh boolean;
BEGIN
    r_branch := get_formula_param( p_active_formula_id, 301, null )::int4;

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

    lock table bkn_result;

    -- obtengo la ocupacion anterior.
    SELECT bkn_result.data INTO r_curr_ocupation
    from bkn_result
    WHERE bkn_result.result_id =
        (
            select max( b.result_id )
            from bkn_result b
            where b.variable_id = p_variable_id
            and b.time < r_time
        );
    if not found
    then
        r_curr_ocupation := 0;
    end if;

    r_set := get_formula_param( p_active_formula_id, 304, r_time )::real;
    if r_set is not null and r_set != 0 
    then
        r_curr_ocupation := r_set;
    else
        r_factor := get_formula_param( p_active_formula_id, 300, r_time )::real;
    -- delta ocupacion
        select bool_or( bkn_measure.refresh ), sum( sum_measure( p_active_formula_id, bkn_measure_data.*, bkn_measure.* ) )
        into  r_refresh, r_delta_ocupation
        from bkn_sensor
        join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
        join bkn_measure_data on bkn_measure.measure_id = bkn_measure_data.measure_id
        where bkn_sensor.branch_code = r_branch
        and bkn_measure.measure_time = r_time; -- el vinculo sigue siendo el tiempo de medicion.

        r_curr_ocupation := ( r_curr_ocupation + r_delta_ocupation ) * r_factor;
    end if;

    -- tengo que recalcular todas las ocupaciones de aca en mas.
    -- primero la actual ( insert or update ).
    update bkn_result
    set data = r_curr_ocupation
    where
        variable_id = p_variable_id
        and time = r_time;
    if not found
    then
        insert into bkn_result( variable_id, time, data )
        values ( p_variable_id, r_time, r_curr_ocupation );
    end if;

    -- ahora actualizo las ocupaciones siguientes
    for r_result in
        select *
        from bkn_result
        where variable_id = p_variable_id
        and time > r_time
        order by time asc
    loop

        -- delta ocupacion
        select bool_or( bkn_measure.refresh ), sum( sum_measure( p_active_formula_id, bkn_measure_data.*, bkn_measure.* ) )
        into  r_refresh, r_delta_ocupation
        from bkn_sensor
        join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
        join bkn_measure_data on bkn_measure.measure_id = bkn_measure_data.measure_id
        where bkn_sensor.branch_code = r_branch
        and bkn_measure.measure_time = r_time; -- el vinculo sigue siendo el tiempo de medicion.

-- corto si encuentro un refresh, esto es por que el engine va a volver a 
-- llamar a esta funcion despues para que refresque de ahi en mas
-- asi que no hago la cuenta dos veces!!!.
        if r_refresh
        then
            return;
        end if;

        r_set := get_formula_param( p_active_formula_id, 304, r_time )::real;
        if r_set is not null and r_set != 0 
        then
            r_curr_ocupation := r_set;
        else
            r_factor := get_formula_param( p_active_formula_id, 300, r_result.time )::real;
            r_curr_ocupation := ( r_curr_ocupation + r_delta_ocupation ) * r_factor;
        end if;

        update bkn_result
        set data = r_curr_ocupation
        where
            variable_id = r_result.variable_id
            and time = r_result.time;
    end loop;
END;
$$;


ALTER FUNCTION urbix.fm_ocupation(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) OWNER TO urbix;

--
-- Name: fm_ocupation_customer(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: urbix; Owner: urbix
--

CREATE FUNCTION fm_ocupation_customer(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
     r_factor real;
 	 r_set real;
     r_branch int4;
     r_sensor bkn_sensor;
     r_time timestamp;
     r_curr_ocupation real;
     r_result bkn_result;
     r_delta_ocupation real;
     r_refresh boolean;
BEGIN
    r_branch := get_formula_param( p_active_formula_id, 301, null )::int4;

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

    lock table bkn_result;

    -- obtengo la ocupacion anterior.
    SELECT bkn_result.data INTO r_curr_ocupation
    from bkn_result
    WHERE bkn_result.result_id =
        (
            select max( b.result_id )
            from bkn_result b
            where b.variable_id = p_variable_id
            and b.time < r_time
        );
    if not found
    then
        r_curr_ocupation := 0;
    end if;

    r_set := get_formula_param( p_active_formula_id, 304, r_time )::real;
    if r_set is not null and r_set != 0 
    then
        r_curr_ocupation := r_set;
    else
        r_factor := get_formula_param( p_active_formula_id, 300, r_time )::real;
    -- delta ocupacion
        select bool_or( bkn_measure.refresh ), sum( sum_measure_customer( p_active_formula_id, bkn_measure_data.*, bkn_measure.* ) )
        into  r_refresh, r_delta_ocupation
        from bkn_sensor
        join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
        join bkn_measure_data on bkn_measure.measure_id = bkn_measure_data.measure_id
        where bkn_sensor.branch_code = r_branch
        and bkn_measure.measure_time = r_time; -- el vinculo sigue siendo el tiempo de medicion.

        r_curr_ocupation := ( r_curr_ocupation + r_delta_ocupation ) * r_factor;
    end if;

    -- tengo que recalcular todas las ocupaciones de aca en mas.
    -- primero la actual ( insert or update ).
    update bkn_result
    set data = r_curr_ocupation
    where
        variable_id = p_variable_id
        and time = r_time;
    if not found
    then
        insert into bkn_result( variable_id, time, data )
        values ( p_variable_id, r_time, r_curr_ocupation );
    end if;

    -- ahora actualizo las ocupaciones siguientes
    for r_result in
        select *
        from bkn_result
        where variable_id = p_variable_id
        and time > r_time
        order by time asc
    loop

        -- delta ocupacion
        select bool_or( bkn_measure.refresh ), sum( sum_measure_customer( p_active_formula_id, bkn_measure_data.*, bkn_measure.* ) )
        into  r_refresh, r_delta_ocupation
        from bkn_sensor
        join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
        join bkn_measure_data on bkn_measure.measure_id = bkn_measure_data.measure_id
        where bkn_sensor.branch_code = r_branch
        and bkn_measure.measure_time = r_time; -- el vinculo sigue siendo el tiempo de medicion.

-- corto si encuentro un refresh, esto es por que el engine va a volver a 
-- llamar a esta funcion despues para que refresque de ahi en mas
-- asi que no hago la cuenta dos veces!!!.
        if r_refresh
        then
            return;
        end if;

        r_set := get_formula_param( p_active_formula_id, 304, r_time )::real;
        if r_set is not null and r_set != 0 
        then
            r_curr_ocupation := r_set;
        else
            r_factor := get_formula_param( p_active_formula_id, 300, r_result.time )::real;
            r_curr_ocupation := ( r_curr_ocupation + r_delta_ocupation ) * r_factor;
        end if;

        update bkn_result
        set data = r_curr_ocupation
        where
            variable_id = r_result.variable_id
            and time = r_result.time;
    end loop;
END;
$$;


ALTER FUNCTION urbix.fm_ocupation_customer(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) OWNER TO urbix;

--
-- Name: fm_ocupation_random(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: urbix; Owner: urbix
--

CREATE FUNCTION fm_ocupation_random(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
     r_factor real;
     r_set real;
     r_branch int4;
     r_sensor bkn_sensor;
     r_time timestamp;
     r_curr_ocupation real;
     r_result bkn_result;
     r_delta_ocupation real;
     r_refresh boolean;
     r_factor_min real;
     r_factor_max real;
     r_rand_factor real;
BEGIN
    r_branch := get_formula_param( p_active_formula_id, 301, null )::int4;

    r_factor_min := get_formula_param( p_active_formula_id, 603, r_time )::real;
    r_factor_max := get_formula_param( p_active_formula_id, 604, r_time )::real;
    r_rand_factor := r_factor_min + ( r_factor_max - r_factor_min ) * random(); 
    
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

    lock table bkn_result;

    -- obtengo la ocupacion anterior.
    SELECT bkn_result.data INTO r_curr_ocupation
    from bkn_result
    WHERE bkn_result.result_id =
        (
            select max( b.result_id )
            from bkn_result b
            where b.variable_id = 3 -- Para que tomé la ocupación principal
            and b.time < r_time
        );
    if not found
    then
        r_curr_ocupation := 0;
    end if;

    r_set := get_formula_param( p_active_formula_id, 304, r_time )::real;
    if r_set is not null and r_set != 0 
    then
        r_curr_ocupation := r_set;
    else
        r_factor := get_formula_param( p_active_formula_id, 300, r_time )::real;
    -- delta ocupacion
        select bool_or( bkn_measure.refresh ), sum( sum_measure( p_active_formula_id, bkn_measure_data.*, bkn_measure.* ) )
        into  r_refresh, r_delta_ocupation
        from bkn_sensor
        join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
        join bkn_measure_data on bkn_measure.measure_id = bkn_measure_data.measure_id
        where bkn_sensor.branch_code = r_branch
        and bkn_measure.measure_time = r_time; -- el vinculo sigue siendo el tiempo de medicion.

        r_curr_ocupation := ( r_curr_ocupation + r_delta_ocupation ) * r_factor;
    end if;

    -- tengo que recalcular todas las ocupaciones de aca en mas.
    -- primero la actual ( insert or update ).
    update bkn_result
    set data = ( r_curr_ocupation * r_rand_factor )
    where
        variable_id = p_variable_id
        and time = r_time;
    if not found
    then
        insert into bkn_result( variable_id, time, data )
        values ( p_variable_id, r_time, r_curr_ocupation * r_rand_factor );
    end if;

    -- ahora actualizo las ocupaciones siguientes
    for r_result in
        select *
        from bkn_result
        where variable_id = p_variable_id
        and time > r_time
        order by time asc
    loop

        -- delta ocupacion
        select bool_or( bkn_measure.refresh ), sum( sum_measure( p_active_formula_id, bkn_measure_data.*, bkn_measure.* ) )
        into  r_refresh, r_delta_ocupation
        from bkn_sensor
        join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
        join bkn_measure_data on bkn_measure.measure_id = bkn_measure_data.measure_id
        where bkn_sensor.branch_code = r_branch
        and bkn_measure.measure_time = r_time; -- el vinculo sigue siendo el tiempo de medicion.

-- corto si encuentro un refresh, esto es por que el engine va a volver a 
-- llamar a esta funcion despues para que refresque de ahi en mas
-- asi que no hago la cuenta dos veces!!!.
        if r_refresh
        then
            return;
        end if;

        r_set := get_formula_param( p_active_formula_id, 304, r_time )::real;
        if r_set is not null and r_set != 0 
        then
            r_curr_ocupation := r_set;
        else
            r_factor := get_formula_param( p_active_formula_id, 300, r_result.time )::real;
            r_curr_ocupation := ( r_curr_ocupation + r_delta_ocupation ) * r_factor;
        end if;

        update bkn_result
        set data = ( r_curr_ocupation * r_rand_factor )
        where
            variable_id = r_result.variable_id
            and time = r_result.time;
    end loop;
END;
$$;


ALTER FUNCTION urbix.fm_ocupation_random(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) OWNER TO urbix;

--
-- Name: fm_ocupation_real(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: urbix; Owner: urbix
--

CREATE FUNCTION fm_ocupation_real(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
     r_factor real;
     r_set real;
     r_branch int4;
     r_sensor bkn_sensor;
     r_time timestamp;
     r_curr_ocupation real;
     r_result bkn_result;
     r_delta_ocupation real;
     r_refresh boolean;
BEGIN
    r_branch := get_formula_param( p_active_formula_id, 301, null )::int4;

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

    lock table bkn_result;

    -- obtengo la ocupacion anterior.
    SELECT bkn_result.data INTO r_curr_ocupation
    from bkn_result
    WHERE bkn_result.result_id =
        (
            select max( b.result_id )
            from bkn_result b
            where b.variable_id = p_variable_id
            and b.time < r_time
        );
    if not found
    then
        r_curr_ocupation := 0;
    end if;

    r_set := get_formula_param( p_active_formula_id, 304, r_time )::real;
    if r_set is not null and r_set != 0 
    then
        r_curr_ocupation := r_set;
    else
        r_factor := get_formula_param( p_active_formula_id, 300, r_time )::real;
    -- delta ocupacion
        select bool_or( bkn_measure.refresh ), sum( sum_measure( p_active_formula_id, bkn_measure_data.*, bkn_measure.* ) )
        into  r_refresh, r_delta_ocupation
        from bkn_sensor
        join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
        join bkn_measure_data on bkn_measure.measure_id = bkn_measure_data.measure_id
        where bkn_sensor.branch_code = r_branch
        and bkn_measure.measure_time = r_time; -- el vinculo sigue siendo el tiempo de medicion.

        r_curr_ocupation := ( r_curr_ocupation + r_delta_ocupation ) * r_factor;
    end if;


-- VALIDO QUE LA OCUPACION NO SEA NEGATIVA
    if r_curr_ocupation < 0
    then 
        r_curr_ocupation := 0;
    end if;

    -- tengo que recalcular todas las ocupaciones de aca en mas.
    -- primero la actual ( insert or update ).
    update bkn_result
    set data = r_curr_ocupation
    where
        variable_id = p_variable_id
        and time = r_time;
    if not found
    then
        insert into bkn_result( variable_id, time, data )
        values ( p_variable_id, r_time, r_curr_ocupation );
    end if;

    -- ahora actualizo las ocupaciones siguientes
    for r_result in
        select *
        from bkn_result
        where variable_id = p_variable_id
        and time > r_time
        order by time asc
    loop

        -- delta ocupacion
        select bool_or( bkn_measure.refresh ), sum( sum_measure( p_active_formula_id, bkn_measure_data.*, bkn_measure.* ) )
        into  r_refresh, r_delta_ocupation
        from bkn_sensor
        join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
        join bkn_measure_data on bkn_measure.measure_id = bkn_measure_data.measure_id
        where bkn_sensor.branch_code = r_branch
        and bkn_measure.measure_time = r_time; -- el vinculo sigue siendo el tiempo de medicion.

-- corto si encuentro un refresh, esto es por que el engine va a volver a 
-- llamar a esta funcion despues para que refresque de ahi en mas
-- asi que no hago la cuenta dos veces!!!.
        if r_refresh
        then
            return;
        end if;

        r_set := get_formula_param( p_active_formula_id, 304, r_time )::real;
        if r_set is not null and r_set != 0 
        then
            r_curr_ocupation := r_set;
        else
            r_factor := get_formula_param( p_active_formula_id, 300, r_result.time )::real;
            r_curr_ocupation := ( r_curr_ocupation + r_delta_ocupation ) * r_factor;
        end if;

-- VALIDO QUE LA OCUPACION NO SEA NEGATIVA
        if r_curr_ocupation < 0
        then 
            r_curr_ocupation := 0;
        end if;


        update bkn_result
        set data = r_curr_ocupation
        where
            variable_id = r_result.variable_id
            and time = r_result.time;
    end loop;
END;
$$;


ALTER FUNCTION urbix.fm_ocupation_real(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) OWNER TO urbix;

--
-- Name: fm_ocupation_real_customer(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: urbix; Owner: urbix
--

CREATE FUNCTION fm_ocupation_real_customer(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
     r_factor real;
	 r_set real;
     r_branch int4;
     r_sensor bkn_sensor;
     r_time timestamp;
     r_curr_ocupation real;
     r_result bkn_result;
     r_delta_ocupation real;
     r_refresh boolean;
     r_desde_hora real;
     r_hasta_hora real;
     r_neto_preapertura real;
BEGIN

	-- Defino el periodo de pre-apertura
	r_desde_hora := '06';
	r_hasta_hora := '09';
	
    r_branch := get_formula_param( p_active_formula_id, 301, null )::int4;

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

    lock table bkn_result;

    -- obtengo la ocupacion anterior.
    SELECT bkn_result.data INTO r_curr_ocupation
    from bkn_result
    WHERE bkn_result.time =
        (
            select max( b.time )
            from bkn_result b
            where b.variable_id = p_variable_id
            and b.time < r_time
        ) AND bkn_result.variable_id = p_variable_id;
    if not found
    then
        r_curr_ocupation := 0;
    end if;

    r_set := get_formula_param( p_active_formula_id, 304, r_time )::real;
    if r_set is not null and r_set != 0 
    then
        r_curr_ocupation := r_set;
    else
        r_factor := get_formula_param( p_active_formula_id, 300, r_time )::real;
    -- delta ocupacion
        if extract(hour from r_time) not between r_desde_hora and r_hasta_hora then -- Si esta en el per�odo de pre-apertura calcula la ocupacion sin usar factores
		select bool_or( bkn_measure.refresh ), sum( sum_measure_customer( p_active_formula_id, bkn_measure_data.*, bkn_measure.* ) ) -- Utiliza esta funcion para el calculo con los parametros 310 y 320
		into  r_refresh, r_delta_ocupation
		from bkn_sensor
		join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
		join bkn_measure_data on bkn_measure.measure_id = bkn_measure_data.measure_id
		where bkn_sensor.branch_code = r_branch 
		and bkn_measure.sensor_id not in(51,52,53,10,101,102,103,104,11,12,111,112,200,201,202,203,204,205)
		and bkn_measure.measure_time = r_time; -- el vinculo sigue siendo el tiempo de medicion.
	else
		select bool_or( bkn_measure.refresh ), sum( sum_measure( p_active_formula_id, bkn_measure_data.*, bkn_measure.* ) ) -- Utiliza esta funcion para el calculo con los parametros 310 y 320
		into  r_refresh, r_delta_ocupation
		from bkn_sensor
		join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
		join bkn_measure_data on bkn_measure.measure_id = bkn_measure_data.measure_id
		where bkn_sensor.branch_code = r_branch
		and bkn_measure.sensor_id not in(51,52,53,10,101,102,103,104,11,12,111,112,200,201,202,203,204,205)
		and bkn_measure.measure_time = r_time; -- el vinculo sigue siendo el tiempo de medicion.
	end if;

		-- Si el periodo actual r_time coincide con la hora de finalizacion del periodo de preapertura calcula el neto y lo guarda en r_neto_preapertura
	    if extract(hour from r_time)= r_hasta_hora then
		select (select round(sum(value)) from bkn_measure a, bkn_measure_data b 
		where a.measure_id=b.measure_id and extract(hour from measure_time) between r_desde_hora and r_hasta_hora and date(measure_time)=date(r_time) and type_code=1
		and sensor_id not in(51,52,53,10,101,102,103,104,11,12,111,112,200,201,202,203,204,205) group by date(measure_time)) - (select round(sum(value)) as out from bkn_measure a, bkn_measure_data b 
		where a.measure_id=b.measure_id and extract(hour from measure_time) between r_desde_hora and r_hasta_hora and date(measure_time)=date(r_time) and type_code=2
		and sensor_id not in(51,52,53,10,101,102,103,104,11,12,111,112,200,201,202,203,204,205) group by date(measure_time)) into r_neto_preapertura
		from bkn_measure a, bkn_measure_data b 
		where a.measure_id=b.measure_id LIMIT 1;

		r_curr_ocupation := r_neto_preapertura;
	    else
		r_curr_ocupation := ( r_curr_ocupation + r_delta_ocupation ) * r_factor;	    	
	    end if;

    end if;


-- VALIDO QUE LA OCUPACION NO SEA NEGATIVA
    if r_curr_ocupation < 0
    then 
        r_curr_ocupation := 0;
    end if;

    -- tengo que recalcular todas las ocupaciones de aca en mas.
    -- primero la actual ( insert or update ).
    update bkn_result
    set data = r_curr_ocupation
    where
        variable_id = p_variable_id
        and time = r_time;
    if not found
    then
        insert into bkn_result( variable_id, time, data )
        values ( p_variable_id, r_time, r_curr_ocupation );
    end if;

    -- ahora actualizo las ocupaciones siguientes
    for r_result in
        select *
        from bkn_result
        where variable_id = p_variable_id
        and time > r_time
        order by time asc
    loop

        -- delta ocupacion
        if extract(hour from r_time) not between r_desde_hora and r_hasta_hora then -- Si esta en el periodo de pre-apertura calcula la ocupacion sin usar factores
		select bool_or( bkn_measure.refresh ), sum( sum_measure_customer( p_active_formula_id, bkn_measure_data.*, bkn_measure.* ) ) -- Utiliza esta funcion para el calculo con los parametros 310 y 320
		into  r_refresh, r_delta_ocupation
		from bkn_sensor
		join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
		join bkn_measure_data on bkn_measure.measure_id = bkn_measure_data.measure_id
		where bkn_sensor.branch_code = r_branch
		and bkn_measure.sensor_id not in(51,52,53,10,101,102,103,104,11,12,111,112,200,201,202,203,204,205)
		and bkn_measure.measure_time = r_time; -- el vinculo sigue siendo el tiempo de medicion.
	else
		select bool_or( bkn_measure.refresh ), sum( sum_measure( p_active_formula_id, bkn_measure_data.*, bkn_measure.* ) ) -- Utiliza esta funcion para el calculo con los parametros 310 y 320
		into  r_refresh, r_delta_ocupation
		from bkn_sensor
		join bkn_measure on bkn_measure.sensor_id = bkn_sensor.sensor_id
		join bkn_measure_data on bkn_measure.measure_id = bkn_measure_data.measure_id
		where bkn_sensor.branch_code = r_branch
		and bkn_measure.sensor_id not in(51,52,53,10,101,102,103,104,11,12,111,112,200,201,202,203,204,205)
		and bkn_measure.measure_time = r_time; -- el vinculo sigue siendo el tiempo de medicion.
	end if;

-- corto si encuentro un refresh, esto es por que el engine va a volver a 
-- llamar a esta funcion despues para que refresque de ahi en mas
-- asi que no hago la cuenta dos veces!!!.
        if r_refresh
        then
            return;
        end if;

        r_set := get_formula_param( p_active_formula_id, 304, r_time )::real;
        if r_set is not null and r_set != 0 
        then
            r_curr_ocupation := r_set;
        else
            r_factor := get_formula_param( p_active_formula_id, 300, r_result.time )::real;
		-- Si el periodo actual r_time coincide con la hora de finalizacion del periodo de preapertura calcula el neto y lo guarda en r_neto_preapertura
	    if extract(hour from r_time)= r_hasta_hora then
		select (select round(sum(value)) from bkn_measure a, bkn_measure_data b 
		where a.measure_id=b.measure_id and extract(hour from measure_time) between r_desde_hora and r_hasta_hora and date(measure_time)=date(r_time) and type_code=1 
		and sensor_id not in(51,52,53,10,101,102,103,104,11,12,111,112,200,201,202,203,204,205) group by date(measure_time)) - (select round(sum(value)) as out from bkn_measure a, bkn_measure_data b 
		where a.measure_id=b.measure_id and extract(hour from measure_time) between r_desde_hora and r_hasta_hora and date(measure_time)=date(r_time) and type_code=2
		and sensor_id not in(51,52,53,10,101,102,103,104,11,12,111,112,200,201,202,203,204,205) group by date(measure_time)) into r_neto_preapertura
		from bkn_measure a, bkn_measure_data b 
		where a.measure_id=b.measure_id LIMIT 1;

		r_curr_ocupation := r_neto_preapertura;
	    else
		r_curr_ocupation := ( r_curr_ocupation + r_delta_ocupation ) * r_factor;	    	
	    end if;

        end if;

-- VALIDO QUE LA OCUPACION NO SEA NEGATIVA
        if r_curr_ocupation < 0
        then 
            r_curr_ocupation := 0;
        end if;


        update bkn_result
        set data = r_curr_ocupation
        where
            variable_id = r_result.variable_id
            and time = r_result.time;
    end loop;
END;
$$;


ALTER FUNCTION urbix.fm_ocupation_real_customer(p_measure_id integer, p_sensor_id integer, p_formula_id integer, p_active_formula_id integer, p_variable_id integer) OWNER TO urbix;

--
-- Name: formula_engine(); Type: FUNCTION; Schema: urbix; Owner: urbix
--

CREATE FUNCTION formula_engine() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    r_measure bkn_measure;
    r_formula record;
    r_sql varchar;
    r_done boolean;
BEGIN
-- mediciones realizadas, las ordeno desde la mas vieja hacia la mas nueva, asi las formulas pueden tener en cuenta este orden.
    <<measure_label>>
    FOR r_measure
    IN 
        select *
        from bkn_measure
        where refresh = true
        order by bkn_measure.measure_time asc
        for update
    LOOP
        r_done := true;
-- formulas activas al momento de creacion de la medicion.
        <<formula_label>>
        FOR r_formula
        IN
            select bkn_active_formula.active_formula_id, bkn_active_formula.variable_id,
                    bkn_formula.formula_id, bkn_formula.class
            from bkn_active_formula
            join bkn_formula on bkn_active_formula.formula_id = bkn_formula.formula_id
            where bkn_active_formula.start_date <= r_measure.measure_time
            and ( bkn_active_formula.end_date is null or bkn_active_formula.end_date >= r_measure.measure_time )
        LOOP
            begin
                r_sql := 'select ' || r_formula.class
                        || '( '
                        || r_measure.measure_id || ' , '
                        || r_measure.sensor_id || ' , '
                        || r_formula.formula_id || ' , '
                        || r_formula.active_formula_id || ' , '
                        || r_formula.variable_id
                        || ' );';
                -- Las formulas deben actualizar el registro si existe o crearlo.
                --raise notice 'SQL : %', r_sql;
                execute r_sql;
             exception
                when others then
                   r_done := false;
                   INSERT INTO ums_log ( type_code, msg )
                    VALUES ( SQLSTATE, SQLERRM );
                   raise notice 'SQL : %', r_sql;
             end;
        END LOOP formula_label;

--        r_done := false;
        if r_done
        then
            update bkn_measure
            set refresh = false
            where bkn_measure.measure_id = r_measure.measure_id;
        end if;
    END LOOP measure_label;
END;
$$;


ALTER FUNCTION urbix.formula_engine() OWNER TO urbix;

--
-- Name: get_formula_param(integer, integer, timestamp without time zone); Type: FUNCTION; Schema: urbix; Owner: urbix
--

CREATE FUNCTION get_formula_param(p_active_formula_id integer, p_formula_param_id integer, p_time timestamp without time zone) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    r_ret varchar;
    r_active_formula_param_id int4;
    r_filter bkn_active_formula_param_x_time_filter;
BEGIN

    -- consigo el id del parametro de la formula para la formula activa y el valor.
    select value, active_formula_param_id into r_ret, r_active_formula_param_id
    from bkn_active_formula_param
    where
        active_formula_id = p_active_formula_id
        and formula_param_id = p_formula_param_id;
    if not found
    then
        r_ret := null;
    end if;

    -- aplico un filtro si existe, el de mayor prioridad manda.
    if p_time is not null
    then
        for r_filter 
        in  select *
            from bkn_active_formula_param_x_time_filter
            where bkn_active_formula_param_x_time_filter.active_formula_param_id = r_active_formula_param_id
            order by priority desc
        loop
            if filter_match( r_filter.filter_id, p_time )
            then
                return r_filter.value;
            end if;
        end loop;
    end if;

    if r_ret is null
    then
        select value into r_ret
        from bkn_active_formula, bkn_formula_param
        where
            bkn_active_formula.active_formula_id = p_active_formula_id
            and bkn_active_formula.formula_id = bkn_formula_param.formula_id
            and bkn_formula_param.param_id = p_formula_param_id;
        if not found
        then
            raise exception 'parameter % not found for active_formula %' , p_formula_param_id, p_active_formula_id;
        end if;
        if r_ret is null
        then
            raise exception 'parameter % must be declared in bkn_active_formula_param for active_formula %' , p_formula_param_id, p_active_formula_id;
        end if;
    end if;
    return r_ret;
END;
$$;


ALTER FUNCTION urbix.get_formula_param(p_active_formula_id integer, p_formula_param_id integer, p_time timestamp without time zone) OWNER TO urbix;

--
-- Name: measure_calibrated(); Type: FUNCTION; Schema: urbix; Owner: urbix
--

CREATE FUNCTION measure_calibrated() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    p_sensor_id int4;
    r_factor_sensor real;
BEGIN
 	-- Obtengo el id de sensor y lo guardo en p_sensor_id
	select sensor_id into p_sensor_id  
	from bkn_measure
	where measure_id = NEW.measure_id;

	-- Con el id de sensor y el tipo de dato (IN=1 o OUT=2) de la tabla bkn_sensor_factor obtengo el factor correcto a aplicar a la medicion
	select factor_value into r_factor_sensor 
	from bkn_sensor_factor 
	where sensor_id = p_sensor_id and
	type_code= NEW.type_code and
	end_date IS NULL;
	if not found then
		r_factor_sensor := 1;
	end if;
		
	-- Para mantener compatibilidad con todo, en el campo 'original_value' guardo la medición original del sensor y en 'value' la medición calibrada (pasada por el factor)
	NEW.original_value := NEW.value;
	NEW.value := NEW.value * r_factor_sensor;
	
	return NEW;
END;
$$;


ALTER FUNCTION urbix.measure_calibrated() OWNER TO urbix;

--
-- Name: FUNCTION measure_calibrated(); Type: COMMENT; Schema: urbix; Owner: urbix
--

COMMENT ON FUNCTION measure_calibrated() IS 'Toma el valor original medido por el sensor, le aplica un ''factor de calibracion'' y lo escribe en una nueva columna ''value_calib''';


--
-- Name: range_match(integer, boolean, timestamp without time zone); Type: FUNCTION; Schema: urbix; Owner: urbix
--

CREATE FUNCTION range_match(p_range_id integer, p_range_not boolean, p_time timestamp without time zone) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    p_range record;
    p_data timestamp;
    p_from timestamp;
    p_to timestamp;
    p_fixed timestamp;
BEGIN
    p_fixed := '0001-01-01 00:00:00.000';

    select bkn_time_range.* into p_range
    from  bkn_time_range
    where bkn_time_range.time_range_id = p_range_id;
    if not found
    then
        return false;
    end if;


    if p_range.presicion = 'holiday'
    then
        -- Esto es malisimo, holiday en vez de ser un boolean es un string.
        perform 1
        from ftn_time_period
        where ftn_time_period.holiday = 'S'
        and date_trunc( 'day', ftn_time_period.date ) = date_trunc( 'day', p_time );
        if ( not p_range_not and not found ) or ( p_range_not and found )
        then
            return false;
        end if;
    else

        p_data := p_time;
        if p_range.presicion is not null
        then
            p_data := date_trunc( p_range.presicion, p_data );
        end if;

        if p_range.repeat is not null
        then
            p_data := p_data - date_trunc( p_range.repeat, p_data ) + p_fixed;
        end if;

        p_from := p_range.r_from;
        if p_from is not null
        then
            if p_range.presicion is not null
            then
                p_from := date_trunc( p_range.presicion, p_from );
            end if;
            if p_range.repeat is not null
            then
                p_from := p_from - date_trunc( p_range.repeat, p_from ) + p_fixed;
            end if;
        end if;

        p_to := p_range.r_to;
        if p_to is not null
        then
            if p_range.presicion is not null
            then
                p_to := date_trunc( p_range.presicion, p_to );
            end if;
            if p_range.repeat is not null
            then
                -- aca hay un problema cuando repeat es week, como el limite es por menor
                -- estricto y el domingo cambia la semana si resto asi no puedo representar
                -- la fecha correcta. Por esto para el repear uso el from asumiendo que es
                -- menor que el to.
                if p_range.r_from is not null
                then
                    p_to := p_to - date_trunc( p_range.repeat, p_range.r_from ) + p_fixed;
                else
                    p_to := p_to - date_trunc( p_range.repeat, p_to ) + p_fixed;
                end if;
            end if;
        end if;

        if p_range_not
        then
            -- in range
            if p_data >= p_from and p_data < p_to
            then
                return false;
            end if;
        else 
            -- not in range
            if p_data < p_from or p_data >= p_to
            then
                return false;
            end if;
        end if;

     end if;

    return true;
END;
$$;


ALTER FUNCTION urbix.range_match(p_range_id integer, p_range_not boolean, p_time timestamp without time zone) OWNER TO urbix;

--
-- Name: sum_measure(integer, bkn_measure_data, bkn_measure); Type: FUNCTION; Schema: urbix; Owner: urbix
--

CREATE FUNCTION sum_measure(p_active_formula_id integer, r_data bkn_measure_data, r_measure bkn_measure) RETURNS real
    LANGUAGE plpgsql
    AS $$
DECLARE
     r_factor real;
BEGIN
    -- en esta funcion esta cableado el significado de si un sensor es de in/out
    -- ver ums_codes -> MEASURE_TYPE
    if r_data.type_code = 1 -- in
    then
        r_factor := get_formula_param( p_active_formula_id, 302, r_measure.measure_time )::real;
        return r_data.value * r_factor;
    elseif r_data.type_code = 2 -- out
    then
        r_factor := get_formula_param( p_active_formula_id, 303, r_measure.measure_time )::real;
        return -r_data.value * r_factor;
    end if;
    return 0;
END;
$$;


ALTER FUNCTION urbix.sum_measure(p_active_formula_id integer, r_data bkn_measure_data, r_measure bkn_measure) OWNER TO urbix;

--
-- Name: sum_measure_customer(integer, bkn_measure_data, bkn_measure); Type: FUNCTION; Schema: urbix; Owner: urbix
--

CREATE FUNCTION sum_measure_customer(p_active_formula_id integer, r_data bkn_measure_data, r_measure bkn_measure) RETURNS real
    LANGUAGE plpgsql
    AS $$
DECLARE
     r_factor real;
	 r_value real;
	 r_noncustomer real;
BEGIN
    -- en esta funcion esta cableado el significado de si un sensor es de in/out
    -- ver ums_codes -> MEASURE_TYPE
    if r_data.type_code = 1 -- in
    then
        r_factor := get_formula_param( p_active_formula_id, 302, r_measure.measure_time )::real;
        r_noncustomer := get_formula_param(p_active_formula_id, 310, r_measure.measure_time )::real; -- Valor a restar, (no-clientes).
		r_value := r_data.value - r_noncustomer;
		return r_value * r_factor;
    elseif r_data.type_code = 2 -- out
    then
        r_factor := get_formula_param( p_active_formula_id, 303, r_measure.measure_time )::real;
        r_noncustomer := get_formula_param(p_active_formula_id, 320, r_measure.measure_time )::real; -- Valor a restar, (no-clientes).
		r_value := r_data.value - r_noncustomer;
		return -r_value * r_factor;
    end if;
    return 0;
END;
$$;


ALTER FUNCTION urbix.sum_measure_customer(p_active_formula_id integer, r_data bkn_measure_data, r_measure bkn_measure) OWNER TO urbix;

--
-- PostgreSQL database dump complete
--

