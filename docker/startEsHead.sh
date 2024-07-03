# ES-head
docker run -it -d \
 --name=es-head \
 --privileged=true \
 --restart=always \
 -p 9100:9100 \
 mobz/elasticsearch-head:5-alpine
