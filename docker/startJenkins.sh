# 启动jenkins镜像
docker run -d \
 -u root \
 --privileged=true \
 -p 10240:8080 \
 -p 10241:50000 \
 -v /usr/local/dockerSpac/jenkins/jenkins_home/:/var/jenkins_home \
 --name myjenkin \
 jenkins/jenkins:2.344
