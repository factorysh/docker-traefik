
include Makefile.lint
include Makefile.build_args

GOSS_VERSION := 0.3.6

TRAEFIK_VERSION := 2.0

export TRAEFIK_VERSION

all: pull build

pull:
	docker pull traefik:$(TRAEFIK_VERSION)

build:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg TRAEFIK_VERSION=$(TRAEFIK_VERSION) \
		-t bearstech/traefik-dev:$(TRAEFIK_VERSION) \
		-f Dockerfile-$(TRAEFIK_VERSION) \
		.
	 docker tag bearstech/traefik-dev:$(TRAEFIK_VERSION) bearstech/traefik-dev:latest

push:
	docker push bearstech/traefik-dev:$(TRAEFIK_VERSION)
# we dont want to push 2.0 as latest for now
#	docker push bearstech/traefik-dev:latest

remove_image:
	docker rmi bearstech/traefik-dev

test: bin/${GOSS_VERSION}/goss
	rm -f hosts
	touch hosts
	docker-compose -f tests_traefik/docker-compose.yml up -d
	docker-compose -f tests_traefik/docker-compose.yml exec -T traefik \
		wait_for_services -vd 2 --timeout 120
	docker-compose -f tests_traefik/docker-compose.yml exec -T traefik \
		traefik_hosts > hosts
	docker-compose -f tests_traefik/docker-compose.yml exec -T traefik traefik_hosts \
		| grep " auth empty-auth mirror"
	docker-compose -f tests_traefik/docker-compose.yml run goss \
		goss -g web-$(TRAEFIK_VERSION).yaml validate --max-concurrent 4 --format documentation
	docker-compose -f tests_traefik/docker-compose.yml down || true

down:
	docker-compose -f tests_traefik/docker-compose.yml down || true

tests: test

bin/${GOSS_VERSION}/goss:
	mkdir -p bin/${GOSS_VERSION}/
	curl -o bin/${GOSS_VERSION}/goss -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64
	chmod +x bin/${GOSS_VERSION}/goss
	cd bin && ln -s ${GOSS_VERSION} current
