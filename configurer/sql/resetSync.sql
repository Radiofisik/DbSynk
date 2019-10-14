select * from pg_replication_slots;
select pg_drop_replication_slot('debezium');
select * from pg_replication_slots;