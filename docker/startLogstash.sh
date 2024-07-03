# logstash启动
esHost=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' es_771`
localPath=`pwd`

rm -rf config
rm -rf data
rm -rf logs 

mkdir -p ${localPath}/config data logs
chown -R 1000:1000 ${localPath}

cat >> ${localPath}/config/logstash.yml << EOF
# 配置内容
path.config: ${localPath}/config/*.conf
path.logs: ${localPath}/logs/
EOF
cat ${localPath}/config/logstash.yml

cat >> ${localPath}/config/logstashIni.conf << EOF
# 收录springboot项目日志配置 ini.conf
input {
	tcp {
		type => "syslog-ra"   #此处为自定义名称
		host => "0.0.0.0"     #此处为logstash的IP地址用于接受SYSLOG日志
		port => 514
	}
}

output {
	elasticsearch {
		hosts => ["${esHost}:9200"]
	}
	stdout {
		codec => rubydebug 
	}
}
# 以下为filebeat的配置
input {
	beats {
		port => 514
		codec => "json"
	}
}
# 保存日志到es中
output {
	elasticsearch { hosts => ["${esHost}:9200"] }
	stdout { codec => rubydebug }
}
EOF
cat ${localPath}/config/logstashIni.conf

docker pull logstash:7.7.1
# 启动服务
docker run -it -d \
 --name logstash_771 \
 --privileged=true \
 --restart=always \
 -p 514:514 \
 -p 5045:5045 \
 -p 5046:5046 \
 -v ${localPath}/config/logstash.yml:/usr/share/logstash/config/logstash.yml \
 -v ${localPath}/config/conf.d/:/usr/share/logstash/conf.d/ \
 logstash:7.7.1