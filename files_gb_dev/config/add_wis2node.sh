#!/bin/sh

WIS2NODE=$1

cd {{ docker_user_home}}/config/data

if [ ! -f "env/$WIS2NODE".env ]; then
 exit
fi

if [ ! -d "wis2node/$WIS2NODE" ]; then
  mkdir wis2node/$WIS2NODE
fi

# Create prometheus entry
cp wis2node_mqtt.json json/`echo $WIS2NODE`.json
sed -i "s/wis2node/$WIS2NODE/g" json/`echo $WIS2NODE`.json
jq -n 'reduce inputs as $in (null;
   . + if $in|type == "array" then $in else [$in] end)
   ' $(find ./json -name '*.json') > mqtt.json

cp mqtt.json ../../prometheus

# Create directory and compose entries
if [ ! -d "wis2node/$WIS2NODE/compose" ]; then
  mkdir wis2node/$WIS2NODE/compose
fi

cp wis2node-docker-compose.yml wis2node/$WIS2NODE/compose/docker-compose.yml
sed -i "s/wis2node/$WIS2NODE/g" wis2node/$WIS2NODE/compose/docker-compose.yml
cp globalenv/globalbroker.env wis2node/$WIS2NODE/compose
cp globalenv/globalurl.env wis2node/$WIS2NODE/compose
cp globalenv/redis.env wis2node/$WIS2NODE/compose
cp globalenv/host.env wis2node/$WIS2NODE/compose
cp env/`echo $WIS2NODE`.env wis2node/$WIS2NODE/compose

docker stop $WIS2NODE
docker rm $WIS2NODE

cd wis2node/$WIS2NODE/compose
docker compose -p $WIS2NODE up -d
