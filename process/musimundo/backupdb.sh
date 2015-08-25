#!/bin/bash
echo 'Realizando backup de DB, para MUSIMUNDO...'
export PGPASSWORD='urbix'
pg_dump -i -h localhost -p 5432 -U urbix -F c -b -v -f ../backupdbs/urbixmusimundo.backup urbixmusimundo

