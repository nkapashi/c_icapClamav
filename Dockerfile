# Build a docker image for clamav/clamd

FROM alpine:latest

LABEL maintainer "nkapashi"

ENV cicapBaseVersion="0.5.2" cicapModuleVersion="0.4.5"

WORKDIR /

# 1. create needed directories
RUN mkdir -p /tmp/install && mkdir -p /opt/c-icap && mkdir -p /var/log/c-icap/ && mkdir -p /run/clamav && \
	cd /tmp/install && \

# 2. install needed packages
	apk --update --no-cache add \
		bzip2 \
		bzip2-dev \ 
		zlib \
		zlib-dev \
		curl \
		tar \
		gcc \
		make \
		g++ \
		clamav \ 
		clamav-libunrar && \

# 3. download c_icap, c_icap modules and install them 
	curl --silent --location --remote-name "http://downloads.sourceforge.net/project/c-icap/c-icap/0.5.x/c_icap-${cicapBaseVersion}.tar.gz" && \
	curl --silent --location --remote-name "https://sourceforge.net/projects/c-icap/files/c-icap-modules/0.4.x/c_icap_modules-${cicapModuleVersion}.tar.gz" && \
	tar -xzf "c_icap-${cicapBaseVersion}.tar.gz" && tar -xzf "c_icap_modules-${cicapModuleVersion}.tar.gz" && cd c_icap-${cicapBaseVersion} && \
	./configure --quiet --prefix=/opt/c-icap --enable-large-files && make && make install && \
	cd ../c_icap_modules-${cicapModuleVersion}/ && ./configure --quiet --with-c-icap=/opt/c-icap --prefix=/opt/c-icap && \
	make && make install && \

# 4. configure clamav and initialize anti-virus database
	chown clamav:clamav /run/clamav && \
	sed -i 's/^#Foreground .*$/Foreground true/g' /etc/clamav/clamd.conf && \
	sed -i 's/^#Foreground .*$/Foreground true/g' /etc/clamav/freshclam.conf && \
	sed -i 's/#MaxAttempts .*$/MaxAttempts 5/g' /etc/clamav/freshclam.conf && \
	sed -i 's/#DatabaseMirror .*$/DatabaseMirror db.US.clamav.net/g' /etc/clamav/freshclam.conf && \

# 5. clean up
	cd / && rm -rf /tmp/install && \
	apk del \
		bzip2 \
		bzip2-dev \ 
		zlib \
		zlib-dev \
		curl \
		tar \
		gcc \
		make \
		g++

# 6. add configuration file and antivrus database file
		
ADD ./etc /opt/c-icap/etc
ADD ./opt /opt
COPY custom_vir_sig.ndb /var/lib/clamav/ 
CMD chmod +x /opt/start.sh; sync && /opt/start.sh && /bin/sh