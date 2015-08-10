# nginx-mod-zip
Nginx with mod_zip module

### Dependencies
fpm (RPM builder) https://github.com/jordansissel/fpm
```
gem install fpm
```
rpm-build
```
yum install rpm-build
```

### Build
```
# Builds executable: bin/nginxzip
make
```

### Build RPM
To build RPMs, be sure to use CentOS
```
# Builds RPM: nginxzip-1.0.0-1.x86_64.rpm
make rpm
```

### Installation
When the RPM is installed, the binary can be found at `/usr/local/smartfile/bin/nginxzip`
