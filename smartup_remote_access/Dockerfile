ARG BUILD_ARCH
FROM ghcr.io/home-assistant/${BUILD_ARCH}-base:3.22

ENV FRP_VERSION=0.68.0

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

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
