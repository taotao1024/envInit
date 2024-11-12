# grafana 脚本
localPath=`pwd`

rm -rf config
rm -rf data
rm -rf logs 

mkdir -p ${localPath}/config data logs
chown -R 1000:1000 ${localPath}

docker pull grafana/grafana
# 启动容器
docker run -it -d \
 --name myGrafana \
 --privileged=true \
 -p 3000:3000 \
 -v "/etc/localtime:/etc/localtime" \
 -e "GF_SECURITY_ADMIN_PASSWORD=admin" \
 grafana/grafana