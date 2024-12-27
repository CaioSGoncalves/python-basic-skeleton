build:
	ruff format &&\
	docker build -t python-basic-skeleton -f Dockerfile . --no-cache

run:
	ruff format &&\
	docker build -t python-basic-skeleton -f Dockerfile . &&\
	docker-compose up python-basic-skeleton

lint:
	ruff format
