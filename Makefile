GOSS_VERSION := 0.3.6
GIT_VERSION := $(shell git rev-parse HEAD)

all: pull build

pull:
	docker pull traefik:1.7

build:
	docker build \
		-t bearstech/traefik-dev \
		--build-arg GIT_VERSION=${GIT_VERSION} \
		-f Dockerfile \
		.

push:
	docker push bearstech/traefik-dev

remove_image:
	docker rmi bearstech/traefik-dev

test: bin/${GOSS_VERSION}/goss
	docker-compose -f tests_traefik/docker-compose.yml up -d \
		traefik mirror auth-mirror empty-auth-mirror mysql
	docker-compose -f tests_traefik/docker-compose.yml exec -T traefik wait_for_services -vd 2 --timeout 20
	docker-compose -f tests_traefik/docker-compose.yml exec -T traefik traefik_hosts \
		| grep " auth empty-auth traefik"
	docker-compose -f tests_traefik/docker-compose.yml run goss \
		goss -g web.yaml validate --max-concurrent 4 --format documentation
	docker-compose -f tests_traefik/docker-compose.yml down || true

down:
	docker-compose -f tests_traefik/docker-compose.yml down || true

tests: test

bin/${GOSS_VERSION}/goss:
	mkdir -p bin/${GOSS_VERSION}/
	curl -o bin/${GOSS_VERSION}/goss -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64
	chmod +x bin/${GOSS_VERSION}/goss
	cd bin && ln -s ${GOSS_VERSION} current
