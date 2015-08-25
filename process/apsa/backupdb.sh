#!/bin/bash
echo 'Realizando backup de DB, para APSA...'
export PGPASSWORD='urbix'
pg_dump -i -h localhost -p 5432 -U urbix -F c -b -v -f ../backupdbs/urbixapsa.backup urbixapsa

