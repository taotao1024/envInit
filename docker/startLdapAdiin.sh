# 设置中文 https://iltongda.com/docker-phpldapadmin-chinese.html
docker run -d \
 --name ldap-admin \
 --privileged \
 -p 6443:443 \
 -p 6080:80 \
 --link ldap-server:10.2.3.210 \
 --env PHPLDAPADMIN_LDAP_HOSTS=10.2.3.210 \
 --env PHPLDAPADMIN_HTTPS=false \
 --detach osixia/phpldapadmin:latest
