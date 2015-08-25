#echo "copy bkn_measure from stdin;" > dummy_meassures.sql
#psql -h peopleimpact.com.ar -U urbix urbixsolar -c 'copy bkn_measure to stdout;' -t >> dummy_meassures.sql
#echo "\." >> dummy_meassures.sql

pg_dump -h peopleimpact.com.ar -U urbix urbixsolar -t urbix.bkn_measure > make-dummy-table.sql

# edit the file
# remove the foreign key constraint

psql -h urbix-desarrollo.thin-hippo.net -U urbix urbixrecoleta  -f make-dummy-table.sql

