build:
	docker build -t bearstech/traefik-dev -f Dockerfile .

up: build
	docker-compose -f traefik-compose.yml up
