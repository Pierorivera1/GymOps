# GymOps-FIEI 🏋️

> Herramienta de seguimiento de entrenamiento para la terminal, construida como **proyecto final de Base de Datos II (UNFV)**.

> [!IMPORTANT]
> **Enfoque del proyecto.** GymOps es una aplicación CLI real, pero su propósito académico es demostrar el **uso avanzado de una base de datos relacional en PostgreSQL**. Toda la lógica de negocio (cálculo de 1RM, detección de PRs, auditoría, validaciones) vive en la base de datos mediante procedimientos almacenados, funciones, triggers, vistas e índices — no en el código Python, que actúa solo como capa de presentación sobre `psycopg2`. Cada comando del CLI está mapeado a los objetos SQL que ejecuta; el detalle por fase con el código SQL de cada uno se documenta en el manual de usuario entregado al curso (no incluido en este repositorio).

### ¿A quién va dirigido?
GymOps está diseñado principalmente para:
- **Estudiantes de Ingeniería Informática** y entusiastas de la tecnología familiarizados con la terminal. El uso de interfaces CLI/TUI es ideal por su compatibilidad con agentes de Inteligencia Artificial que pueden interactuar directamente con la terminal para automatizar tareas.
- **Principiantes y entusiastas del fitness** que desean comenzar a entrenar fuerza en el gimnasio o mediante otras modalidades. Ofrece la flexibilidad de registrar manualmente cualquier ejercicio (haciéndolo útil incluso para calistenia u otras disciplinas).

### Entrena con Ciencia
El sistema recopila información y principios de entrenamiento basados en la ciencia. GymOps viene precargado con splits conocidos y recomendados por su efectividad, científicamente estructurados. El usuario puede:
1. Revisar las rutinas disponibles.
2. Seleccionar la que mejor se adapte a su disponibilidad de tiempo y preferencias.
3. Seguir de forma guiada los ejercicios, series y repeticiones recomendados para optimizar sus resultados.

