# node Exporter 脚本
localPath=`pwd`

rm -rf config
rm -rf data
rm -rf logs 

mkdir -p ${localPath}/config data logs
chown -R 1000:1000 ${localPath}

docker run -d -p 9100:9100 prom/node-exporter

# docker run -d \
#  -p 9100:9100 \
#  -v "${localPath}/data/proc:/host/proc:ro" \
#  -v "${localPath}/data/sys:/host/sys:ro" \
#  -v "${localPath}/data/:/rootfs:ro" \
#  --net="host" \
#  quay.io/prometheus/node-exporter \
#  -collector.procfs /host/proc \
#  -collector.sysfs /host/sys \
#  -collector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)"