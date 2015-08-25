#!/bin/bash
echo 'Realizando backup de DB, para TORTUGAS OPEN MALL...'
export PGPASSWORD='urbix'
pg_dump -i -h localhost -p 5432 -U urbix -F c -b -v -f /opt/process/backupdbs/urbixtom.backup urbixtom

