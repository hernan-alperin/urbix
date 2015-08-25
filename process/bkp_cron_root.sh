#!/bin/bash

find /data -maxdepth 1 -name 'bkp-crontab-*' -mtime 7 -exec rm {} \;
crontab -l -u root > /data/bkp-crontab-`date +%Y-%m-%d`
