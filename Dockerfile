# Build a docker image for clamav/clamd

FROM alpine:3.20

LABEL maintainer="nkapashi"

ENV cicapBaseVersion="0.5.2" \
	cicapModuleVersion="0.4.5" \
	CFLAGS="-std=gnu17"

WORKDIR /

# 1. Create directories, install packages, build c-icap and clean up.
RUN set -eux; \
	mkdir -p /tmp/install /opt/c-icap /var/log/c-icap/ /run/clamav; \
	apk add --no-cache \
		bzip2 \
		clamav \
		clamav-libunrar \
		zlib; \
	apk add --no-cache --virtual .build-deps \
		bzip2-dev \
		curl \
		file \
		g++ \
		gcc \
		make \
		tar \
		zlib-dev; \
	cd /tmp/install; \
	curl --fail --silent --show-error --location --remote-name "http://downloads.sourceforge.net/project/c-icap/c-icap/0.5.x/c_icap-${cicapBaseVersion}.tar.gz"; \
	curl --fail --silent --show-error --location --remote-name "https://sourceforge.net/projects/c-icap/files/c-icap-modules/0.4.x/c_icap_modules-${cicapModuleVersion}.tar.gz"; \
	tar -xzf "c_icap-${cicapBaseVersion}.tar.gz"; \
	tar -xzf "c_icap_modules-${cicapModuleVersion}.tar.gz"; \
	cd "c_icap-${cicapBaseVersion}"; \
	./configure --quiet --prefix=/opt/c-icap --enable-large-files; \
	make; \
	make install; \
	cd "../c_icap_modules-${cicapModuleVersion}"; \
	./configure --quiet --with-c-icap=/opt/c-icap --prefix=/opt/c-icap; \
	make; \
	make install; \
	chown clamav:clamav /run/clamav; \
	sed -i 's/^#Foreground .*$/Foreground true/g' /etc/clamav/clamd.conf; \
	sed -i 's/^#Foreground .*$/Foreground true/g' /etc/clamav/freshclam.conf; \
	sed -i 's/#MaxAttempts .*$/MaxAttempts 5/g' /etc/clamav/freshclam.conf; \
	sed -i 's/#DatabaseMirror .*$/DatabaseMirror db.US.clamav.net/g' /etc/clamav/freshclam.conf; \
	cd /; \
	rm -rf /tmp/install /opt/c-icap/etc/*.default; \
	apk del .build-deps

# 2. Add configuration file and antivirus database file
		
COPY ./etc /opt/c-icap/etc
COPY ./opt /opt
COPY custom_vir_sig.ndb /var/lib/clamav/
RUN chmod +x /opt/start.sh

CMD ["sh", "-c", "sync && /opt/start.sh && /bin/sh"]
