CFLAGS=--add-module=../mod_zip --without-http_rewrite_module

SRC_DIR = src
BIN_DIR = bin
EXECUTABLE=$(BIN_DIR)/nginxzip

all: clean
	mkdir $(SRC_DIR)
	cd $(SRC_DIR) && wget http://nginx.org/download/nginx-1.8.0.tar.gz
	cd $(SRC_DIR) && tar -xf nginx-1.8.0.tar.gz
	cd $(SRC_DIR) && git clone https://github.com/evanmiller/mod_zip.git
	cd $(SRC_DIR)/nginx-1.8.0 && ./configure $(CFLAGS)
	cd $(SRC_DIR)/nginx-1.8.0 && $(MAKE)
	mkdir $(BIN_DIR)
	cp $(SRC_DIR)/nginx-1.8.0/objs/nginx $(EXECUTABLE)

rpm: all
	fpm \
		-s dir \
		-t rpm \
		-n nginxzip \
		--config-files /etc/nginxzip/nginx.conf \
		-v 1.0.0 \
		$(EXECUTABLE)=/usr/local/smartfile/bin \
		nginx.conf=/etc/nginxzip/nginx.conf
	

clean:
	$(RM) -rf $(SRC_DIR) $(BIN_DIR) *.rpm
