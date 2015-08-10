# nginx-mod-zip
Nginx with mod_zip module

### Dependencies
fpm (RPM builder) https://github.com/jordansissel/fpm
```
gem install fpm
```

### Build
```
# Builds executable: bin/nginx
make
```

### Build RPM
```
# Builds RPM: nginxzip-1.0.0-1.x86_64.rpm
make rpm
```

### Installation
When the RPM is installed, it can be found at `/usr/local/smartfile/bin`
