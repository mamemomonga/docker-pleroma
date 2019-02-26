#!/bin/bash
set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"  && pwd )"
source $BASEDIR/.env


do_init() {
	docker volume create $VOLUME_CONFIG
	docker volume create $VOLUME_UPLOAD
	docker volume create $VOLUME_DB

	CONTAINER_NAME="pleroma-setup-$$"

	# Pleroma
	# .env $B$G@_Dj$7$?$N4D6-JQ?t$+$i@_Dj%U%!%$%k$r@8@.$5$;$k(B
	docker run -d --name $CONTAINER_NAME $IMAGE_NAME sh -c 'while true; do sleep 1; done'

	docker exec -i $CONTAINER_NAME su-exec pleroma sh -c "cd /opt/pleroma; mix pleroma.instance gen \
		--domain $DOMAIN --instance-name $INSTANCE_NAME --admin-email $ADMIN_EMAIL \
		--dbhost $DBHOST --dbname $DBNAME --dbuser $DBUSER --dbpass $DBPASS"

	docker exec $CONTAINER_NAME su-exec pleroma tar zcC /opt/pleroma/config . | docker run --rm -i -v $VOLUME_CONFIG:/config busybox tar zxvpC /config
	docker rm -f $CONTAINER_NAME

	do_config_get

	# PostgreSQL
	# $B=i4|2=$N$_9T$$$?$$$,!"(Bpostgres$B$r5/F0$7$J$$$H(Bentrypoint$B$,=i4|2=$r9T$o$J$$$?$a!"(B
	# $B2?$b$7$J$$(B postgres$B$H$7$F(Bbootstraping$B%b!<%I$G5/F0$9$k!#(B
	# docker-compose$B$K=i4|2=MQ(BSQL$B$r4^$a$?$/$J$$$N$G(B docker run $B$G<B9T(B
	docker run --rm \
		-v $VOLUME_DB:/var/lib/postgresql/data \
		-v $BASEDIR/config/setup_db.psql:/docker-entrypoint-initdb.d/setup_db.sql:ro \
		--env-file=$BASEDIR/.env \
		postgres:10.7 postgres --boot

	mv config/{generated_config.exs,prod.secret.exs}

	do_config_put

	docker-compose up -d db
	docker-compose run --rm pleroma sh -c 'mix local.rebar --force; mix local.hex --force; mix ecto.migrate'
	docker-compose down
}

do_config_get() {
	cd $BASEDIR
	mkdir -p config
	docker run --rm -v $VOLUME_CONFIG:/opt/pleroma/config $IMAGE_NAME tar cC /opt/pleroma/config . | tar xvC config
}

do_config_put() {
	cd $BASEDIR
	docker volume rm $VOLUME_CONFIG
	docker volume create $VOLUME_CONFIG
	tar c config | docker run -i --rm -v $VOLUME_CONFIG:/opt/pleroma/config $IMAGE_NAME tar xvC /opt/pleroma
	docker run --rm -v $VOLUME_CONFIG:/opt/pleroma/config $IMAGE_NAME chown -R pleroma:nobody /opt/pleroma/config
}

usage() {
	echo "USAGE: $0 COMMAND"
	echo "COMMANDS:"
	echo "  init"
	echo "  get"
	echo "  put"
	exit 1
}


case "${1:-}" in
	"init" ) do_init ;;
	"get" )  do_config_get ;;
	"put" )  do_config_put ;;
	* )      usage ;;
esac

