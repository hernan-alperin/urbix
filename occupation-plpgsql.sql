set search_path to private;
create type system_state as (i integer, timestamp timestamp, incoming numeric, outgoing numeric, occupation numeric);

drop function system_states(v_in integer, v_out integer, "date" date);
create function system_states(v_in integer, v_out integer, "date" date)
returns setof system_state
as $$
declare
  i integer;
  opening_time timestamp;
  ending_time timestamp;
  actual_time timestamp;
  previous_occupation numeric;
  system_state record;
begin
  set search_path to private, public, urbix;
  select max(date + workday_start) into opening_time
  from bkn_variable 
  where variable_id in ($1,$2);
  select min(date + workday_start + (workday_duration||' hours')::interval) into ending_time
  from bkn_variable 
  where variable_id in ($1,$2);
  i := 0;
  actual_time := opening_time;
  previous_occupation := 0;
  while (actual_time < ending_time)
  loop
    select i, incoming.actual_time, incoming, outgoing, incoming - outgoing + previous_occupation as occupation into system_state
    from (
      select actual_time, estimation as incoming
      from variables_estimations
      where v_id = $1 and timestamp = actual_time) as incoming
    natural join (
      select actual_time, estimation as outgoing
      from variables_estimations
      where v_id = $2 and timestamp = actual_time) as outgoing;
    i := i+1;
    actual_time := actual_time + '1 hour'::interval;
    previous_occupation := system_state.occupation;
    return next system_state; 
  end loop;

end;
$$
language plpgsql
;
select * from system_states(51,52,'2015-07-15')
;

drop function ocupacion(v_in integer, v_out integer, "timestamp" timestamp);
create function ocupacion(v_in integer, v_out integer, "timestamp" timestamp)
returns numeric
as $$
declare ocupacion numeric;
begin
  select occupation into ocupacion
  from system_states($1, $2, timestamp::date) as system_states
  where system_states.timestamp = $3;
  if ocupacion is null then
    return 0;
  else
    return ocupacion;
  end if;
end;
$$
language plpgsql
;
select ocupacion(51,52,'2015-07-15 10:00');
select ocupacion(51,52,'2015-07-15 9:00');

drop function desbalance(v_in integer, v_out integer, "date" date);
create function desbalance(v_in integer, v_out integer, "date" date)
returns numeric
as $$
select occupation
from system_states($1, $2, $3) 
order by timestamp desc
limit 1
$$
language sql
;

select desbalance(51,52,'2015-07-15');

select dia, desbalance(51,52,dia) as desbalance from (select distinct timestamp::date as dia from variables_estimations order by timestamp::date) as dias order by desbalance;


