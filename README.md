# Pleroma Docker

## Setup

	$ git clone https://github.com/mamemomonga/docker-pleroma.git
	$ cd docker-pleroma
	$ cp .env.example .env
	$ vim .env
	$ docker-compose pull
	$ ./setup.sh init
	$ docker-compose up

## Get current config

	$ ./setup.sh get

## Put config

	$ ./setup.sh put

## Destroy

	$ ./setup.sh destroy


* https://hub.docker.com/r/mamemomonga/pleroma
* https://git.pleroma.social/pleroma/pleroma/wikis/Installing%20on%20Alpine%20Linux
