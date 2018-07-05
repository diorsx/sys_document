#/bin/bash
. /etc/init.d/functions

[ ! -d /root/software ] && mkdir -p /root/software
cd /root/software

#下载安装包
wget http://mirrors.hust.edu.cn/apache//apr/apr-1.6.3.tar.gz
wget http://mirrors.hust.edu.cn/apache//apr/apr-util-1.6.1.tar.gz
wget http://mirror.bit.edu.cn/apache/httpd/httpd-2.4.32.tar.gz
wget http://cn2.php.net/distributions/php-7.2.7.tar.gz

#解压相关安装包
for i in *.tar.gz ; do
    tar -xzf "$i"
done

#安装apr依赖包
apr_path="/usr/local/apr-1.6.3"
cd apr-1.6.3
./configure --prefix=$apr_path
if [ $? -eq 0 ]
then
    action "Configure Apr Success" /bin/true
else
    action "Configure Apr Failure"  /bin/false
    exit 1
fi
make && make install
if [ $? -eq 0 ]
then
    action "Install Apr Success!" /bin/true
else
    action "Install Apr Failure"  /bin/false
    exit 1
fi

cd ../
#安装apr-util依赖包
apr_util_path="/usr/local/apr-util-1.6.1"
cd apr-util-1.6.1
./configure --prefix=$apr_util_path
if [ $? -eq 0 ]
then
    action "Configure Apr-util Success" /bin/true
else
    action "Configure Apr-util Failure"  /bin/false
    exit 1
fi
make && make install
if [ $? -eq 0 ]
then
    action "Install Apr-util Success!" /bin/true
else
    action "Install Apr-util Failure"  /bin/false
    exit 1
fi

cd ../
#安装httpd依赖
httpd_path="/usr/local/httpd-2.4.32"
cd httpd-2.4.32
./configure  \
--prefix=$httpd_path \
--with-apr=$apr_path \
--with-apr-util=$apr_util_path \
--enable-so \
--enable-expires \
--enable-static-support \
--enable-buffer \
--enable-rewrite \
--with-pcre \
--enable-modules=all \
--enable-deflate\
--enable-cgi \
--with-ssl \
--with-zlib

if [ $? -eq 0 ]
then
    action "Configure Httpd Success" /bin/true
else
    action "Configure Httpd Failure"  /bin/false
    exit 1
fi
make && make install
if [ $? -eq 0 ]
then
    action "Install Httpd Success!" /bin/true
else
    action "Install Httpd Failure"  /bin/false
    exit 1
fi

cd ../
#安装php
until [ "$module_flags" = "yes" ] || [ "$module_flags" = "no" ] 
do
	read -p "是否以APACHE模块形式安装(yes|no):"  module_flags
   #对用户的输入进行匹配
	case $module_flags in
       "yes")
            php_installation_options="--with-apxs2=${httpd_path}/bin/apxs"
            ;;
       "no")
            php_installation_options="--enable-fpm"
            ;;
        *)
            ;;
	esac
done

cd php-7.2.7
php_path='/usr/local/php-7.2.7/'
./configure --prefix=$php_path \
--enable-shared \
--with-libxml-dir \
--with-gd \
--with-openssl-dir \
--enable-mbstring \
--with-mysqli \
--enable-opcache \
--enable-mysqlnd \
--enable-zip \
--with-zlib-dir \
--with-pdo-mysql \
--with-jpeg-dir \
--with-freetype-dir \
--with-curl \
--without-pdo-sqlite \
--without-sqlite3 \
--enable-soap \
--with-gd \
${php_installation_options}

if [ $? -eq 0 ]
then
    action "Configure Php Success" /bin/true
else
    action "Configure Php Failure"  /bin/false
    exit 1
fi
make && make install
if [ $? -eq 0 ]
then
    action "Install Php Success!" /bin/true
else
    action "Install Php Failure"  /bin/false
    exit 1
fi