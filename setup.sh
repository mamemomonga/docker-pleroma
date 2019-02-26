#!/bin/bash
set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"  && pwd )"
source $BASEDIR/.env


do_init() {
	docker volume create $VOLUME_CONFIG
	docker volume create $VOLUME_BUILD
	docker volume create $VOLUME_UPLOAD
	docker volume create $VOLUME_DB

	CONTAINER_NAME="pleroma-setup-$$"

	# Pleroma初期設定とconfigとbuildキャッシュのコピー
	docker run --rm \
		-v $VOLUME_CONFIG:/mnt/config \
		-v $VOLUME_BUILD:/mnt/_build \
		$IMAGE_NAME instance_gen \
		--domain $DOMAIN --instance-name $INSTANCE_NAME --admin-email $ADMIN_EMAIL \
		--dbhost $DBHOST --dbname $DBNAME --dbuser $DBUSER --dbpass $DBPASS

	do_config_get

	# PostgreSQL
	# 初期化のみ行いたいが、postgresを起動しないとentrypointが初期化を行わないため、
	# 何もしない postgresとしてbootstrapingモードで起動する。
	# docker-composeに初期化用SQLを含めたくないので docker run で実行
	docker run --rm \
		-v $VOLUME_DB:/var/lib/postgresql/data \
		-v $BASEDIR/config/setup_db.psql:/docker-entrypoint-initdb.d/setup_db.sql:ro \
		--env-file=$BASEDIR/.env \
		postgres:10.7 postgres --boot

	mv config/{generated_config.exs,prod.secret.exs}
	do_config_put

	docker-compose up -d db
	docker-compose run --rm pleroma migrate
	docker-compose down

}

do_destroy() {
	docker-compose down || true
	docker volume rm $VOLUME_CONFIG || true
	docker volume rm $VOLUME_BUILD || true
	docker volume rm $VOLUME_UPLOAD || true
	docker volume rm $VOLUME_DB || true
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
	echo "  destroy"
	echo "  get"
	echo "  put"
	exit 1
}


case "${1:-}" in
	"init" ) do_init ;;
	"get" )  do_config_get ;;
	"put" )  do_config_put ;;
	"destroy") do_destroy ;;
	* )      usage ;;
esac

