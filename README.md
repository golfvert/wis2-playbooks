# A collection of ansible playbooks and configuration files 

This is a set of ansible playbooks targeted primarily at helping with the deployment of various WIS2 related tools.
The files variable.yml contains all ansible variables that are used in the playbooks.

Create a file secret.yml based on the example provided. This contains the password / token to create a secure environment.

By using traefik, it is possible to create and renew automatically let's encrypt certificates.
The yml provided are configured to use Infomaniak and a token to use the dns-01 challenge.
If your domain is not registered with Infomaniak, adapt to your needs.

1. Deploying a test Global Broker running on a single server.
For this, running the following playbooks, in this order, is required:
- setup_gb_dev.yml 
- docker.yml 
- traefik.yml 
- emqx_bridge_mode.yml 
- redis.yml 

For each playbook, one or more variables (all stored in variables.yml) starting with the name of the playbook (setup_gb_, docker_,..) can and should be modified according to the needed configuration.