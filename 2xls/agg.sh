psql -h peopleimpact.com.ar urbixagg -U urbix \
-c 'select description, variable_id from urbix.bkn_variable order by variable_id' -At \
> variables

cp head.sql get-variables.sql

head -1 variables |\
sed -e 's/\([^|]*\)|\([^|]*\)/from (select time, data as "\1 v_id=\2|\2/' -e 's/|/"|/' -e "s/|/ from bkn_result \n where '2015-01-01' <= time and time <= '2015-05-01' \n|/" \
-e "s/|\([^|]*\)/ and variable_id = \1) as v\1\n/" >> get-variables.sql


tail -n +2 variables |\
sed -e 's/\([^|]*\)|\([^|]*\)/full join (select time, data as "\1 - v_id=\2|\2/' -e 's/|/"|/' -e "s/|/ from bkn_result \n where '2015-01-01' <= time and time <= '2015-05-01' \n|/" \
-e "s/|\([^|]*\)/ and variable_id = \1) as v\1\n/" \
-e "s/$/using (time)/"  >> get-variables.sql

echo "order by time;" >> get-variables.sql

psql -h peopleimpact.com.ar -U urbix urbixagg -f get-variables.sql
 
psql -A -F';' -h peopleimpact.com.ar -U urbix urbixagg -c 'select * from v_meassures;' -o agg.2015-1er-cuat.csv



