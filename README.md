# WIS2 Test Environment Deployment

Ansible playbooks for deploying WIS2 (WMO Information System 2.0) test infrastructure. Automates deployment of MQTT brokers, monitoring, test nodes, and supporting services across multiple hosts.

## Architecture

Three deployment types:

1. **Global Broker (GB)** - Central MQTT broker aggregating messages from multiple WIS2 nodes
2. **WIS2 Node** - Individual 'fake' WIS2 nodes connecting to Global Broker
3. **Master Node** - For configuration message propagation to the Fake WIS2 nodes

All deployments use Docker containers, Traefik for reverse proxy/TLS, EMQX for MQTT, and Redis for caching.

## Prerequisites

- Ansible control machine (Debian-like OS or macOS)
- Target nodes running Debian-like OS
- DNS records configured for all target hosts
- `inventory.yml` - host definitions
- `variables.yml` - environment-specific configuration
- `secret.yml` - credentials and tokens (create from example, never commit)

Tested with:
- Ansible master on Debian-like OS and macOS
- Ansible nodes on Debian-like OS

## Configuration Files

### variables.yml
Central configuration for all playbooks. Contains service versions, Docker network settings, container names, and deployment-specific parameters. Modify variables prefixed with playbook names (setup_gb_, docker_, etc.) according to your environment.

### secret.yml
Sensitive credentials: EMQX passwords, DNS provider tokens (for Let's Encrypt), Traefik dashboard password. Create from example.

### inventory.yml
Ansible inventory defining target hosts.

Structure:
```yaml
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

Group must be `node`. The `dns_name` field is required for Let's Encrypt certificate generation. Create as many entries as needed.

## Certificate Management

Traefik handles automatic Let's Encrypt certificates via DNS-01 challenge. Currently configured for Infomaniak DNS provider. If using different provider, modify `traefik.yml` playbook and `files_*/traefik/traefik.yml` configuration. DNS provider token required in `secret.yml`.

## Deployment Sequences

### 1. Global Broker (Single Server)

```bash
ansible-playbook docker.yml
ansible-playbook setup_gb_dev.yml
ansible-playbook traefik.yml
ansible-playbook redis.yml
ansible-playbook emqx_bridge_mode.yml
ansible-playbook prometheus.yml
```

Result: Functional Global Broker.

### 2. WIS2 Node with Testing Tools

```bash
ansible-playbook docker.yml
ansible-playbook setup_wis2node.yml
ansible-playbook traefik.yml
ansible-playbook redis.yml
ansible-playbook emqx_bridge_mode.yml
ansible-playbook caddy.yml
ansible-playbook wis2node.yml
ansible-playbook wis2benchtools.yml
ansible-playbook wis2benchgb.yml
```

Or use helper script:
```bash
./ansible-test-node.sh test-node-X
```

Result: Functional WIS2 node with testing tools.

### 3. Add Node to Existing Global Broker

Deploy the node first (sequence 2), then register with GB:
```bash
./add_wis2node.sh test-node-X
```

## Helper Scripts

### ansible-test-node.sh
Automates full WIS2 node deployment sequence with single command.
```bash
./ansible-test-node.sh <node-name>
```

### addnode.sh
Registers existing WIS2 node with Global Broker (establishes MQTT bridge).
In wis2node directory, create or modify a file called xy-example.env (xy-example is the effective centre-id for the remote WIS2 Node)
In this file:

```
MQTT_SUB_BROKER=mqtt://mybroker.example.xy      # This is the URL of the local broker of the WIS2 Node. If needed :456 can be added at the end of the URL if the post used in not the standard one.
MQTT_SUB_USERNAME=username
MQTT_SUB_PASSWORD=password
MQTT_SUB_TOPIC=origin/a/wis2/xy-example/#       # This is the topic to subscribe to. Depending on the role of the remote Node (Global Cache, Global Broker,...) or the WIS2 Node itself, the subscription can be adapted. Multiple topics can be entered. 
CENTRE_ID=xy-example                            # This must be the official centre-id of the remote WIS2 Node
MSG_CHECK_OPTION=discard                        # The three options can either have the value no, verify, discard. When no - the verification feature is disabled, verify - checks the conformance but let the message go through, discard - check the conformance and discard offending WNM
TOPIC_CHECK_OPTION=verify                       # MSG_CHECK_OPTION = conformance to WNM specifications, TOPIC_CHECK_OPTION = conformance to the WTH specifications, METADATA_CHECK_OPTION = existence of a metadata for a particluar topic
METADATA_CHECK_OPTION=verify
```

```bash
./addnode.sh <node-name>
```

Requires node environment file: `wis2node/<node-name>.env`

### delnode.sh
Unregisters WIS2 node with Global Broker (remove MQTT bridge).

```bash
./delnode.sh <node-name>
```

Requires node environment file: `wis2node/<node-name>.env`

## Centre ID Allocation

Unique centre_id values computed from hostname to prevent collisions. Servers must use DNS pattern `test-node-X.mydomain.com` where X is integer. In the current setup X is 1, 2, 3, 4 or 5.

| Component | Pattern | test-node-1 | test-node-2 |
|-----------|---------|-------------|-------------|
| wis2node | X + 10 | 11 | 12 |
| wis2benchgb (instance 1) | (X-1) * 40 + 100 | 100 | 140 |
| wis2benchgb (instance 2) | (X-1) * 40 + 120 | 120 | 160 |
| wis2benchtools | X + 999 | 1000 | 1001 |

Centre IDs used in MQTT topics and data metadata.

## Network Architecture

Services communicate via custom Docker bridge network (default: `gbnet`, subnet: `172.30.0.0/16`):

```
Internet → Traefik (80, 443) → gbnet → Services (EMQX, Redis, Prometheus, Caddy, applications)
```

Traefik provides routing and TLS termination. Internal services not directly exposed.

## Troubleshooting

Check deployed services:
```bash
ansible node -i inventory.yml -m shell -a "docker ps"
```

View service logs:
```bash
ansible node -i inventory.yml -m shell -a "docker logs <container_name>"
```

Check installation type:
```bash
ansible node -i inventory.yml -m shell -a "cat /home/gbnode/installation_type"
```

Verify Docker network:
```bash
ansible node -i inventory.yml -m shell -a "docker network inspect gbnet"
```

Certificate issues:
- Verify DNS records resolve correctly
- Check DNS provider token in `secret.yml`
- Ensure `traefik/acme.json` has 600 permissions

## Maintenance

### Update Service Version
1. Edit version in `variables.yml`
2. Re-run service playbook
3. Old container stopped, new version deployed
4. Volumes persist (no data loss)

### Add New Node
1. Add host to `inventory.yml`
2. Run WIS2 node deployment sequence
3. Run `addnode.yml` to register with GB

### Remove Node
1. Stop containers on target host
2. Remove from `inventory.yml`
3. Update GB MQTT bridge configuration if needed

## Security Notes

- All credentials in `secret.yml` (never commit)
- Traefik provides TLS termination
- Services isolated via Docker network
- Strong passwords required for MQTT and admin interfaces
- Regular container image updates recommended

