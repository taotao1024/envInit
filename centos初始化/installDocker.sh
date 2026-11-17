#!/usr/bin/env bash
# Docker 一键安装脚本（适用于 CentOS / RHEL 7+）
# 流程：关闭防火墙 -> 修复 yum 源 -> 系统更新 -> 清理旧版 Docker -> 配置 yum 源 -> 安装 Docker 及工具 -> 启动并校验

set -euo pipefail

# ========== 可配置参数 ==========
DISABLE_FIREWALL=true   # 是否关闭并禁用 firewalld
FIX_CENTOS_REPO=true    # 是否自动将 CentOS 7 的失效源替换为 vault 归档源
SKIP_UPDATE=false       # 是否跳过系统全量更新（yum update -y）
USE_CN_MIRROR=true      # 是否使用清华镜像源安装 Docker CE（国内服务器推荐）
# ================================

log_info() { echo -e "\033[32m[INFO]\033[0m $(date '+%F %T') $*"; }
log_warn() { echo -e "\033[33m[WARN]\033[0m $(date '+%F %T') $*"; }
log_err()  { echo -e "\033[31m[ERROR]\033[0m $(date '+%F %T') $*" >&2; }

# root 权限检查
if [[ $EUID -ne 0 ]]; then
    log_err "请使用 root 用户或 sudo 执行本脚本"
    exit 1
fi

# 系统包管理器检查
if ! command -v yum >/dev/null 2>&1; then
    log_err "当前系统不支持 yum，本脚本仅适用于 CentOS / RHEL 系列"
    exit 1
fi

log_info "==== 开始 Docker 环境安装 ===="

# 1. 关闭防火墙（按需）
if [[ "$DISABLE_FIREWALL" == true ]] && systemctl list-unit-files firewalld.service >/dev/null 2>&1; then
    log_info "步骤 1/9：关闭并禁用 firewalld"
    systemctl stop firewalld.service || true
    systemctl disable firewalld.service || true
    systemctl status firewalld.service || true
else
    log_warn "步骤 1/9：跳过防火墙操作（已禁用配置或系统无 firewalld）"
fi

# 2. 修复 CentOS 7 yum 源（EOL 后 mirrorlist.centos.org 已下线，会报 Could not resolve host）
if [[ "$FIX_CENTOS_REPO" == true ]] && grep -q 'release 7' /etc/redhat-release 2>/dev/null; then
    log_info "步骤 2/9：检测 CentOS 7 yum 源"
    if [[ ! -f /etc/yum.repos.d/CentOS-Base.repo ]] || grep -q 'mirrorlist.centos.org' /etc/yum.repos.d/CentOS-Base.repo 2>/dev/null; then
        log_info "切换为阿里云 CentOS 7 归档源（vault）"
        cp -f /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak 2>/dev/null || true
        cat > /etc/yum.repos.d/CentOS-Base.repo <<'EOF'
[base]
name=CentOS-$releasever - Base - mirrors.aliyun.com
baseurl=https://mirrors.aliyun.com/centos-vault/7.9.2009/os/$basearch/
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-$releasever - Updates - mirrors.aliyun.com
baseurl=https://mirrors.aliyun.com/centos-vault/7.9.2009/updates/$basearch/
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-$releasever - Extras - mirrors.aliyun.com
baseurl=https://mirrors.aliyun.com/centos-vault/7.9.2009/extras/$basearch/
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-7

[centosplus]
name=CentOS-$releasever - Plus - mirrors.aliyun.com
baseurl=https://mirrors.aliyun.com/centos-vault/7.9.2009/centosplus/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-7
EOF
        yum clean all
        yum makecache
    else
        log_info "yum 源配置正常，跳过替换"
    fi
else
    log_warn "步骤 2/9：跳过 yum 源修复（非 CentOS 7 或已关闭配置）"
fi

# 3. 系统更新（按需）
if [[ "$SKIP_UPDATE" == false ]]; then
    log_info "步骤 3/9：系统更新（yum update -y）"
    yum update -y
else
    log_warn "步骤 3/9：跳过系统更新"
fi

# 4. 清理旧版 Docker 组件（保留已有数据目录 /var/lib/docker）
log_info "步骤 4/9：卸载旧版 Docker 组件"
yum remove -y docker docker-client docker-client-latest docker-common docker-latest \
    docker-latest-logrotate docker-logrotate docker-engine || true

# 5. 安装基础依赖
log_info "步骤 5/9：安装 epel-release 与 yum 工具"
yum install -y epel-release
yum install -y yum-utils device-mapper-persistent-data lvm2

# 6. 配置 Docker CE 源
log_info "步骤 6/9：配置 Docker CE yum 源"
# 先清除所有已存在的 Docker 相关 repo，避免官方残留源继续生效
rm -f /etc/yum.repos.d/docker*.repo /etc/yum.repos.d/*docker*.repo
if [[ "$USE_CN_MIRROR" == true ]]; then
    # 阿里云 Docker CE 源（与 CentOS 源同厂商，链路更稳定）
    cat > /etc/yum.repos.d/docker-ce.repo <<'EOF'
[docker-ce-stable]
name=Docker CE Stable - $basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/$releasever/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg
EOF
else
    cat > /etc/yum.repos.d/docker-ce.repo <<'EOF'
[docker-ce-stable]
name=Docker CE Stable - $basearch
baseurl=https://download.docker.com/linux/centos/$releasever/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg
EOF
fi
# 刷新缓存，让新源立即生效
yum clean all
yum makecache fast || true

# 7. 安装 Docker 及常用工具
log_info "步骤 7/9：安装 docker-ce、buildx、compose 插件及 atop/jq"
yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin atop jq

# 8. 启动并设置开机自启
log_info "步骤 8/9：启动 Docker 并设置开机自启"
systemctl enable --now docker

# 9. 校验安装结果
log_info "步骤 9/9：校验安装结果"
docker --version
docker compose version
systemctl is-active docker

log_info "==== Docker 安装完成 ===="
log_warn "如需配置镜像加速，请创建 /etc/docker/daemon.json（写入 registry-mirrors），然后执行：systemctl daemon-reload && systemctl restart docker"
