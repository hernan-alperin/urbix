create type system_state as (i numeric, timestamp timestamp, incoming numeric, outgoing numeric, occupation numeric);


drop function system_states_balanced(v_in integer, v_out integer, "date" date, imbalance numeric);
create function system_states_balanced(v_in integer, v_out integer, "date" date, imbalance numeric)
returns setof system_state
as $$
declare
  i integer;
  duration integer;
  opening_time timestamp;
  closing_time timestamp;
  actual_time timestamp;
  previous_occupation numeric;
  system_state record;
begin
  set search_path to private, public, urbix;
  select max(date + workday_start) into opening_time
  from bkn_variable
  where variable_id in ($1,$2);
  select min(date + workday_start + (workday_duration||' hours')::interval) into closing_time
  from bkn_variable
  where variable_id in ($1,$2);
  duration := extract('hour' from closing_time - opening_time);
  actual_time := opening_time;
  i := 1;
  previous_occupation := 0;
  while (actual_time < closing_time)
  loop
    select i, incoming.actual_time, incoming, outgoing*(imbalance/sum_outgoing), incoming - outgoing + previous_occupation as occupation into system_state
    from (
      select actual_time, estimation as incoming
      from variables_estimations
      where v_id = $1 and timestamp = actual_time) as incoming
    natural join (
      select actual_time, estimation as outgoing
      from variables_estimations
      where v_id = $2 and timestamp = actual_time) as outgoing;
    actual_time := actual_time + '1 hour'::interval;
    previous_occupation := system_state.occupation;
    return next system_state;
  end loop;
end;
$$
language plpgsql ;
select * from system_states_balanced(51,52,'2015-07-15',3326.73);) 
