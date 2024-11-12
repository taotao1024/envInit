#!/bin/sh

# git地址 https://github.com/wnameless/docker-oracle-xe-11g
docker pull wnameless/oracle-xe-11g-r2

# 默认登录
# hostname: localhost
# port: 49161
# sid: xe
# username: system
# password: oracle

# 启动Oracle数据库
docker run -d \
-p 49161:1521 \
-e ORACLE_ALLOW_REMOTE=true \
-e ORACLE_DISABLE_ASYNCH_IO=true \
wnameless/oracle-xe-11g-r2