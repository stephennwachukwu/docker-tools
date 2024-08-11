#!/bin/bash

set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <docker-compose-file> [--dry-run] [--include-stopped]"
  exit 1
fi

COMPOSE_FILE=$1
DRY_RUN=0
INCLUDE_STOPPED=0

shift
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --include-stopped)
      INCLUDE_STOPPED=1
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo "Stopping and removing containers defined in Docker Compose..."
if [ $DRY_RUN -eq 0 ]; then
  docker-compose -f "$COMPOSE_FILE" down
else
  echo "[DRY RUN] Would stop and remove containers defined in Docker Compose"
fi

echo "Identifying images to keep..."
EXCLUDE_IMAGES=("postgres" "rabbitmq")
EXCLUDE_IDS=($(docker images --filter "reference=${EXCLUDE_IMAGES[*]}" -q))
EXCLUDE_IDS+=($(docker-compose -f "$COMPOSE_FILE" images -q))

# Exclude images used by running containers
EXCLUDE_IDS+=($(docker ps -q | xargs -r docker inspect --format='{{.Image}}'))

# Optionally exclude images used by stopped containers
if [ $INCLUDE_STOPPED -eq 0 ]; then
  EXCLUDE_IDS+=($(docker ps -a -q | xargs -r docker inspect --format='{{.Image}}'))
fi

EXCLUDE_IDS=($(echo "${EXCLUDE_IDS[@]}" | tr ' ' '\n' | sort -u))

echo "Removing unused images..."
ALL_IMAGES=($(docker images -q))
IMAGES_TO_REMOVE=($(comm -23 <(printf '%s\n' "${ALL_IMAGES[@]}" | sort) <(printf '%s\n' "${EXCLUDE_IDS[@]}" | sort)))
if [ ${#IMAGES_TO_REMOVE[@]} -gt 0 ]; then
  if [ $DRY_RUN -eq 0 ]; then
    docker rmi "${IMAGES_TO_REMOVE[@]}" --force
  else
    echo "[DRY RUN] Would remove these images: ${IMAGES_TO_REMOVE[*]}"
  fi
else
  echo "No unused images to remove."
fi

echo "Removing unused volumes..."
USED_VOLUMES=$(docker-compose -f "$COMPOSE_FILE" config --volumes)
if [ $DRY_RUN -eq 0 ]; then
  docker volume ls -q | xargs -I {} docker volume inspect {} --format '{{.Name}} {{.Mountpoint}}' | grep -vE "$USED_VOLUMES" | awk '{print $1}' | xargs -r docker volume rm -f
else
  echo "[DRY RUN] Would remove unused volumes"
fi

echo "Removing unused networks..."
USED_NETWORKS=$(docker-compose -f "$COMPOSE_FILE" config --networks)
if [ $DRY_RUN -eq 0 ]; then
  docker network ls -q | xargs -I {} docker network inspect {} --format '{{.Name}}' | grep -vE "$USED_NETWORKS" | xargs -r docker network rm
else
  echo "[DRY RUN] Would remove unused networks"
fi

echo "Cleaning build cache..."
if [ $DRY_RUN -eq 0 ]; then
  docker builder prune -f
else
  echo "[DRY RUN] Would clean build cache"
fi

echo "Cleanup complete."
