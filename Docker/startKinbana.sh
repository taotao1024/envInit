# Kibana 脚本
esHost=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' es_771`
localPath=`pwd`

rm -rf config
rm -rf data
rm -rf logs 

mkdir -p ${localPath}/config data logs
chown -R 1000:1000 ${localPath}

cat >> ${localPath}/config/kibana.yml << EOF
# 配置内容
# Default Kibana configuration for docker target
server.name: kibana
server.host: "0"
i18n.locale: "zh-CN"
elasticsearch.hosts: ["http://${esHost}:9200"]
xpack.monitoring.ui.container.elasticsearch.enabled: true
EOF

cat ${localPath}/config/kibana.yml

docker pull kibana:7.7.1
# 启动服务
docker run -it -d \
 --name kibana_771 \
 --privileged=true \
 --restart=always \
 -p 5601:5601 \
 -v ${localPath}/config/kibana.yml:/usr/share/kibana/config/kibana.yml \
 --log-driver json-file \
 --log-opt max-size=100m \
 --log-opt max-file=2 \
 kibana:7.7.1