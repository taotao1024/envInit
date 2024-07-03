# ES启动文件
localPath=`pwd`
rm -rf config
rm -rf data
rm -rf logs
rm -rf plugins

mkdir -p ${localPath}/config data logs plugins
chown -R 1000:1000 ${localPath}


cat >> ${localPath}/config/elasticsearch.yml << EOF
# 配置内容
cluster.name: "my-es"
network.host: 0.0.0.0
http.port: 9200
#跨域
http.cors.enabled: true
http.cors.allow-origin: "*"
EOF

cat ${localPath}/config/elasticsearch.yml
# 启动服务
docker run -it -d \
 --name es_771 \
 --privileged=true \
 --restart=always \
 -p 9200:9200 \
 -p 9300:9300 \
 -e ES_JAVA_OPTS="-Xms256m -Xmx256m" \
 -e "discovery.type=single-node" \
 -v ${localPath}/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml \
 -v ${localPath}/data:/usr/share/elasticsearch/data \
 -v ${localPath}/logs:/usr/share/elasticsearch/logs \
 -v ${localPath}/plugins:/usr/share/elasticsearch/plugins \
 elasticsearch:7.7.1

