#!/bin/bash

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

curl -i -X DELETE http://connect:8083/connectors/inventory-connector
curl -i -X DELETE http://connect:8083/connectors/jdbc-sink 

sleep 10

export PGPASSWORD=postgrespw
psql -h postgres -d inventory -U postgresuser -p 5432 -a -q -f /usr/src/cleanSchema.sql
psql -h postgressrc -d inventory -U postgresuser -p 5432 -a -q -f /usr/src/resetSync.sql

docker exec debeziumpgpg_kafka_1 bash -c 'bin/kafka-topics.sh --zookeeper zookeeper:2181 --delete --topic my_connect_offsets'
docker exec debeziumpgpg_kafka_1 bash -c 'bin/kafka-topics.sh --zookeeper zookeeper:2181 --delete --topic customers'

sleep 10
docker restart debeziumpgpg_connect_1