#!/usr/bin/with-contenv bashio

set -euo pipefail

CONFIG_FILE="/tmp/frpc.toml"

server_host="$(bashio::config 'server_host')"
server_port="$(bashio::config 'server_port')"
auth_token="$(bashio::config 'auth_token')"
transport_tls="$(bashio::config 'transport_tls')"
user_name="$(bashio::config 'user')"
remote_ui_port="$(bashio::config 'remote_ui_port')"
local_ui_host="$(bashio::config 'local_ui_host')"
local_ui_port="$(bashio::config 'local_ui_port')"
log_level="$(bashio::config 'log_level')"

if [[ -z "${server_host}" ]]; then
    bashio::exit.nok "server_host must not be empty"
fi

if [[ -z "${auth_token}" ]]; then
    bashio::exit.nok "auth_token must not be empty"
fi

cat > "${CONFIG_FILE}" <<EOF
serverAddr = "${server_host}"
serverPort = ${server_port}
loginFailExit = false
user = "${user_name}"
log.to = "stdout"
log.level = "${log_level}"

[auth]
method = "token"
token = "${auth_token}"

[transport]
protocol = "tcp"
tls.enable = ${transport_tls}

[[proxies]]
name = "ha-ui"
type = "tcp"
localIP = "${local_ui_host}"
localPort = ${local_ui_port}
remotePort = ${remote_ui_port}
EOF

add_proxy() {
    local type="$1"
    local spec="$2"
    local name
    local remote_port
    local local_host
    local local_port

    IFS=':' read -r name remote_port local_host local_port <<< "${spec}"

    if [[ -z "${name:-}" || -z "${remote_port:-}" || -z "${local_host:-}" || -z "${local_port:-}" ]]; then
        bashio::exit.nok "Invalid ${type} forwarding '${spec}'. Use name:remote_port:local_host:local_port"
    fi

    cat >> "${CONFIG_FILE}" <<EOF

[[proxies]]
name = "${name}"
type = "${type}"
localIP = "${local_host}"
localPort = ${local_port}
remotePort = ${remote_port}
EOF
}

for spec in $(bashio::config 'tcp_forwarding|join(" ")'); do
    add_proxy "tcp" "${spec}"
done

for spec in $(bashio::config 'udp_forwarding|join(" ")'); do
    add_proxy "udp" "${spec}"
done

bashio::log.info "Starting Smartup AutoSSH"
bashio::log.info "Primary UI remote port: ${remote_ui_port}/tcp"
bashio::log.info "Generated FRP client configuration:"
sed 's/token = ".*/token = "[redacted]"/' "${CONFIG_FILE}" | while IFS= read -r line; do
    bashio::log.info "${line}"
done

exec frpc -c "${CONFIG_FILE}"
