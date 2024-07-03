#!/bin/sh
# 监控脚本
localPath=`pwd`
rm -rf ${localPath}/docker
rm -rf ${localPath}/docker-compose.yaml
rm -rf ${localPath}/prometheus.yml

mkdir -p ${localPath}/docker/prometheus
mkdir -p ${localPath}/docker/prometheus/config 
mkdir -p ${localPath}/docker/prometheus/data
mkdir -p ${localPath}/docker/grafana/data

cat >> ${localPath}/docker-compose.yaml << EOF
version: '3'
services:
  # prom/prometheus 服务
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: always
    privileged: true
    environment:
      - TZ=Asia/Shanghai
    volumes:
      - ./docker/prometheus/config/:/etc/prometheus/
      - ./docker/prometheus/data/:/prometheus/
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
    ports:
      - '9090:9090'
    healthcheck:
      test: ["CMD", "nc", "-z", "localhost", "9090"]
      interval: 10s
      timeout: 30s
      retries: 5
      start_period: 1m
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 256M

  # prom/node-exporter 服务
  node_exporter:
    image: prom/node-exporter
    container_name: node
    restart: always
    privileged: true
    ports:
      - '9100:9100'
    volumes:
      - '/proc:/host/proc:ro'
      - '/sys:/host/sys:ro'
      - '/:/rootfs:ro'
      - '/:/host:ro,rslave'
    network_mode: host
    healthcheck:
      test: ["CMD", "nc", "-z", "localhost", "9100"]
      interval: 10s
      timeout: 10s
      retries: 5
      start_period: 1m
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 256M

  # Grafana服务
  grafana:
    image: grafana/grafana:latest
    restart: always
    container_name: grafana
    privileged: true
    environment:
      TZ: Asia/Shanghai
    volumes:
      - ./docker/grafana/data:/var/lib/grafana
    ports:
      - '3000:3000'
    healthcheck:
      test: ["CMD", "bash", "-c", "cat < /dev/null > /dev/tcp/127.0.0.1/3000"]
      interval: 10s
      timeout: 30s
      retries: 5
      start_period: 3m
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 256M

EOF

read -p "请输入CA地址: "  	ca_addr
read -p "请输入RA地址: " 	ra_addr
read -p "请输入RA地址: " 	lra_addr
read -p "请输入KM地址: " 	km_addr
read -p "请输入Node地址: " 	node_addr

cat >> ${localPath}/prometheus.yml << EOF
# Prometheus配置内容
global:
  scrape_interval: 15s
  evaluation_interval: 15s

# 监控目标配置 默认只有主机本身的监控配置
scrape_configs:
  - job_name: "KM" 
    scrape_interval: 10s
    static_configs:
      - targets: ['${km_addr}:50883']
        labels:
          # 节点用途，此处固定为KM
          instanceType: 'KM'
          zone: 'KM机房-01'
    relabel_configs:
    - source_labels: ['__address__']
      target_label: instance
      regex: '(.*):.*'
      replacement: '\${1}'
      
  - job_name: "CA" 
    scrape_interval: 10s
    static_configs:
      - targets: ['${ca_addr}:50881']
        labels:
          # 节点用途，此处固定为CA
          instanceType: 'CA'
          zone: 'CA机房-01'
    relabel_configs:
    - source_labels: ['__address__']
      target_label: instance
      regex: '(.*):.*'
      replacement: '\${1}'
      
  - job_name: "CRL" 
    scrape_interval: 10s
    static_configs:
      - targets: ['${ca_addr}:50891']
        labels:
          # 节点用途，此处固定为CRL
          instanceType: 'CRL'
          zone: 'CRL机房-01'
    relabel_configs:
    - source_labels: ['__address__']
      target_label: instance
      regex: '(.*):.*'
      replacement: '\${1}'
      
  - job_name: "RA" 
    scrape_interval: 10s
    static_configs:
      - targets: ['${ra_addr}:50882']
        labels:
          # 节点用途，此处固定为RA
          instanceType: 'RA'
          zone: 'RA机房-01'
    relabel_configs:
    - source_labels: ['__address__']
      target_label: instance
      regex: '(.*):.*'
      replacement: '\${1}'

  - job_name: "LRA"
    scrape_interval: 10s
    static_configs:
      - targets: ['${lra_addr}:50892']
        labels:
          # 节点用途，此处固定为LRA
          instanceType: 'LRA'
          zone: 'RA机房-01'
    relabel_configs:
    - source_labels: ['__address__']
      target_label: instance
      regex: '(.*):.*'
      replacement: '\${1}'

  - job_name: "node"
    static_configs:
      - targets: 
        - '${node_addr}:9100'
        labels:
          # 节点用途，此处固定为node
          instanceType: 'node'
          zone: '机房-01'
    relabel_configs:
    - source_labels: ['__address__']
      target_label: instance
      regex: '(.*):.*'
      replacement: '\${1}'
EOF

mv prometheus.yml ${localPath}/docker/prometheus/config/
chmod -R 777 ${localPath}/docker/grafana/ ${localPath}/docker/prometheus

docker compose up -d