Todo funciona desde la terminal: sin apps en la nube, sin cuentas, sin distracciones. Inspirado en [lazygit](https://github.com/jesseduffield/lazygit) — la idea de que una buena herramienta de terminal no debe estorbarte, funcionar localmente y simplemente hacer su trabajo.

---

## ¿Para quién es GymOps?

| Perfil | Cómo lo ayuda GymOps |
|--------|----------------------|
| 🔰 **Sin experiencia** | Viene precargado con splits conocidos y recomendados por su efectividad. Solo elige la tuya y empieza a registrar. |
| 📈 **Intermedio** | Lleva el seguimiento de tus cargas, detecta si estás progresando y rompe tus PRs. |
| ⚙️ **Avanzado** | Crea tus propios programas y rutinas personalizadas desde la CLI. |

---

## Características

- **Rutinas listas para usar**: Viene precargado con splits conocidos y recomendados por su efectividad (Upper/Lower 4 días, ULPPL 5 días, PPL 6 días). Ideal para quienes no saben qué rutina hacer.
- **Programas personalizados**: Crea tus propios programas y días de entrenamiento desde la CLI.
- **Backend PostgreSQL**: Base de datos relacional completa con procedimientos almacenados, vistas, triggers e índices.
- **1RM estimado**: Calcula el máximo estimado de una repetición usando la fórmula de Epley después de cada serie.
- **Estadísticas de sobrecarga progresiva**: Compara el rendimiento de hoy contra tu última sesión para saber si estás mejorando.
- **Seguimiento de PRs**: Detecta y registra tus récords personales automáticamente.
- **Auditoría automática**: Todo cambio en sets y PRs queda registrado en un log de auditoría.
- **Resúmenes semanales**: Genera resúmenes en Markdown del volumen semanal de entrenamiento y mejores levantamientos.
- **CLI bilingüe**: Cambia entre inglés y español con `gymops set-language`.

---

## Inicio rápido

### Requisitos previos
- Python 3.12+
- [uv](https://github.com/astral-sh/uv)
- Docker (para PostgreSQL)

### Configuración

```bash
# Clonar el repositorio
git clone https://github.com/Pierorivera1/GymOps-FIEI.git
cd GymOps-FIEI

# Iniciar PostgreSQL con Docker
docker run --name gymops-db -e POSTGRES_USER=gymops \
  -e POSTGRES_PASSWORD=gymops_pass \
  -e POSTGRES_DB=gymops_db \
  -p 5432:5432 -d postgres:16

# Crear entorno virtual e instalar dependencias
uv venv
source .venv/bin/activate
uv pip install -e .

# Inicializar la base de datos (ejecutar los scripts SQL en orden)
psql -h localhost -U gymops -d gymops_db -f proyecto_bdII/sql/01_ddl.sql
psql -h localhost -U gymops -d gymops_db -f proyecto_bdII/sql/02_seed.sql

# Verificar que funciona
gymops --help
```

---

## Uso

```bash
# Establecer el idioma preferido (en / es)
gymops set-language es

# 1. Listar todos los programas de entrenamiento disponibles
gymops list-programs

# 2. Seleccionar el programa activo que seguirás
gymops select-program "Upper/Lower 4-Day"

# 3. Establecer el día de entrenamiento de hoy (hacerlo al inicio del entrenamiento)
gymops set-day "Upper A — Strength"

# 4. Registrar tus series mientras las realizas
gymops log --exercise "Barbell Bench Press" --sets 4 --reps 5 --weight 80

# 5. Revisar la sobrecarga progresiva vs la última sesión
gymops stats --exercise "Barbell Bench Press"

# 6. Ver tus récords personales
gymops prs

# 7. Ver el historial de un ejercicio
gymops history --exercise "Barbell Bench Press"

# 8. Agregar un ejercicio al catálogo
gymops add-exercise --name "Dumbbell Lateral Raise" --muscle-group "Shoulders" --type isolation

# 9. Crear un programa de entrenamiento personalizado
gymops add-program

# 10. Generar un resumen semanal en Markdown
gymops digest
```

### Comandos de análisis y reportes (consultan vistas, funciones y SPs)

```bash
# Resumen de sesiones recientes (vista v_session_summary)
gymops sessions

# Progresión de 1RM de un ejercicio en el tiempo (vista v_exercise_progress)
gymops progress --exercise "Barbell Bench Press"

# Volumen semanal por grupo muscular (vista v_muscle_volume_week / función fn_weekly_volume)
gymops muscle-volume
gymops muscle-volume --week 2026-06-22

# Catálogo de ejercicios con estadísticas de uso (vista v_exercise_catalog)
gymops list-exercises

# Estructura completa de un programa: días, ejercicios y objetivos (vista v_program_overview)
gymops show-program "Upper/Lower 4-Day"

# Línea de tiempo cronológica de todos los PRs (vista v_pr_timeline)
gymops pr-timeline

# Métricas completas de un ejercicio (procedimiento almacenado sp_get_exercise_stats)
gymops exercise-stats --exercise "Barbell Bench Press"
```

> Todos estos comandos consumen directamente objetos SQL del servidor. El mapeo completo comando → objeto SQL (con el código de cada vista, función, SP y trigger) está documentado por fase en el manual de usuario entregado al curso.

---

## Base de datos

GymOps corre sobre **PostgreSQL 16** (Docker). El esquema incluye:

| Objeto | Cantidad | Descripción |
|--------|----------|-------------|
| Tablas | 11 | Esquema relacional en 3FN (con desnormalización controlada por triggers) |
| Vistas | 9 (1 actualizable) | Reportes, seguridad y seguimiento de progreso |
| Índices | 15 | Índices B-tree, parciales y de expresión |
| Procedimientos almacenados | 5 `sp_*` + 2 `prc_*` (CALL) | Gestión de sesiones, log de sets, detección de PRs, mantenimiento |
| Funciones (UDF) | 6 | Fórmula Epley, volumen, historial por ejercicio |
| Triggers | 7 | Cálculo automático de 1RM, auditoría, validaciones, INSTEAD OF sobre vista |

### Scripts SQL (`proyecto_bdII/sql/`)

| Script | Propósito |
|--------|-----------|
| `01_ddl.sql` | Esquema: tablas, PKs, FKs, CHECKs |
| `02_seed.sql` | Datos iniciales: músculos, 51 ejercicios, 3 programas predeterminados |
| `03_dml.sql` | DML: sesiones, series, ejemplos de UPDATE/DELETE |
| `04_queries.sql` | 10 consultas avanzadas (CTE, funciones de ventana, RANK, LAG) |
| `05_views.sql` | 9 vistas para reportes y seguridad; `v_current_prs` actualizable vía trigger INSTEAD OF |
| `06_indexes.sql` | 15 índices + planes EXPLAIN ANALYZE |
| `07_procedures.sql` | 5 rutinas `sp_*` (FUNCTION/SELECT) + 2 procedimientos `prc_*` (PROCEDURE/CALL) |
| `08_functions.sql` | 6 funciones escalares y tipo tabla |
| `09_triggers.sql` | 6 triggers de auditoría, cálculo automático y validación |

### Modelo de datos (entidades principales)

| Entidad | Descripción |
|---------|-------------|
| `muscle_group` | Grupos musculares (pecho, espalda, piernas, hombros, etc.) |
| `exercise` | Catálogo maestro de ejercicios (nombre, músculo, tipo, equipamiento) |
| `program` | Programa de entrenamiento (ej: "Upper/Lower 4-Day") |
| `program_day` | Día dentro de un programa (ej: "Upper A — Strength") |
| `routine_exercise` | Ejercicios asignados a un día de programa (con series y reps objetivo) |
| `workout_session` | Sesión de entrenamiento realizada (fecha, programa y día) |
| `workout_set` | Set individual registrado (ejercicio, reps, peso, 1RM calculado) |
| `personal_record` | Récord personal por ejercicio (máximo 1RM histórico) |
| `audit_log` | Registro de auditoría de cambios en sets y PRs (JSONB) |
| `guide_article` | Guías y artículos de fitness (contenido en Markdown) |
| `active_program` | Tabla de control (fila única) con el programa y día activos |

> El detalle completo de normalización (justificación de 1FN/2FN/3FN y las desnormalizaciones deliberadas) está en [`proyecto_bdII/DESCRIPCION_PROYECTO.md`](proyecto_bdII/DESCRIPCION_PROYECTO.md) §1.8.

### Conexión

```
Host:          localhost
Puerto:        5432
Base de datos: gymops_db
Usuario:       gymops
Contraseña:    gymops_pass
```

---

## Requerimientos

### Funcionales

| ID | Requerimiento |
|----|---------------|
| RF-01 | Registrar ejercicios con nombre, grupo muscular, tipo y equipamiento |
| RF-02 | Crear y gestionar programas de entrenamiento con días y ejercicios asignados |
| RF-03 | Iniciar y cerrar sesiones de entrenamiento |
| RF-04 | Registrar sets (ejercicio, series, reps, peso) dentro de una sesión |
| RF-05 | Calcular automáticamente el 1RM estimado por cada set (fórmula Epley) |
| RF-06 | Detectar y registrar récords personales automáticamente |
| RF-07 | Mostrar estadísticas de progreso comparando sesiones pasadas vs actuales |
| RF-08 | Generar reportes semanales de volumen y mejores levantamientos |
| RF-09 | Consultar el historial de cualquier ejercicio |
| RF-10 | Registrar un log de auditoría de cambios en sets y PRs |

### No Funcionales

| ID | Requerimiento |
|----|---------------|
| RNF-01 | **Rendimiento:** Consultas frecuentes (historial, PRs) en < 100ms con índices |
| RNF-02 | **Integridad:** Todas las relaciones con FK y ON DELETE apropiado |
| RNF-03 | **Disponibilidad:** BD en Docker disponible localmente en todo momento |
| RNF-04 | **Usabilidad:** Salida formateada con Rich tables para todas las consultas |
| RNF-05 | **Mantenibilidad:** Todo el código SQL comentado y organizado por archivo |
| RNF-06 | **Portabilidad:** Scripts SQL compatibles con PostgreSQL 14+ |
| RNF-07 | **Trazabilidad:** Todo cambio en `workout_set` y `personal_record` auditado |

---

## Alcance

**Incluido en esta versión:**
- Módulo de gestión de ejercicios (catálogo por músculo y tipo)
- Módulo de programas de entrenamiento (splits, días, rutinas predefinidas y personalizadas)
- Módulo de sesiones de entrenamiento (log de sets por sesión)
- Módulo de análisis de progreso (1RM estimado, sobrecarga progresiva, PRs)
- Módulo de reportes (resúmenes semanales, estadísticas por ejercicio)
- Implementación SQL completa: DDL, DML, vistas, índices, SPs, funciones, triggers

**Fuera de alcance en esta versión:**
- Módulo de Administración y Seguridad (gestión de usuarios/roles de BD, backups automáticos, GRANT/REVOKE)
- Interfaz web o móvil (la aplicación es CLI/TUI)
- Sincronización en la nube

---

## Estructura del proyecto

```
GymOps-FIEI/
├── gymops/
│   ├── cli.py          # Todos los comandos Typer del CLI
│   ├── db.py           # Capa de base de datos (PostgreSQL)
│   ├── i18n.py         # Internacionalización (en / es)
│   ├── models.py       # Dataclasses: Workout, Exercise, PR, Routine
│   └── report.py       # Generador de resúmenes semanales
├── proyecto_bdII/
│   ├── DESCRIPCION_PROYECTO.md   # Descripción completa del proyecto (BD II)
│   └── sql/                      # Todos los scripts SQL (fases 1–7)
└── tests/              # Suite de pruebas con pytest
```

---

## Desarrollo y pruebas

> [!NOTE]
> Dado que esta versión está enfocada en el desarrollo de la Base de Datos, las pruebas unitarias e integración no son parte del flujo regular de trabajo y solo deben ejecutarse de manera explícita si se requiere validar el comportamiento CLI.

```bash
# Instalar requisitos de prueba
uv pip install pytest

# Ejecutar pruebas (solo bajo demanda explícita)
uv run pytest
```

---

## BD II — Proyecto de curso

Este repositorio es el **proyecto final de Base de Datos II** en la UNFV. La documentación completa (planning por fases, manual de usuario con el mapeo comando → código SQL, diagramas y formato oficial) se entrega al curso por separado; en este repositorio público queda como referencia [`proyecto_bdII/DESCRIPCION_PROYECTO.md`](proyecto_bdII/DESCRIPCION_PROYECTO.md), con la problemática, objetivos, alcance, entidades, reglas de negocio, **normalización (3FN)** y resumen de implementación SQL.

**Stack**: PostgreSQL 16 · Python 3.12 · Docker · Typer · Rich · psycopg2
