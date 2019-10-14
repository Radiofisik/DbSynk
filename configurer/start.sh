#!/bin/bash
echo "Starting configurer script!"

#cleanup script is still in developement
/usr/src/cleanup.sh

export PGPASSWORD=123
psql -h $AGGREGATION_DB_HOSTNAME -d cognitive_etp -U postgres -p 5432 -a -q -f /usr/src/createSchema.sql

while true
do
  STATUS=$(curl -s -o /dev/null -w '%{http_code}' http://connect:8083/connectors/)
  if [ $STATUS -eq 200 ]; then
    echo "Got 200! Connector is ready!"
    break
  else
    echo "Got $STATUS :( Not done yet..."
  fi
  sleep 10
done

curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://connect:8083/connectors/ -d @/usr/src/sink.json
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://connect:8083/connectors/ -d @/usr/src/source.json

tail -f /dev/null