#delete connectors
curl -i -X DELETE -H "Accept:application/json" -H  "Content-Type:application/json" http://docker:8083/connectors/inventory-connector 
curl -i -X DELETE -H "Accept:application/json" -H  "Content-Type:application/json" http://docker:8083/connectors/jdbc-sink 

#clean destination data and replication slots
sleep 10
docker-compose exec postgres bash -c 'psql -U $POSTGRES_USER $POSTGRES_DB -c "drop table customers"'

docker-compose exec postgressrc bash -c 'psql -U $POSTGRES_USER $POSTGRES_DB -c "select * from pg_replication_slots "'
docker-compose exec postgressrc bash -c 'psql -U $POSTGRES_USER $POSTGRES_DB -c "select pg_drop_replication_slot('"'debezium'"')"'

#clean topics
docker-compose exec kafka bash -c 'bin/kafka-topics.sh --zookeeper zookeeper:2181 --delete --topic my_connect_offsets'
# docker-compose exec kafka bash -c 'bin/kafka-topics.sh --zookeeper zookeeper:2181 --delete --topic my_connect_configs'
# docker-compose exec kafka bash -c 'bin/kafka-topics.sh --zookeeper zookeeper:2181 --delete --topic my_connect_status'
docker-compose exec kafka bash -c 'bin/kafka-topics.sh --zookeeper zookeeper:2181 --delete --topic customers'


sleep 5
docker-compose restart connect

sleep 10
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://docker:8083/connectors/ -d @sink.json
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://docker:8083/connectors/ -d @source.json