FROM elixir:1.8.1-alpine

RUN set -xe && \
        apk --update add tzdata su-exec git git build-base && \
        cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
        apk del tzdata && \
        rm -rf /var/cache/apk/*

ENV BRANCH=release-0.9.9
RUN set -xe && \
        adduser -S -s /bin/false -h /opt/pleroma -H pleroma && \
        mkdir -p /opt/pleroma && \
        chown -R pleroma:nogroup /opt/pleroma && \
        su-exec pleroma git clone https://git.pleroma.social/pleroma/pleroma /opt/pleroma && \
        cd /opt/pleroma && \
        su-exec pleroma git checkout ${BRANCH} && \
        su-exec pleroma mix local.rebar --force && \
        su-exec pleroma mix local.hex --force && \
        su-exec pleroma mix deps.get && \
        su-exec pleroma mix compile && \
        rm -rf /var/cache/apk/*

WORKDIR /opt/pleroma

CMD ["sh","-xec","mix local.rebar --force; mix local.hex --force; exec mix phx.server"]

