#!/usr/bin/env bash
# Consul 单节点 Docker 部署脚本（开发/测试环境）
# 特性：Web UI、服务注册发现、DNS 接口、数据持久化、幂等执行、启动自检
# 如需集群，可在多个节点分别执行，并通过 -join=<主节点IP> 加入（见文末说明）

set -euo pipefail

# ========== 可配置参数 ==========
CONTAINER_NAME="consul"                        # 容器名称
CONSUL_IMAGE="hashicorp/consul:1.15"           # 固定镜像版本，避免 latest 带来兼容问题
HTTP_PORT=8500                                 # Web UI / HTTP API 端口
DNS_PORT=8600                                  # DNS 接口端口（UDP）
DATA_DIR="$(pwd)/consul/data"                  # 数据持久化目录
CONFIG_DIR="$(pwd)/consul/config"              # 配置目录（可选，用于放置 *.json 配置）
ENABLE_DNS=true                                # 是否映射 DNS 端口
PULL_IMAGE=true                                # 是否预先拉取镜像
# ================================

log_info() { echo -e "\033[32m[INFO]\033[0m $(date '+%F %T') $*"; }
log_warn() { echo -e "\033[33m[WARN]\033[0m $(date '+%F %T') $*"; }
log_err()  { echo -e "\033[31m[ERROR]\033[0m $(date '+%F %T') $*" >&2; }

# 依赖检查
if ! command -v docker >/dev/null 2>&1; then
    log_err "未检测到 docker，请先安装 Docker"
    exit 1
fi

# 幂等检查：容器已存在则提示并退出，避免重复创建报错
if docker ps -a --format '{{.Names}}' | grep -qx "${CONTAINER_NAME}"; then
    log_warn "容器 ${CONTAINER_NAME} 已存在，跳过创建"
    docker ps -a --filter "name=^/${CONTAINER_NAME}$" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    exit 0
fi

# 创建持久化目录（不再使用 rm -rf，避免误删已有数据）
log_info "创建目录：${DATA_DIR}、${CONFIG_DIR}"
mkdir -p "${DATA_DIR}" "${CONFIG_DIR}"

# 拉取镜像
if [[ "$PULL_IMAGE" == true ]]; then
    log_info "拉取镜像：${CONSUL_IMAGE}"
    docker pull "${CONSUL_IMAGE}"
fi

# 组装 docker run 参数
DOCKER_ARGS=(
    -d
    --name "${CONTAINER_NAME}"
    --restart=always
    -p "${HTTP_PORT}:8500"
    -v "${DATA_DIR}:/consul/data"
    -v "${CONFIG_DIR}:/consul/config"
    -e "CONSUL_BIND_INTERFACE=eth0"
)
if [[ "$ENABLE_DNS" == true ]]; then
    DOCKER_ARGS+=(-p "${DNS_PORT}:8600" -p "${DNS_PORT}:8600/udp")
fi

# 启动容器：单节点 server 模式 + Web UI + 自动绑定容器 IP
log_info "启动 Consul 容器..."
docker run "${DOCKER_ARGS[@]}" "${CONSUL_IMAGE}" \
    agent -server \
    -bootstrap-expect=1 \
    -ui \
    -client=0.0.0.0 \
    -data-dir=/consul/data \
    -config-dir=/consul/config \
    -node=consul-server-1

# 等待服务就绪（最多 30 秒）
log_info "等待 Consul 服务就绪..."
LEADER=""
for _ in $(seq 1 30); do
    if curl -sf "http://127.0.0.1:${HTTP_PORT}/v1/status/leader" >/dev/null 2>&1; then
        LEADER=$(curl -s "http://127.0.0.1:${HTTP_PORT}/v1/status/leader" | tr -d '"')
        [[ -n "$LEADER" ]] && break
    fi
    sleep 1
done

if [[ -n "$LEADER" ]]; then
    log_info "Consul 启动成功，Leader: ${LEADER}"
    log_info "Web UI 地址: http://<服务器IP>:${HTTP_PORT}/ui/"
    log_info "DNS 端口: ${DNS_PORT}/udp（可通过 dig @<服务器IP> -p ${DNS_PORT} consul.service.consul 验证）"
else
    log_err "Consul 未在预期时间内就绪，请查看日志：docker logs ${CONTAINER_NAME}"
    exit 1
fi

# ============================================================
# 集群扩展示例（可选）：
# 在第二台机器上把 CONTAINER_NAME 改为 consul-2，并在 docker run 参数中增加：
#     -join=<第一台机器的IP>
# 同时需开放防火墙端口：8300(server rpc)、8301(serf lan)、8302(serf wan)
# 示例：
#   DOCKER_ARGS+=(-p 8300:8300 -p 8301:8301 -p 8301:8301/udp -p 8302:8302 -p 8302:8302/udp)
#   docker run "${DOCKER_ARGS[@]}" "${CONSUL_IMAGE}" \
#       agent -server -bootstrap-expect=3 -ui -client=0.0.0.0 \
#       -data-dir=/consul/data -config-dir=/consul/config \
#       -node=consul-server-2 -join=<第一台机器的IP>
# ============================================================
