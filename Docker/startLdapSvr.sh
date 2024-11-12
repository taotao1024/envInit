# LDAP 脚本
localPath=`pwd`

rm -rf config
rm -rf data
rm -rf logs 

mkdir -p ${localPath}/config data logs
chown -R 1000:1000 ${localPath}

# 管理员名称  cn=admin,dc=koal,dc=com
# 管理员密码  ${LDAP_ADMIN_PASSWORD}=123456
docker run -d \
 --name ldap-server \
 --hostname ldap-server \
 --privileged=true \
 -p 389:389 \
 -p 636:636 \
 -v ${localPath}/data:/var/lib/ldap \
 -v ${localPath}/conf:/etc/ldap/slapd.d \
 --env LDAP_ORGANISATION="koal" \
 --env LDAP_DOMAIN="koal.com" \
 --env LDAP_ADMIN_PASSWORD="123456" \
 --env DISABLE_CHOWN="true" \
 --env LDAP_TLS="false" \
 --detach osixia/openldap:latest
