#!/bin/sh

WIS2NODE=$1

cd data

if [ ! -f "env/$WIS2NODE".env ]; then
 exit
fi

if [ -d "wis2node/$WIS2NODE" ]; then
  rm -rf  wis2node/$WIS2NODE
fi

# Delete prometheus entry
rm json/`echo $WIS2NODE`.json

files=$(find ./json -name '*.json')
if [ -n "$files" ]; then
  jq -n 'reduce inputs as $in (null;
    . + if $in|type == "array" then $in else [$in] end)' $files > mqtt.json
else
  rm mqtt.json
fi

#cp mqtt.json ../../prometheus

docker stop $WIS2NODE
docker rm $WIS2NODE
