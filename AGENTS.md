# AGENTS.md

## Proyecto: GymOps-FIEI

CLI de seguimiento de entrenamiento en Python, pero el propósito real es ser el
**proyecto final de Base de Datos II (UNFV)**. El enfoque es demostrar uso avanzado
de PostgreSQL: toda la lógica de negocio (1RM, detección de PRs, auditoría,
validaciones) vive en la BD vía SPs/funciones/triggers, no en Python. El CLI es
solo capa de presentación sobre `psycopg2`.

## Stack
- Python 3.12, Typer, Rich, psycopg2 (sin ORM)
- PostgreSQL 16 corriendo en Docker (contenedor `gymops-db`, no siempre está
  levantado — verificar con `docker ps` y `docker start gymops-db` si hace falta).
  Este proyecto usa **exclusivamente PostgreSQL**; si `docker ps -a` muestra otros
  contenedores (ej. `mssql`, `postgres18`), son de otros proyectos del usuario y
  no tienen relación con GymOps — ignorarlos.
- `uv` para entorno y paquetes
- Sin CI/CD, sin Azure, sin Terraform

## Conexión a la BD
```
host=localhost port=5432 user=gymops password=gymops_pass dbname=gymops_db
```
`gymops/db.py:init_db()` corre automáticamente los scripts SQL (`01_ddl` → `09_triggers`)
la primera vez que se invoca cualquier comando, si la tabla `exercise` no existe.

## Estructura clave
- `gymops/cli.py` — todos los comandos Typer
- `gymops/db.py` — capa de datos, todo el SQL que ejecuta la app
- `gymops/report.py` — generador del digest semanal (usa vistas + `sp_weekly_digest`)
- `proyecto_bdII/sql/01_ddl.sql` … `09_triggers.sql` — las 7 fases del proyecto SQL
- `proyecto_bdII/DESCRIPCION_PROYECTO.md` — problemática, objetivos, entidades,
  reglas de negocio, normalización (3FN), resumen de implementación SQL

## Archivos que existen localmente pero NO están en git
Se entregan al curso por Drive, no por GitHub (el repo es portafolio/CV, no canal
de entrega académica). Ver `.gitignore`:
- `proyecto_bdII/PLANNING.md` — roadmap por fases 1–7
- `proyecto_bdII/manual_usuario.md` — manual + guía por fase con el código SQL
  completo de cada comando (documento más grande y detallado del proyecto)
- `Formato_Proyecto_Final_Base_Datos_II.pdf` — formato oficial de la UNFV
- `INSTRUCCIONES.md` — notas de trabajo del usuario para dirigirme en sesiones

## Inventario de objetos SQL (verificado contra la BD real)
11 tablas (incluye `guide_article`, `active_program`) · 9 vistas · 15 índices ·
5 procedimientos almacenados · 6 funciones UDF · 6 triggers.

**Todos los objetos SQL están conectados a un comando del CLI** — no hay vistas,
SPs ni funciones huérfanas. Las únicas excepciones intencionales, sin comando
propio porque se demuestran indirectamente:
- Funciones escalares (`fn_epley_1rm`, `fn_volume`, `fn_is_pr`, `fn_session_volume`)
  — se ejecutan dentro de triggers/SPs cada vez que corres `gymops log`.
- Los 15 índices — se demuestran con `EXPLAIN ANALYZE`, no con un comando dedicado.

Comandos de reporte que conectan directamente vistas/SPs/funciones: `sessions`,
`progress`, `muscle-volume`, `list-exercises`, `show-program`, `pr-timeline`,
`exercise-stats`. El mapeo comando → objeto SQL está en `manual_usuario.md`
(local, no en git).

## Convenciones y preferencias del usuario
- Sin tests automáticos por defecto — solo correr `uv run pytest` si se pide
  explícitamente (el enfoque del curso es BD, no testing).
- Sin abstracciones ni features no pedidas — priorizar el mínimo cambio que
  cumple lo pedido.
- Antes de excluir algo de git, verificar si es un entregable real (ver
  `PLANNING.md` §5 "Entregables Finales") — no todo lo que parece "nota interna"
  lo es.
- `git push` a `main` directo está aprobado para este repo (proyecto personal).
- **Cuidado con el entry point de `gymops`:** el binario `.venv/bin/gymops` puede
  quedar apuntando a un `.venv` de otro directorio si se reinstaló desde otra ruta
  alguna vez. Si tras editar `cli.py`/`db.py` los cambios no se reflejan al correr
  `gymops <comando>`, verificar con
  `.venv/bin/python -c "import gymops.cli as c; print(c.__file__)"`
  que apunte a *este* repo, y si no, reinstalar con
  `uv pip install -e . --python .venv/bin/python`.

## Estado actual
Fases 1–7 del proyecto SQL completas. CLI con 18 comandos, todos mapeados a
objetos SQL reales. Documentación (`DESCRIPCION_PROYECTO.md`, `manual_usuario.md`,
`README.md`) actualizada y coherente entre sí.
