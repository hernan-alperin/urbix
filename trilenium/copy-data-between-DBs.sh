export host=urbix-desarrollo.thin-hippo.net
pg_dump -h $host urbixtrilenium -U urbix -cC -n urbix > dump-urbix-dev2prd.sql
echo 'drop schema urbix cascade;' >> copy-urbix-dev2prd.sql
echo 'begin;' > copy-urbix-dev2prd.sql
cat dump-urbix-dev2prd.sql >> copy-urbix-dev2prd.sql
echo 'commit;' >> copy-urbix-dev2prd.sql
psql -h peopleimpact.com.ar urbixtrilenium -f copy-urbix-dev2prd.sql

rm dump-urbix-dev2prd.sql copy-urbix-dev2prd.sql
