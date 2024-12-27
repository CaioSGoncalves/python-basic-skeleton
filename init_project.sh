#!/bin/bash

# Check if project name is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <project_name>"
    exit 1
fi

PROJECT_NAME=$1
PYTHON_VERSION=3.13

# Create project directories
mkdir -p src

# Create Dockerfile
cat <<EOF > Dockerfile
FROM python:$PYTHON_VERSION-slim

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
EOF

# Create src/main.py
cat <<EOF > src/main.py
def main():
    print("MAIN!")

if __name__ == "__main__":
    main()

EOF

# Create src/config.py
cat <<EOF > src/config.py
from pydantic import Field
from pydantic_settings import BaseSettings

class Settings(BaseSettings):    
        APP_ENV: str = Field(None, description="App environment")
        
        class Config:
                env_file = ".env"
EOF

# Create Makefile
echo "build:\n\truff format &&\\" >> Makefile
echo "\tdocker build -t $PROJECT_NAME -f Dockerfile . --no-cache" >> Makefile
echo "\nrun:\n\truff format &&\\" >> Makefile
echo "\tdocker build -t $PROJECT_NAME -f Dockerfile . &&\\" >> Makefile
echo "\tdocker-compose up $PROJECT_NAME" >> Makefile
echo "\nlint:\n\truff format" >> Makefile

# Create .env file
cat <<EOF > .env
APP_ENV=dev
EOF

# Create docker-compose.yml
cat <<EOF > docker-compose.yml
services:
    $PROJECT_NAME:
        image: $PROJECT_NAME:latest
        container_name: $PROJECT_NAME
        env_file:
            - .env
EOF

# Initialize the project with uv
uv venv --python $PYTHON_VERSION
uv init

# Add the required packages
uv add --dev ruff ipykernel
uv add pydantic pydantic-settings
rm hello.py

# Create README.md
cat <<EOF > README.md
# $PROJECT_NAME

## 📝 **Description**
This is a simple project with Docker, Python, uv, lint(ruff) and env manager(pydantic).

## 🛠 **Dependencies**
- Docker
- Docker Compose

## 🚀 **Running**
1. Build the Docker image:
    \`\`\`sh
    make build
    \`\`\`
2. Run the app:
    \`\`\`sh
    make run
    \`\`\`
EOF