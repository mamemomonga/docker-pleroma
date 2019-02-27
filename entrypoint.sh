#!/bin/sh
set -eux


case "${1:-}" in

	"server" )
		export MIX_ENV=prod
		echo "START SERVER"
		su-exec pleroma mix local.rebar --force
		su-exec pleroma mix local.hex --force
		exec su-exec pleroma mix phx.server
		;;

	"migrate" )
		export MIX_ENV=prod
		su-exec pleroma mix local.rebar --force
		su-exec pleroma mix local.hex --force
		exec su-exec pleroma mix ecto.migrate
		;;

	"instance_gen")
		su-exec pleroma mix local.rebar --force
		su-exec pleroma mix local.hex --force

		su-exec pleroma mix pleroma.instance gen \
			--domain $DOMAIN --instance-name "$INSTANCE_NAME" --admin-email $ADMIN_EMAIL \
			--dbhost $DBHOST --dbname $DBNAME --dbuser $DBUSER --dbpass $DBPASS

		tar cC /opt/pleroma/config . | tar xpC /mnt/config
		tar cC /opt/pleroma/_build . | tar xpC /mnt/_build
		;;

	* )
		exec $@
		;;
esac

