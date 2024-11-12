# 青龙 初始化
# https://www.xjx100.cn/news/326477.html?action=onClick
# https://zhuanlan.zhihu.com/p/664671254?utm_id=0
# https://blog.csdn.net/u011027547/article/details/130703685
# 青龙 定时任务集合
# 京东库 https://github.com/shufflewzc/faker2

localPath=`pwd`

rm -rf config
rm -rf data
rm -rf logs 

mkdir -p ${localPath}/ql
chown -R 1000:1000 ${localPath}

#镜像初始化
docker pull whyour/qinglong:2.10.13

# 启动
docker run -dit \
-v ${localPath}/ql/config:/ql/config \
-v ${localPath}/ql/scripts:/ql/scripts \
-v ${localPath}/ql/repo:/ql/repo \
-v ${localPath}/ql/log:/ql/log \
-v ${localPath}/ql/db:/ql/db \
-v ${localPath}/ql/deps:/ql/deps \
-v ${localPath}/ql/jbot:/ql/jbot \
-v ${localPath}/ql/raw:/ql/raw \
-v ${localPath}/ql/ninja:/ql/ninja \
-v ${localPath}/ql/xdd:/ql/xdd \
-v ${localPath}/ql/xdd-plus:/ql/xdd-plus \
-v ${localPath}/ql/sillyGirl:/ql/sillyGirl \
-p 5700:5700 \
-p 5701:5701 \
-e ENABLE_HANGUP=true \
-e ENABLE_WEB_PANEL=true \
-e ENABLE_TG_BOT=true \
--name qinglong \
--hostname qinglong \
--restart unless-stopped \
whyour/qinglong:2.10.13