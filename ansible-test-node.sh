#!/bin/bash

# Check if a node name was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <node-name>"
  exit 1
fi

NODE="$1"

ansible-playbook docker.yml --limit $NODE
ansible-playbook setup_wis2node.yml --limit $NODE
ansible-playbook traefik.yml --limit $NODE
ansible-playbook redis.yml --limit $NODE
ansible-playbook emqx_bridge_mode.yml --limit $NODE
ansible-playbook caddy.yml --limit $NODE
ansible-playbook wis2node.yml --limit $NODE
ansible-playbook wis2benchtools.yml --limit $NODE
ansible-playbook wis2benchgb.yml --limit $NODE
