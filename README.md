# A collection of ansible playbooks and configuration files 

This is a set of ansible playbooks targeted primarily at helping with the deployment of various WIS2 related tools.
The files variable.yml contains all ansible variables that are used in the playbooks.
Adapt the value of the var to your own environment.
By construction, each ansible playbook will use the values of the variables starting by the name of the playbook.
Create a file secret.yml based on the example provided. This contains the password / token to create a secure environment.

By using traefik, it is possible to create and renew automatically let's encrypt certificates.
The yml provided are configured to use Infomaniak and a token to use the dns-01 challenge.
If your domain is not registered with Infomaniak, adapt to your needs.

1. Deploying a test Global Broker running on a single server.
For this, running the following playbooks, in this order, is required:
- setup_gb_dev.yml - adapt variables starting with setup_gb_dev
- docker.yml - adapt variables starting with docker_
- traefik.yml - adapt variables starting with traefik_ and adapt to your DNS provider
- emqx_bridge_mode.yml - adapt variables starting with emqx_
- redis.yml - adapt variables starting with redis_
