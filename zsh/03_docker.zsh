export UID=$(id -u)
export GID=$(id -g)
export DOCKER_BUILDKIT=1
# Apple Silicon users only:
export DOCKER_DEFAULT_PLATFORM=linux/amd64
