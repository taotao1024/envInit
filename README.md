### 克隆仓库
```angular2html
# 127.0.0.1:7890 为临时代理地址
git -c http.proxy=http://127.0.0.1:7890 clone https://github.com/xxx/xxx.git
```
# envInit 环境初始化脚本集

本项目汇总了常用中间件、监控组件与基础运行环境的**一键安装 / 启动脚本**，分为两大场景：

- **`Docker/`**：基于 Docker / Docker Compose 的容器化部署脚本，覆盖数据库、搜索引擎、监控告警、CI/CD 等常用服务。
- **`ISO-Centos/`**：面向 CentOS 7 裸机的环境初始化脚本与 Jenkins Pipeline 示例，用于系统级工具安装与持续集成。

> 说明：脚本中默认包含部分内网 IP、`API Key`、`access_token`、数据库密码等示例值，实际使用前请按环境自行替换。

## 目录结构

```text
envInit/
├── Docker/                          # Docker 容器化部署脚本（20 个 .sh + 1 个 .yaml）
│   ├── grafana/
│   │   └── docker-compose.yaml      # Grafana（bitnami 镜像）编排配置
│   ├── installOracle.sh             # Oracle 数据库
│   ├── startAlertManager.sh         # Prometheus 告警管理器
│   ├── startConsul.sh               # Consul 服务发现
│   ├── startDocker.sh               # 安装 Docker 环境
│   ├── startELK.sh                  # ELK 一体镜像
│   ├── startEs.sh                   # Elasticsearch
│   ├── startEsHead.sh               # Elasticsearch Head
│   ├── startGptTurbo.sh             # ChatGPT Next Web
│   ├── startGrafana.sh              # Grafana
│   ├── startJenkins.sh              # Jenkins
│   ├── startKinbana.sh              # Kibana
│   ├── startLdapAdiin.sh            # phpLDAPadmin
│   ├── startLdapSvr.sh              # OpenLDAP
│   ├── startLogstash.sh             # Logstash
│   ├── startMysql.sh                # MySQL
│   ├── startNodeExporter.sh         # Node Exporter
│   ├── startProm.sh                 # Prometheus 全家桶（Compose 编排）
│   ├── startPrometheus.sh           # Prometheus
│   ├── startQL.sh                   # 青龙面板
│   └── startWebHook.sh              # 钉钉 Webhook 告警
└── ISO-Centos/                      # CentOS 7 裸机环境初始化
    ├── Jenkinsfile                  # Jenkins 声明式流水线示例
    ├── README.md                    # 该目录的原始使用说明
    ├── initCentOS7Tools.sh          # 环境初始化主脚本
    ├── startGradle.sh               # Gradle 环境变量配置
    └── startJenkins.sh              # Jenkins（WAR 包方式）部署
```

## Docker 目录

容器化部署脚本，多数脚本会先清理并重建当前目录下的 `config`、`data`、`logs` 等目录，再生成配置文件并启动容器。

### 基础环境

| 脚本 | 主要镜像 | 映射端口 | 说明 |
| --- | --- | --- | --- |
| `startDocker.sh` | — | — | 基于阿里云 yum 源安装 `docker-ce` 与 `docker-compose`，并启动、设置开机自启 |

### 数据库与中间件

| 脚本 | 主要镜像 | 映射端口 | 说明 |
| --- | --- | --- | --- |
| `installOracle.sh` | `wnameless/oracle-xe-11g-r2` | `49161:1521` | Oracle XE 11g，SID 为 `xe`，开启远程连接 |
| `startMysql.sh` | `mysql:8.0.26` | `3306:3306` | MySQL 8.0，挂载配置 / 数据 / 日志目录，root 密码环境变量配置 |
| `startConsul.sh` | `hashicorp/consul` | `8500:8500` | Consul 服务注册与发现，含双 server 节点与 Web UI |
| `startLdapSvr.sh` | `osixia/openldap` | `389`、`636` | OpenLDAP 服务，域名示例 `koal.com` |
| `startLdapAdiin.sh` | `osixia/phpldapadmin` | `6443:443`、`6080:80` | phpLDAPadmin，LDAP 目录可视化管理 |
| `startQL.sh` | `whyour/qinglong:2.10.13` | `5700`、`5701` | 青龙面板（定时任务），挂载多目录持久化 |

### 日志与搜索（ELK）

