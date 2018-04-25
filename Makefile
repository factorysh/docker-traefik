all: pull build

pull:
	docker pull traefik

build:
	docker build -t bearstech/traefik-dev -f Dockerfile .

push:
	docker push bearstech/traefik-dev

test:
	docker-compose -f traefik-compose.yml up -d
	docker-compose -f traefik-compose.yml down || true

tests: test
