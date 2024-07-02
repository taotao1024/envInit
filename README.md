# envInit
CentOs7环境初始化

# 给予执行权限
chmod +775 initCentOS7Tools.sh
# 关闭防火墙
./initCentOS7Tools.sh installHost
# 安装jdk
./initCentOS7Tools.sh installJdk
# 安装Mysql
./initCentOS7Tools.sh installMysql
# 初始化Mysql
./initCentOS7Tools.sh initMysql