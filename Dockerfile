FROM centos:7.5.1804

ENV NGINX_VERSION 1.12.2

COPY nginx.conf /etc/nginx/nginx.conf
RUN yum makecache && yum -y groupinstall 'Development Tools' && yum install -y zlib-devel ruby-devel gcc make rpm-build libevent libevent-devel libaio-devel openssl-devel pcre-devel && mkdir /nginx-source
RUN cd /nginx-source && git clone https://github.com/evanmiller/mod_zip.git
#RUN cd /nginx-source && git clone https://github.com/travcunn/nginx-upload-module.git
RUN cd /nginx-source && git clone https://github.com/fdintino/nginx-upload-module.git
RUN cd /nginx-source && curl -O http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
RUN cd /nginx-source && tar -zxvf /nginx-source/nginx-${NGINX_VERSION}.tar.gz

# Compile Nginx with mod_zip
#RUN curl -O https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && tar zxvf nginx-${NGINX_VERSION}.tar.gz

# Compile Nginx with nginx-upload-module and mod_zip
RUN cd /nginx-source/nginx-${NGINX_VERSION} && ./configure --prefix=/usr/share/nginx \
            --sbin-path=/usr/sbin/nginx \
            --conf-path=/etc/nginx/nginx.conf \
            --error-log-path=/var/log/nginx/error.log \
            --http-log-path=/var/log/nginx/access.log \
            --pid-path=/run/nginx.pid \
            --lock-path=/var/lock/nginx.lock \
            --user=www-data \
            --group=www-data \
            --http-client-body-temp-path=/tmp/.nginx/client_body \
            --http-proxy-temp-path=/tmp/.nginx/proxy_temp \
            --http-fastcgi-temp-path=/tmp/.nginx/fastcgi_temp \
            --http-uwsgi-temp-path=/tmp/.nginx/uwsgi_temp \
            --http-scgi-temp-path=/tmp/.nginx/scgi_temp \
            --add-module=/nginx-source/nginx-upload-module \
            --add-module=/nginx-source/mod_zip \
            --with-file-aio \
            --with-threads \
            --with-http_addition_module \
            --with-http_auth_request_module \
            --with-http_flv_module \
            --with-http_gunzip_module \
            --with-http_gzip_static_module \
            --with-http_mp4_module \
            --with-http_random_index_module \
            --with-http_realip_module \
            --with-http_sub_module \
            --with-http_stub_status_module \
            --with-http_secure_link_module \
            --without-http_rewrite_module \
            --with-stream \
            --with-debug \
            --with-cc-opt='-O2 -g -pipe -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -pie -fPIE -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic'
RUN cd /nginx-source/nginx-${NGINX_VERSION} && make && mkdir /nginx-source/nginx-${NGINX_VERSION}/bin && cp /nginx-source/nginx-${NGINX_VERSION}/objs/nginx /nginx-source/nginx-${NGINX_VERSION}/bin/nginxzip
RUN gem install --no-ri --no-rdoc fpm
RUN fpm -s dir -t rpm -n nginxzip --config-files /etc/nginxzip/nginx.conf -v ${NGINX_VERSION} /nginx-source/nginx-${NGINX_VERSION}/bin/nginxzip=/usr/local/smartfile/bin/nginxzip /etc/nginx/nginx.conf=/etc/nginxzip/nginx.conf
RUN cd /nginx-source/nginx-${NGINX_VERSION} && make install