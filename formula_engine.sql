CREATE OR REPLACE FUNCTION urbix.formula_engine()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
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
$function$
