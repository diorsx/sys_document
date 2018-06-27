#!/bin/bash

. /etc/init.d/functions

[ ! -d /root/software ] && mkdir -p /root/software
cd /root/software

#检测依赖包
for dependent_package in gcc openssl-devel pcre-devel gd-devel unzip
do
   rpm -qa | grep $dependent_package  || yum -y install $dependent_package
done

#创建相关运行用户
read -p "创建Nginx运行用户(default nginx): "  nginx_user

#如果为空, 则创建默认用户名nginx
[ -z $nginx_user ] && nginx_user="nginx"   
id $nginx_user >/dev/null 2>&1
if [ $? -ne 0 ]
then
    groupadd -g  1001 $nginx_user
    useradd -g 1001 -u 1001 -s /sbin/nologin $nginx_user
fi

#下载安装包
wget http://nginx.org/download/nginx-1.10.3.tar.gz
wget https://github.com/simpl/ngx_devel_kit/tarball/master -O ngx_devel_kit.tar.gz
wget http://luajit.org/download/LuaJIT-2.0.5.tar.gz
wget https://github.com/openresty/lua-nginx-module/archive/v0.10.13.tar.gz -O lua-nginx-module-0.10.13.tar.gz
#ngx支持断点续传模块
wget https://github.com/hongzhidao/nginx-upload-module/archive/master.zip -O nginx-upload-module-master.zip
#清除静态缓存模块
wget http://labs.frickle.com/files/ngx_cache_purge-2.3.tar.gz

#安装LuaJit解释器, ngx需此解释器解释lua代码
tar -xzf LuaJIT-2.0.5.tar.gz
cd LuaJIT-2.0.5
make && make install
if [ $? -eq 0 ]
then
    action "Install LuaJIT Success!" /bin/true
	#添加动态库
	echo "/usr/local/lib" >/etc/ld.so.conf.d/usr_local_lib.conf
	ldconfig
else
    action "Install LuaJIT Failure"  /bin/false
    exit 1
fi

cd ../

#解压相关安装包
for i in *.tar.gz ; do
    tar -xzf "$i"
done

for i in *.zip ; do
	unzip "$i"
done

#编译安装
cd nginx-1.10.3
./configure --prefix=/usr/local/nginx-1.10.3 --with-stream --with-http_stub_status_module --with-http_image_filter_module --with-http_ssl_module --user=$nginx_user --group=$nginx_user --with-pcre --add-module=../simplresty-ngx_devel_kit-a22dade/ --add-module=../ngx_cache_purge-2.3 --add-module=../lua-nginx-module-0.10.13  --add-module=../nginx-upload-module-master
if [ $? -eq 0 ]
then
    action "Configure Nginx Success" /bin/true
else
    action "Configure Nginx Failure"  /bin/false
    exit 1
fi
make
if [ $? -eq 0 ]
then
    action "Make Nginx Success" /bin/true
else
    action "Make Nginx Failure"  /bin/false
    exit 1
fi
make install
if [ $? -eq 0 ]
then
    action "Install Nginx Success!" /bin/true
else
    action "Install Nginx Failure"  /bin/false
    exit 1
fi