# A collection of ansible playbooks, shell scripts and configuration files 

This is a set of ansible playbooks targeted primarily at helping with the deployment of various WIS2 related tools.
It has been tested with:
- the Ansible master running on a debian-like OS and on MacOS.
- the Ansible nodes running on a debian-like OS

The file variable.yml contains all ansible variables that are used in the playbooks.

Create a file secret.yml based on the example provided. This contains the various password / token to create a secure environment.

By using traefik, it is possible to create and renew automatically let's encrypt certificates.
The yml provided (the playbook traefik.yml and the configuration file traefik/traefik.yml) are configured to use Infomaniak and a token for the dns-01 challenge.
If your domain is not registered with Infomaniak, adapt to your needs. The token is not provided.

1. Deploying a test Global Broker running on a single server.
For this, running the following playbooks, in this order, is required:
- docker.yml 
- setup_gb_dev.yml 
- traefik.yml 
- redis.yml 
- emqx_bridge_mode.yml 

For each playbook, one or more variables (all stored in variables.yml) starting with the name of the playbook (setup_gb_, docker_,..) can and should be modified according to the needed configuration.