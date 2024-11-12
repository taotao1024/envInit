# prometheus 脚本
localPath=`pwd`

rm -rf config
rm -rf data
rm -rf logs 

mkdir -p ${localPath}/config data logs
chown -R 1000:1000 ${localPath}

cat >> ${localPath}/config/prometheus.yml << EOF
# 配置内容
# 全局配置
global:
  scrape_interval: 15s # 设置抓取(pull)时间间隔，默认是1m
  evaluation_interval: 15s # 设置rules评估时间间隔，默认是1m
  # scrape_timeout 设置为全局默认值（10 秒）

# 告警管理配置，暂未使用，默认配置
alerting:
  alertmanagers:
    - static_configs:
        - targets: ['10.2.3.210:9093']

# 加载rules，并根据设置的时间间隔定期评估，暂未使用，默认配置
rule_files:
  - /usr/local/dockerSpac/prometheus/config/pki_*rules.yml

# 抓取(pull)，即监控目标配置 默认只有主机本身的监控配置
scrape_configs:
# 监控目标的label（这里的监控目标只是一个metric，而不是指某特定主机，
# 可以在特定主机取多个监控目标），在抓取的每条时间序列表中都会添加此label
  - job_name: "KM" 
    # 可覆盖全局配置设置的抓取间隔，由15秒重写成5秒。
    scrape_interval: 5s
	# 静态指定监控目标，暂不涉及使用一些服务发现机制发现目标
    static_configs:
      - targets: ['10.2.3.202:50883']
        labels:
          # 节点用途，此处固定为KM
          instanceType: 'KM'
          # 机房名称
          zone: 'KM节点1'
  - job_name: "CA" 
    static_configs:
      - targets: ['10.2.3.202:50881']
        labels:
          # 节点用途，此处固定为CA
          instanceType: 'CA'
          # 机房名称
          zone: 'CA节点1'
  - job_name: "RA" 
    static_configs:
      - targets: ['10.2.3.202:50882']
        labels:
          # 节点用途，此处固定为RA
          instanceType: 'RA'
          # 机房名称
          zone: 'RA节点1'

EOF

docker pull prom/prometheus
# 启动容器
docker run -it -d \
 --name myPrometheus \
 --privileged=true \
 -p 9090:9090 \
 -v ${localPath}/config/prometheus.yml:/etc/prometheus/prometheus.yml \
 -v ${localPath}/config/:/etc/prometheus/ \
 prom/prometheus