# Home Assistant Add-on: Smartup AutoSSH

**Reverse tunnel Home Assistant services over both TCP and UDP.**

This add-on is designed for sites behind NAT where you cannot port-forward locally.  
It is branded as **Smartup AutoSSH** to preserve the familiar workflow from the original AutoSSH add-on, but it uses **FRP** under the hood because plain SSH port forwarding is TCP-only and is not the right transport for UDP services such as KNX/IP on port `3671/udp`.

## What this add-on changes

- Keeps the reverse-tunnel pattern: the remote Home Assistant connects out to a public server.
- Supports the Home Assistant UI over TCP.
- Adds optional extra TCP forwardings.
- Adds optional UDP forwardings.

## Important limitation

This add-on **does not connect to a normal OpenSSH server**.

Your public VPS must run an **FRP server** (`frps`), not just `sshd`.

## Quick Start

1. Install `Smartup AutoSSH`.
2. Prepare an `frps` server on your VPS.
3. Set `server_host`, `server_port`, and `auth_token`.
4. Set `remote_ui_port` for the Home Assistant UI.
5. Add optional `tcp_forwarding` and `udp_forwarding` entries.
6. Start the add-on.

## Configuration

### Required

- `server_host`: public VPS hostname or IP.
- `server_port`: FRP server port, for example `7000`.
- `auth_token`: shared token between client and server.
- `remote_ui_port`: public TCP port on the VPS that should reach Home Assistant UI.

### Optional

- `local_ui_host`: defaults to `home-assistant`.
- `local_ui_port`: defaults to `8123`.
- `tcp_forwarding`: extra TCP forwards.
- `udp_forwarding`: extra UDP forwards.
- `transport_tls`: enable FRP transport TLS.

### Forwarding format

Both `tcp_forwarding` and `udp_forwarding` use this format:

```yaml
name:remote_port:local_host:local_port
```

Examples:

```yaml
tcp_forwarding:
  - "sshadmin:22210:192.168.1.20:22"
  - "mqtt:18830:core-mosquitto:1883"

udp_forwarding:
  - "knx:36710:192.168.1.50:3671"
  - "dns:53530:192.168.1.1:53"
```

## Example add-on config

```yaml
server_host: vps.example.com
server_port: 7000
auth_token: "replace_me"
transport_tls: true
user: house1
remote_ui_port: 18123
local_ui_host: home-assistant
local_ui_port: 8123
tcp_forwarding:
  - "sshadmin:22210:192.168.1.20:22"
udp_forwarding:
  - "knx:36710:192.168.1.50:3671"
log_level: info
```

## Example `frps` server config

Put something like this on your VPS as `frps.toml`:

```toml
bindPort = 7000

[auth]
method = "token"
token = "replace_me"
```

Then start the server:

```bash
frps -c /etc/frp/frps.toml
```

## How to access services

If the example above is active:

- Home Assistant UI is reachable on `vps.example.com:18123`
- Remote admin SSH is reachable on `vps.example.com:22210`
- KNX/IP is reachable on `vps.example.com:36710/udp`

## Recommended architecture

- Use **Traefik** on the VPS only for HTTP/HTTPS apps such as Home Assistant UI.
- Use **FRP ports directly** for raw TCP/UDP services.
- For KNX/IP and other UDP-heavy control protocols, this is much more appropriate than SSH port forwarding.

## Security notes

- Restrict VPS firewall rules to only the ports you actually use.
- Use a strong `auth_token`.
- Prefer per-site port ranges or naming conventions.
- Treat the Home Assistant host as trusted because it holds the tunnel credentials.
