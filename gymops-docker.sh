#!/usr/bin/env bash
set -e

# Script auxiliar para ejecutar GymOps en Docker
docker compose run --rm app "$@"
