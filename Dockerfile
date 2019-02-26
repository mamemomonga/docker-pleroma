FROM elixir:1.7-alpine

RUN set -xe && \
	apk --update add tzdata su-exec git git build-base && \
	cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
	apk del tzdata && \
	rm -rf /var/cache/apk/*

RUN set -xe && \
	adduser -S -s /bin/false -h /opt/pleroma -H pleroma && \
	mkdir -p /opt/pleroma && \
	chown -R pleroma:nogroup /opt/pleroma

ENV BRANCH=master
WORKDIR /opt/pleroma

RUN set -xe && \
	su-exec pleroma git clone https://git.pleroma.social/pleroma/pleroma . && \
	su-exec pleroma git checkout ${BRANCH} && \
	su-exec pleroma mix local.rebar --force && \
	su-exec pleroma mix local.hex --force && \
	su-exec pleroma mix deps.get && \
	su-exec pleroma mix compile

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
