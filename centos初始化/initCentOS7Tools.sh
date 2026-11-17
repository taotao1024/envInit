#!/bin/sh
rootPath=`pwd`

# 关闭防火墙
installHost(){
systemctl stop firewalld.service
systemctl disable firewalld.service
systemctl status firewalld.service
}

# 安装jdk
installJdk(){
jdk_tar=''
jdk_install_path="/usr/local/jdk/"

# 1、安装包
for i in `ls`; do
  if [[ $i =~ 'jdk' ]];then
	  echo "自动获取到JDK安装包 $i"
	  jdk_tar=$i
  fi
done

if [ "$jdk_tar" = '' ];then
  read -ep "请输入JDK.tar包命 : " jdk_tar
fi

# 2、移动路径
rm -rf ${jdk_install_path}
mkdir -p ${jdk_install_path}

chown -R 1000:1000 ${jdk_install_path}
tar -xvf ${jdk_tar} -C ${jdk_install_path}

# 3、配置环境变量
cp /etc/profile /etc/profile.bak
jdk_file_name=${jdk_tar%.*}

cat >> /etc/profile << EOF
export JAVA_HOME=${jdk_install_path}${jdk_file_name}
export JRE_HOME=\$JAVA_HOME/jre
export CLASSPATH=\$JAVA_HOME/lib:\$JRE_HOME/lib:\$CLASSPATH
export PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:\$PATH
EOF
# 4、环境变量生效
source /etc/profile
}

# 安装Mysql
installMysql(){
zipName=''
read -ep "请输入Mysql安装包名称: " zipName
echo "1.Mysql Unzip Start"
tar xzvf ${zipName}
mysqlDir=${zipName%.tar.gz*}
mv ${mysqlDir} /usr/local/mysql
mkdir /usr/local/mysql/data

# 开始安装
useradd mysql
chown -R mysql:mysql /usr/local/mysql
chmod -R 755 /usr/local/mysql
# 配置文件
cat >> /etc/my.cnf << EOF
[mysqld]
datadir=/usr/local/mysql/data
basedir=/usr/local/mysql
socket=/usr/local/mysql/data/mysql.sock
user=mysql
port=3306
character-set-server=utf8
symbolic-links=0
lower_case_table_names=1
#password=/usr/local/mysql/data/mysql.password
[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
[client]
port=3306
socket=/usr/local/mysql/data/mysql.sock
EOF

echo "2.Mysql Config Start"
# 初始化Mysql
cd /usr/local/mysql/bin
./mysqld --initialize --user=mysql --datadir=/usr/local/mysql/data --basedir=/usr/local/mysql
# 添加开启自启
cp -rf /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
/usr/lib/systemd/systemd-sysv-install enable mysqld
# cp -rf `find / -name mysql.server | head -1` /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
source /etc/profile
# 配置环境变量
echo "export MYSQL_HOME=/usr/local/mysql" >> /etc/profile
source /etc/profile
echo "export PATH=$PATH:$MYSQL_HOME/bin" >> /etc/profile
source /etc/profile

echo "3.Mysql Install Success"
# 启动Mysql
systemctl enable mysqld
systemctl start mysqld
}

# 初始化
initMysql() {
dbPwd=''
read -ep "请输入数据库密码 : " dbPwd

mysql_cmd="mysql -h127.0.0.1 -uroot -p${dbPwd} --protocol=tcp --silent"
mysql_cmd2="mysql -h127.0.0.1 -uroot -p123123 --protocol=tcp --silent"
# 查看root的密码是否为空,以及是否支持远程登录
# select host,user,plugin,authentication_string from mysql.user;

# 设置环境变量
\cp -rf /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
/usr/lib/systemd/systemd-sysv-install enable mysqld
\cp -rf `find / -name mysql.server | head -1` /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
source /etc/profile

echo "1.Mysql Update Passwd"
$mysql_cmd -e "SET PASSWORD = PASSWORD('123123');flush privileges;" --connect-expired-password

echo "2.Mysql Update Access"
$mysql_cmd2 -e "use mysql;update user set host = '%' where user = 'root';flush privileges;" --connect-expired-password
}

# 初始化
rmMysqlPwd() {
source /etc/profile
mysql_cmd2="mysql -h127.0.0.1 -uroot -p123123 --protocol=tcp --silent"

echo "1.Mysql Root NoPwd"
$mysql_cmd2 -e "use mysql;ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '';" --connect-expired-password
}

case $1 in
  installHost)
	echo "installHost START"
  	installHost
	echo "installHost END "
  ;;
  installJdk)
	echo "installJdk START"
  	installJdk
	echo "installJdk  END "
  ;;
  installMysql)
	echo "installMysql START"
  	installMysql
	echo "installMysql  END "
  ;;
  initMysql)
	echo "initMysql START"
  	initMysql
	echo "initMysql  END "
  ;;
  *)
  	echo ""
  	echo "参数不合法，启动脚本的使用参数如下: "
	echo $"Usage: $0 {installJdk | installMysql | initMysql }"
	echo "          installJdk           安装JDK"
	echo "          installMysql              初始化数据库"
	echo "          initMysql              初始化数据库"
  	echo ""
	exit 1
esac
exit 0