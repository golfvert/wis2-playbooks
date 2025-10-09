#!/bin/bash

# Check if a node name was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <node-name>"
  exit 1
fi

NODE="$1"
ENV_FILE="${NODE}.env"

# Check if the environment file exists
if [ ! -f wis2node/"$ENV_FILE" ]; then
  echo "Error: Environment file '$ENV_FILE' not found."
  exit 2
fi

# Run the Ansible playbook with the node name as a variable
ansible-playbook delnode.yml -e "wis2node=${NODE}" --limit globalbroker
