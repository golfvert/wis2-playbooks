# A collection of ansible playbooks, shell scripts and configuration files 

This is a set of ansible playbooks targeted primarily at helping with the deployment of various WIS2 related tools.
It has been tested with:
- the Ansible master running on a debian-like OS and on MacOS.
- the Ansible nodes running on a debian-like OS

The file variable.yml contains all ansible variables that are used in the playbooks.

For each playbook, one or more variables (all stored in variables.yml) starting with the name of the playbook (setup_gb_, docker_,..) can and should be modified according to the needed configuration.

Create a file secret.yml based on the example provided. This contains the various password / token to create a secure environment.

Create an inventory file for Ansible.
The inventory should be structured like this:
```
node:
  hosts:
    target:
      ansible_host: 192.168.192.192
      ansible_user: ansible
      dns_name: target.mydomain.com
    test-node-25:
      ansible_host: 192.168.168.168
      ansible_user: ansible
      dns_name: test-node-25.mydomain.com
```

By default, the group must be called `node`. It is needed to provide `dns_name` as it is used to create the Let's Encrypt certificate for the host.
Create as many entries as needed to deploy your environment.

By using traefik, it is possible to create and renew automatically let's encrypt certificates.
The yml provided (the playbook traefik.yml and the configuration file traefik/traefik.yml) are configured to use Infomaniak and a token for the dns-01 challenge.
If your domain is not registered with Infomaniak, adapt to your needs. The token is not provided.

1. Deploying a test Global Broker running on a single server
For this, running the following playbooks, in this order, is required:
- docker.yml 
- setup_gb_dev.yml 
- traefik.yml 
- redis.yml 
- emqx_bridge_mode.yml 

2. Deploying a fake wis2node as well as additional tooling used to run the WIS2 Global Services acceptance tests
For this, running the following playbooks, in this order, is required:
- docker.yml 
- setup_wis2node.yml 
- traefik.yml 
- redis.yml 
- emqx_bridge_mode.yml 
- wis2node.yml
- wis2benchtools.yml
- wis2benchgb.yml

By design, the servers where the WIS2 testing tools are deployed (wis2node, wis2benchtools, wis2benchgb) must have a DNS name like `test-node-X.mydomain.com`.
The `X` is used as a baseline to define the `centre-id` used by each tool.

The following method is used:

- for wis2node (the fake wis2node to create notification messages, data files,...) will have a centre-id equal to `X + 10`
- for wis2benchgb (the Notification Message generator) will have the centre-id between `( X - 1 ) * 40 + 100` and `( X - 1 ) * 40 + 139`.
- for wis2bench tools (the container including MQTTX CLI and Apache Bench) will have the centre-id equal to `X + 999`