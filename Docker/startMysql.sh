# --name 指定容器名，可自定义，不指定自动命名
# -i 以交互模式运行容器
# -t 分配一个伪终端，即命令行，通常-it组合来使用
# -p 指定映射端口，讲主机端口映射到容器内的端口
# -d 后台运行容器
# -v 指定挂载主机目录到容器目录，默认为rw读写模式，ro表示只读
# docker exec -it 容器ID或者容器名 /bin/bash



docker run -d \
 --name mysql_8_0_26 \
 --privileged=true \
 --restart=always \
 -p 3306:3306 \
 -v /usr/local/dockerSpac/mysql/conf/my.cnf:/etc/mysql/my.cnf \
 -v /usr/local/dockerSpac/mysql/data:/var/lib/mysql \
 -v /usr/local/dockerSpac/mysql/logs:/var/log/mysql \
 -e MYSQL_ROOT_PASSWORD=root \
 docker.io/mysql:8.0.26
