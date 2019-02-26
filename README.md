# Pleroma Docker

## Setup

	$ cp .env.example .env
	$ docker-compose pull
	$ ./setup.sh init
	$ docker-compose up

## Get current config

	$ ./setup.sh get

## Put config

	$ ./setup.sh put

## Reset

	$ docker-compose down; docker volume rm pleroma-config pleroma-db pleroma-upload; rm -rf config

https://git.pleroma.social/pleroma/pleroma/wikis/Installing%20on%20Alpine%20Linux
