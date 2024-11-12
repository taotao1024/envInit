cat >> /etc/profile << EOF
export GRADLE_HOME=/usr/local/gradle/gradle-4.10.2
export PATH=\${PATH}:\${GRADLE_HOME}/bin
EOF
# 4、环境变量生效
source /etc/profile