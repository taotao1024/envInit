# alertManager 脚本
localPath=`pwd`

rm -rf config
rm -rf data
rm -rf logs 

mkdir -p ${localPath}/config data logs
chown -R 1000:1000 ${localPath}


cat >> ${localPath}/config/alertmanager.yml << EOF
# 全局配置（global）
global:
  resolve_timeout: 5m

# 告警路由（route）
route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'
  routes:
    - match_re:
        alertname: .*
      receiver: 'web.hook'
      continue: true

# 接收人（receivers）
receivers:
- name: 'web.hook'
  webhook_configs:
  - url: 'http://192.168.0.210:5001/'

# 抑制规则（inhibit_rules）
inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
EOF

# 拉区镜像
docker pull prom/alertmanager
docker run -it -d \
 --name alertmanager \
 --privileged=true \
 -p 9093:9093 \
 -v ${localPath}/config/alertmanager.yml:/etc/alertmanager/alertmanager.yml \
 -v ${localPath}/config/:/etc/alertmanager/ \
 prom/alertmanager
