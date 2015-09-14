set search_path to private;

drop function system_states_balanced(v_in integer, v_out integer, "date" date);
create function system_states_balanced(v_in integer, v_out integer, "date" date)
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
  sum_incoming numeric;
  sum_outgoing numeric;
begin
  set search_path to private, public, urbix;
  select max(date + workday_start) into opening_time
  from bkn_variable
  where variable_id in ($1,$2);
  select min(date + workday_start + (workday_duration||' hours')::interval) into closing_time
  from bkn_variable
  where variable_id in ($1,$2);
  duration := extract('hour' from closing_time - opening_time);
  select occupation into previous_occupation
    from system_states($1,$2,$3) where opening_time = timestamp;
  select sum(incoming) + previous_occupation, sum(outgoing) into sum_incoming, sum_outgoing
    from system_states($1,$2,$3) where opening_time <= timestamp;
  select 0 as i, opening_time - '1 hour'::interval as timestamp
    , previous_occupation as incoming, null::numeric as outgoing, null::numeric as occupation into system_state;
  return next system_state;
  i := 1;
  actual_time := opening_time;
  while (actual_time < closing_time)
  loop
    select i, incoming.actual_time, round(incoming), round(outgoing*(sum_incoming/sum_outgoing)), 
      greatest(0,round(incoming) - round(outgoing*(sum_incoming/sum_outgoing)) + previous_occupation) as occupation 
      into system_state
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
security definer
;
--select * from system_states_balanced(51,52,'2015-07-15');

 
