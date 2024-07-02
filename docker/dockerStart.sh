# 安装Docker
yum install -y yum-utils device-mapper-persistent-data lvm2
# 设置Docker仓库
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache fast
yum update
yum makecache fast
yum -y install docker-ce docker-compose
systemctl start docker
systemctl enable docker