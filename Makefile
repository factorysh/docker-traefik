build:
	docker build -t bearstech/traefik-dev -f Dockerfile .

up: build
	docker-compose -f traefik-compose.yml up

pull:
	docker pull traefik

push:
	docker push bearstech/traefik-dev
