FROM centos:7.5.1804
ARG nginx_version
RUN echo "nginx version is $nginx_version"
COPY nginx.conf /etc/nginx/nginx.conf
RUN yum makecache && yum -y groupinstall 'Development Tools' && yum install -y zlib-devel ruby-devel gcc make rpm-build libevent libevent-devel libaio-devel openssl-devel pcre-devel && mkdir /nginx-source
RUN cd /nginx-source && git clone https://github.com/evanmiller/mod_zip.git
#RUN cd /nginx-source && git clone https://github.com/travcunn/nginx-upload-module.git
RUN cd /nginx-source && git clone https://github.com/fdintino/nginx-upload-module.git
RUN cd /nginx-source && curl -O https://ftp.pcre.org/pub/pcre/pcre-8.42.tar.gz
RUN cd /nginx-source && tar -zxvf /nginx-source/pcre-8.42.tar.gz
RUN cd /nginx-source && curl -O http://nginx.org/download/nginx-${nginx_version}.tar.gz
RUN cd /nginx-source && tar -zxvf /nginx-source/nginx-${nginx_version}.tar.gz
RUN mkdir -p /tmp/.nginx/client_body /tmp/.nginx/proxy_temp /tmp/.nginx/fastcgi_temp /tmp/.nginx/uwsgi_temp /tmp/.nginx/scgi_temp 
# Compile Nginx with mod_zip
#RUN curl -O https://nginx.org/download/nginx-${nginx_version}.tar.gz && tar zxvf nginx-${nginx_version}.tar.gz

# Compile Nginx with nginx-upload-module and mod_zip
RUN cd /nginx-source/nginx-${nginx_version} && ./configure --prefix=/usr/share/nginx \
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
            --with-pcre=/nginx-source/pcre-8.42 \
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
            --with-stream \
            --with-debug \
            --with-cc-opt='-O2 -g -pipe -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -pie -fPIE -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic'
RUN cd /nginx-source/nginx-${nginx_version} && make && mkdir /nginx-source/nginx-${nginx_version}/bin && cp /nginx-source/nginx-${nginx_version}/objs/nginx /nginx-source/nginx-${nginx_version}/bin/nginxzip
RUN cd /nginx-source/nginx-${nginx_version} && ls -lah
RUN cd /nginx-source/nginx-${nginx_version} && make install
RUN gem install --no-ri --no-rdoc fpm
RUN fpm -s dir -t rpm -n nginxzip --config-files /etc/nginx -v ${nginx_version} /nginx-source/nginx-${nginx_version}/bin/nginxzip=/usr/bin/nginx /etc/nginx=/etc/nginx
RUN ls -lah
RUN rpm -qlp nginxzip-1.12.2-1.x86_64.rpm
