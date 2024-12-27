FROM python:3.13-slim

USER root
RUN apt-get update
RUN apt-get install build-essential libpq-dev -y 
RUN pip install -U pip setuptools wheel

WORKDIR /work
ADD pyproject.toml pyproject.toml
RUN pip install uv
RUN uv sync

COPY ./src /src

CMD ["uv", "run", "/src/main.py"]
