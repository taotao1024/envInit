#!/bin/sh
rootPath=`pwd`
# TODO 待完善
# 下载 jenkins.war
wget https://get.jenkins.io/war/latest/jenkins.war
# 手动启动 jenkins
nohup java -jar jenkins.war
# 登录密码存放的路径
# cat /root/.jenkins/secrets/initialAdminPassword

# 开机自启
cat >> /etc/systemd/system/jenkins.service << EOF
[Unit]
Description=Jenkins
After=network.target

[Service]
User=root
ExecStart=${JAVA_HOME}/bin/java -jar ${rootPath}/jenkins.war
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# 配置开机自启
#systemctl start jenkins
#systemctl enable jenkins
# 查看是否启动成功
#systemctl status jenkins.service
# sudo journalctl -u jenkins
# 检查配置文件
#systemctl cat jenkins.service
# 重新加载
#systemctl daemon-reload

# Jenkins源码管理Git无法连接的问题排查
https://blog.csdn.net/qq_52030824/article/details/135864441
# Jenkins Pipeline入门使用
https://blog.csdn.net/a13568hki/article/details/137037593


# 修改Host文件
cat >> /etc/hosts << EOF
10.0.1.20 nexus3.koal.com
10.0.1.25 git.koal.com
104.16.73.101 plugins.gradle.org
EOF
# 刷新 DNS 缓存,以确保系统立即应用新的 hosts 文件配置
sudo /etc/init.d/network restart