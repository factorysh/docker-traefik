GOSS_VERSION := 0.3.5

all: pull build

pull:
	docker pull traefik

build:
	docker build -t bearstech/traefik-dev -f Dockerfile .

push:
	docker push bearstech/traefik-dev

test: bin/goss
	docker-compose -f tests/docker-compose.yml up -d traefik mirror
	sleep 1
	docker-compose -f tests/docker-compose.yml run goss \
		goss -g web.yaml validate --max-concurrent 4 --format documentation
	docker-compose -f tests/docker-compose.yml down || true

tests: test

bin/goss:
	mkdir -p bin
	curl -o bin/goss -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64
	chmod +x bin/goss
