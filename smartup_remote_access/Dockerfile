ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG BUILD_ARCH

ENV FRP_VERSION=0.68.0

SHELL ["/bin/ash", "-o", "pipefail", "-c"]

RUN \
    case "${BUILD_ARCH}" in \
      amd64) FRP_ARCH="amd64" ;; \
      aarch64) FRP_ARCH="arm64" ;; \
      armv7|armhf) FRP_ARCH="arm" ;; \
      i386) FRP_ARCH="386" ;; \
      *) echo "Unsupported architecture: ${BUILD_ARCH}" && exit 1 ;; \
    esac \
    && apk add --no-cache curl tar \
    && curl -fsSL -o /tmp/frp.tar.gz "https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_${FRP_ARCH}.tar.gz" \
    && tar -xzf /tmp/frp.tar.gz -C /tmp \
    && mv "/tmp/frp_${FRP_VERSION}_linux_${FRP_ARCH}/frpc" /usr/local/bin/frpc \
    && chmod +x /usr/local/bin/frpc \
    && rm -rf /tmp/frp* \
    && apk del tar

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
