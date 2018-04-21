up:
	#sudo rm -rf /mongo_cluster/*
	#sudo docker-compose up -d
	sleep 5
	sudo docker exec -it mongod_conf1_container bash -c "echo 'rs.initiate({_id: \"mongod_conf_cluster\",configsvr: true, members: [{ _id : 0, host : \"mongod_conf1_container\" },{ _id : 1, host : \"mongod_conf2_container\" }, { _id : 2, host : \"mongod_conf3_container\" }]})' | mongo"
	sleep 5
	sudo docker exec -it mongod_conf1_container bash -c "echo 'rs.status()' | mongo"
	sleep 5
	sudo docker exec -it mongod_db1_container bash -c "echo 'rs.initiate({_id : \"mongod_db_cluster\", members: [{ _id : 0, host : \"mongod_db1_container\" },{ _id : 1, host : \"mongod_db2_container\" },{ _id : 2, host : \"mongod_db3_container\" }]})' | mongo"
	sleep 5
	sudo docker exec -it mongod_db1_container bash -c "echo 'rs.status()' | mongo"
	sleep 5
	#THIS COMMAND MUST BE EXECUTE ON THE PRIMARY NODE, WE ASUME THAT IS mongod_db1_container
	sudo docker exec -it mongod_db1_container bash -c "echo 'db.getSiblingDB(\"admin\").createUser({user: \"cypm\",pwd: \"testing\",roles: [ { role: \"userAdminAnyDatabase\", db: \"admin\" } ]})' | mongo"
	sleep 5
	#CONECTING AS AUTH USER RETURN 1 IF AUTH IS OK
	sudo docker exec -it mongod_db1_container bash -c "echo 'db.getSiblingDB(\"admin\").auth(\"cypm\", \"testing\" )' | mongo"
	sleep 5
	sudo docker exec -it mongos_router1_container bash -c "echo 'sh.addShard(\"mongod_db_cluster/mongod_db1_container\")' | mongo "
	sleep 5
	sudo docker exec -it mongos_router1_container bash -c "echo 'sh.status()' | mongo "
	sleep 5
	sudo docker exec -it mongod_db1_container bash -c "echo 'use testDb' | mongo"
	sleep 5
	sudo docker exec -it mongos_router1_container bash -c "echo 'sh.enableSharding(\"testDb\")' | mongo "
	sleep 5
	sudo docker exec -it mongod_db1_container bash -c "echo 'db.createCollection(\"testDb.testCollection\")' | mongo "
	sleep 5
	sudo docker exec -it mongos_router1_container bash -c "echo 'sh.shardCollection(\"testDb.testCollection\", {\"shardingField\" : 1})' | mongo "


down:
	sudo docker-compose down

# TODO: Remove sudo, this is due to cypm laptop

# TODO: Why not use sh.addShard() in mongod_db2_container and mongod_db3_container, Oficial documentation say use in all of they
# TODO: But looks like is not necessary, because sh.status() show all of they. Adding manually mongod_db2_container output look exactly de same

# TODO: Find a alternative to command "sudo rm -rf /mongo_cluster/*" this is necessary because volumes preserve first execution configuration and
# TODO: this create problems conecctions on second execution

#TODO: Create user must be executed on primary node, but primary changes on executions , so what can we do?