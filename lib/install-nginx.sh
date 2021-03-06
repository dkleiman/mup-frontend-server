set -e 

BUILD_DIR=/tmp/nginx
NGINX_VERSION=1.11.0
PREFIX=/opt/nginx
NGINX_USER=nginx

# creating a non-privileged user
useradd $NGINX_USER || :

# install dependencies
apt-get update
apt-get -y install libpcre3-dev libssl-dev openssl build-essential wget

# start building process

rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR
mkdir -p $PREFIX
cd $BUILD_DIR

wget http://zlib.net/zlib-1.2.11.tar.gz
tar -zxf zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure
make
make install
cd ../

wget -c https://www.openssl.org/source/openssl-1.0.2l.tar.gz
tar xf openssl-1.0.2l.tar.gz
cd ./openssl-1.0.2l
./config
make depend
make
make test
make install
cd ../

# download nginx
wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz
tar xvzf nginx-$NGINX_VERSION.tar.gz

# building
cd nginx-$NGINX_VERSION
./configure \
  --prefix=$PREFIX --user=$NGINX_USER --group=$NGINX_USER \
  --with-http_ssl_module --without-http_scgi_module \
  --without-http_uwsgi_module --without-http_fastcgi_module \
  --with-zlib=../zlib-1.2.11 --with-openssl=../openssl-1.0.2l

make install

# remove build specific libraries
apt-get -y remove build-essential wget
apt-get -y autoremove

# generate new Diffie-Hellman group
openssl dhparam -out /dhparams.pem 2048
