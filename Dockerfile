FROM debian:8

LABEL MAINTAINER="Xuebk <mail@xuebk.cn>"
# less priviledge user, the id should map the user the downloaded files belongs to
RUN groupadd -r dummy && useradd -r -g dummy dummy -u 1000

# webui + aria2
RUN apt-get update \
	&& apt-get install -y aria2 busybox curl unzip \
	&& rm -rf /var/lib/apt/lists/*

# gosu install latest
RUN GITHUB_REPO="https://github.com/tianon/gosu" \
  && LATEST=`curl -s  $GITHUB_REPO"/releases/latest" | grep -Eo "[0-9].[0-9]*"` \
  && curl -L $GITHUB_REPO"/releases/download/"$LATEST"/gosu-amd64" > /usr/local/bin/gosu \
  && chmod +x /usr/local/bin/gosu

# goreman supervisor install latest
RUN GITHUB_REPO="https://github.com/mattn/goreman" \
  && LATEST=`curl -s  $GITHUB_REPO"/releases/latest" | grep -Eo "v[0-9]*.[0-9]*.[0-9]*"` \
  && curl -L $GITHUB_REPO"/releases/download/"$LATEST"/goreman_linux_amd64.zip" > goreman.zip \
  && unzip goreman.zip && mv /goreman /usr/local/bin/goreman && rm -R goreman*

# AriaNg install latest
RUN AriaNg_REPO="https://github.com/mayswind/AriaNg" \
  && LATEST="1.1.4" \
  && mkdir -p /AriaNg \
  && cd AriaNg && curl -L $AriaNg_REPO"/releases/download/"$LATEST"/AriaNg-"$LATEST"-AllInOne.zip" > AriaNg-AllInOne.zip \
  && unzip AriaNg-AllInOne.zip

# goreman setup
RUN echo "web: gosu dummy /bin/busybox httpd -f -p 8080 -h /AriaNg\nbackend: gosu dummy /usr/bin/aria2c --enable-rpc --rpc-listen-all --dir=/data" > Procfile

# aria2 downloads directory
VOLUME /data

# aria2 RPC port, map as-is or reconfigure webui
EXPOSE 6800/tcp

# webui static content web server, map wherever is convenient
EXPOSE 8080/tcp

CMD ["start"]
ENTRYPOINT ["/usr/local/bin/goreman"]