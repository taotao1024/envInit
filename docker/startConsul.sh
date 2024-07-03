docker pull hashicorp/consul
# 以server模式启动第一个节点
docker run -d --name=dev-consul -e CONSUL_BIND_INTERFACE=eth0 hashicorp/consul
# 查看Consul容器IP信息 (172.17.0.6)
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dev-consul
# 以server模式启动第二个节点 并加入到第一个节点中
docker run -d --name=dev-consul-2 -e CONSUL_BIND_INTERFACE=eth0 hashicorp/consul agent -dev -join=172.17.0.6
# 启动客户端
docker run -it -d --privileged=true -p 8500:8500 --restart=always --name=consul hashicorp/consul agent -server -bootstrap -ui -node=1 -client='0.0.0.0' 
