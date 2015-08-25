# traer datos de measure de produccion:urbixsolar a desarrollo:urbixrecoleta para hu1
psql -c "copy (select * from urbix.bkn_measure where creation_date > '2015-04-21' and sensor_id in (1,2,7,8,52,53)) to stdout;" \
-h peopleimpact.com.ar -p 5432 urbixsolar -U urbix |\
psql -c "set search_path to urbix; truncate bkn_measure cascade; copy bkn_measure from stdin;" \
-h urbix-desarrollo.thin-hippo.net -p 5432 urbixrecoleta -U urbix

# traer datos de measure_data de produccion:urbixsolar a desarrollo:urbixrecoleta para hu1
selected="select measure_id from urbix.bkn_measure where creation_date > '2015-04-21' and sensor_id in (1,2,7,8,52,53)"
psql -c "copy (select * from urbix.bkn_measure_data where measure_id in ($selected)) to stdout;" \
-h peopleimpact.com.ar -p 5432 urbixsolar -U urbix |\
psql -c "set search_path to urbix; truncate bkn_measure_data cascade; copy bkn_measure_data from stdin;" \
-h urbix-desarrollo.thin-hippo.net -p 5432 urbixrecoleta -U urbix

# setear refresh en true para recalcular
psql -c "update urbix.bkn_measure set refresh=true;" -h urbix-desarrollo.thin-hippo.net -p 5432 urbixrecoleta -U urbix

# reprocesa todas las formulas activas para los measure coin refresh en true
psql -c "select formula_engine();" -h urbix-desarrollo.thin-hippo.net -p 5432 urbixrecoleta -U urbix


