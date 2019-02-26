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
		shift
		su-exec pleroma mix local.rebar --force
		su-exec pleroma mix local.hex --force
		su-exec pleroma mix pleroma.instance gen $@
		tar cC /opt/pleroma/config . | tar xvpC /mnt/config
		tar cC /opt/pleroma/_build . | tar xvpC /mnt/_build
		;;

	* )
		exec $@
		;;
esac