| 脚本 | 主要镜像 | 映射端口 | 说明 |
| --- | --- | --- | --- |
| `startELK.sh` | `sebp/elk` | — | 拉取 ELK 一体式镜像 |
| `startEs.sh` | `elasticsearch:7.7.1` | `9200`、`9300` | 单节点 ES，开启跨域，限制 JVM 内存 256m |
| `startEsHead.sh` | `mobz/elasticsearch-head:5-alpine` | `9100:9100` | ES 可视化客户端 |
| `startKinbana.sh` | `kibana:7.7.1` | `5601:5601` | Kibana，中文界面，自动探测 ES 容器 IP |
| `startLogstash.sh` | `logstash:7.7.1` | `514`、`5045`、`5046` | 日志收集，配置 syslog / beats 输入并写入 ES |

### 监控与告警

| 脚本 / 文件 | 主要镜像 | 映射端口 | 说明 |
| --- | --- | --- | --- |
| `startPrometheus.sh` | `prom/prometheus` | `9090:9090` | Prometheus 单容器部署，内置告警与抓取目标配置 |
| `startNodeExporter.sh` | `prom/node-exporter` | `9100:9100` | 主机性能指标采集 |
| `startAlertManager.sh` | `prom/alertmanager` | `9093:9093` | Alertmanager，通过 Webhook 转发告警 |
| `startWebHook.sh` | `timonwong/prometheus-webhook-dingtalk:v0.3.0` | `8060:8060` | 钉钉告警 Webhook，附消息模板 |
| `startGrafana.sh` | `grafana/grafana` | `3000:3000` | Grafana 可视化，默认管理员密码 `admin` |
| `startProm.sh` | `prom/prometheus` + `prom/node-exporter` + `grafana/grafana` | `9090`、`9100`、`3000` | 一键生成 `docker-compose.yaml` 与 `prometheus.yml`，交互式录入各节点地址后启动整套监控 |
| `grafana/docker-compose.yaml` | `bitnami/grafana` | `13000:3000` | 独立 Grafana 编排配置，带日志滚动限制 |

### CI/CD 与其他

| 脚本 | 主要镜像 | 映射端口 | 说明 |
| --- | --- | --- | --- |
| `startJenkins.sh` | `jenkins/jenkins:2.344` | `10240:8080`、`10241:50000` | Jenkins，以 root 运行并挂载 `jenkins_home` |
| `startGptTurbo.sh` | `yidadaa/chatgpt-next-web` | `1210:3000` | ChatGPT Next Web 面板，通过环境变量配置 API Key |

## ISO-Centos 目录

面向 CentOS 7 系统的裸机初始化与构建配置，与 Docker 方案互补。

| 文件 | 类型 | 说明 |
| --- | --- | --- |
| `initCentOS7Tools.sh` | Shell | 环境初始化主脚本，通过参数调用不同功能：`installHost`（关闭防火墙）、`installJdk`（解压 JDK 并配置环境变量）、`installMysql`（解压安装 MySQL 并配置 `/etc/my.cnf`）、`initMysql`（修改密码、开放远程访问） |
| `startGradle.sh` | Shell | 向 `/etc/profile` 写入 `GRADLE_HOME`，配置 Gradle 4.10.2 环境变量 |
| `startJenkins.sh` | Shell | 下载 `jenkins.war` 并以 `java -jar` 启动，写入 systemd 服务实现开机自启，同时追加内网 hosts 解析（脚本标注 TODO，待完善） |
| `Jenkinsfile` | Pipeline | Jenkins 声明式流水线：使用 Gradle 4.10.2 / JDK8，依次执行 `Pull`（拉取代码）、`Build`（Gradle 打包并启动）、`Test`（curl 验证）、`Deploy`、`Back`（SSH 备份发布到目标机器）；全局超时 15 分钟 |
| `README.md` | 文档 | 该目录原有的简易调用说明 |

### ISO-Centos 原有调用方式

```bash
# 给予执行权限
chmod +775 initCentOS7Tools.sh
# 关闭防火墙
./initCentOS7Tools.sh installHost
# 安装 jdk
./initCentOS7Tools.sh installJdk
# 安装 Mysql
./initCentOS7Tools.sh installMysql
# 初始化 Mysql
./initCentOS7Tools.sh initMysql
```

## 使用建议

1. `Docker/` 下脚本通常通过 `pwd` 获取当前工作目录作为配置与数据根目录（对应脚本中的 `localPath` 变量），执行前应切换到合适目录，避免误删已有 `config`、`data`、`logs`。
2. 脚本中硬编码了若干内网 IP（如 `10.2.3.x`）、密钥与口令，部署到新环境前需逐一核对替换。
3. 注意端口占用冲突，例如 `startEsHead.sh` 与 `startNodeExporter.sh` 均使用 `9100` 端口，需按实际情况调整。
4. `ISO-Centos/initCentOS7Tools.sh` 会修改 `/etc/profile`、`/etc/my.cnf` 等系统文件，建议先备份后执行。
