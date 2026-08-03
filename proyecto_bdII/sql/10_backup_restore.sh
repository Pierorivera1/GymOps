#!/usr/bin/env bash
# =============================================================================
# GymOps — Base de Datos II
# Script 10: Backup lógico y recuperación con pg_dump / pg_restore
# Gestor: PostgreSQL 16 (contenedor Docker "gymops-db")
# Autor: Piero Rivera
# =============================================================================
# pg_dump es una herramienta de línea de comandos (NO un comando SQL): se
# conecta a la BD como un cliente y genera las instrucciones SQL necesarias
# para reconstruirla desde cero (backup LÓGICO). Se ejecuta vía `docker exec`
# para usar el pg_dump de la misma versión 16 del servidor.
#
# Uso: bash 10_backup_restore.sh
# Documentación completa: proyecto_bdII/BACKUP_RECUPERACION.md
# =============================================================================
set -euo pipefail

# -----------------------------------------------------------------------------
# 1. Backup en formato PLANO (.sql)
#    Genera un archivo de texto legible con CREATE TABLE, COPY, funciones, etc.
#    Se restaura con psql. Ideal para inspeccionar o versionar.
# -----------------------------------------------------------------------------
docker exec gymops-db pg_dump -U gymops gymops_db > backup_gymops.sql
echo "[1/4] Backup plano generado: backup_gymops.sql ($(du -h backup_gymops.sql | cut -f1))"

# -----------------------------------------------------------------------------
# 2. Backup en formato CUSTOM (-Fc, comprimido)
#    Formato binario propio de PostgreSQL: más pequeño y permite restaurar
#    objetos sueltos (una tabla, un índice). Se restaura con pg_restore.
# -----------------------------------------------------------------------------
docker exec gymops-db pg_dump -U gymops -Fc gymops_db > gymops.dump
echo "[2/4] Backup custom generado: gymops.dump ($(du -h gymops.dump | cut -f1))"

# -----------------------------------------------------------------------------
# 3. Restauración a una BD nueva (gymops_restore)
#    Se restaura sobre una BD aparte para verificar el backup sin tocar la
#    original. --if-exists evita error si se re-ejecuta el script.
# -----------------------------------------------------------------------------
docker exec gymops-db dropdb   -U gymops --if-exists gymops_restore
docker exec gymops-db createdb -U gymops gymops_restore
docker exec -i gymops-db pg_restore -U gymops -d gymops_restore < gymops.dump
echo "[3/4] Backup restaurado en la BD gymops_restore"

# -----------------------------------------------------------------------------
# 4. Verificación: comparar filas de workout_set entre original y restaurada
# -----------------------------------------------------------------------------
orig=$(docker exec gymops-db psql -U gymops -d gymops_db      -tAc "SELECT COUNT(*) FROM workout_set;")
rest=$(docker exec gymops-db psql -U gymops -d gymops_restore -tAc "SELECT COUNT(*) FROM workout_set;")
echo "[4/4] workout_set — original: $orig filas | restaurada: $rest filas"
[ "$orig" = "$rest" ] && echo "OK: backup y restauración verificados." \
                      || { echo "ERROR: los conteos no coinciden."; exit 1; }
