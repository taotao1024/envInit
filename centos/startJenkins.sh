#!/bin/sh
rootPath=`pwd`

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