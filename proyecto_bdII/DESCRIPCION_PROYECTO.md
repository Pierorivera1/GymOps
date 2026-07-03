# GymOps — Descripción del Proyecto Final
### Base de Datos II — Universidad Nacional Federico Villarreal (UNFV)
**Autor:** Piero Rivera  
**Gestor de BD:** PostgreSQL (Docker)  
**Versión:** 1.0 — Fase inicial (sin módulo de Administración y Seguridad)

---

## 1. Presentación General del Proyecto

### 1.1 Descripción de la Problemática

El seguimiento del entrenamiento físico es una tarea que la mayoría de atletas aficionados y naturales realiza de manera informal: anotaciones en el celular, cuadernos o simplemente memoria. Este enfoque genera inconsistencias en el registro, pérdida de historial, imposibilidad de analizar tendencias de progreso y falta de motivación al no poder visualizar mejoras a lo largo del tiempo.

**GymOps** nace como respuesta a esta problemática. Es un sistema de seguimiento de entrenamientos basado en terminal (CLI) que permite al usuario registrar sus sesiones de entrenamiento, controlar su historial de cargas, detectar récords personales (PR) y generar resúmenes semanales — todo desde la línea de comandos, sin depender de aplicaciones en la nube.

Para el proyecto de Base de Datos II, GymOps utiliza una base de datos relacional robusta en **PostgreSQL**, incorporando todas las capacidades avanzadas de SQL requeridas por el curso.

---

### 1.2 Objetivos del Sistema

**Objetivo General:**  
Implementar una base de datos relacional en PostgreSQL que soporte el sistema GymOps, permitiendo el registro, consulta y análisis de entrenamientos físicos mediante el uso de todas las herramientas avanzadas de SQL.

**Objetivos Específicos:**
- Diseñar e implementar un modelo relacional normalizado (3FN) que represente las entidades del dominio del entrenamiento físico.
- Implementar procedimientos almacenados que automaticen el cálculo de 1RM estimado (fórmula Epley), detección de PRs y control de sobrecarga progresiva.
- Crear vistas para reportes de rendimiento por ejercicio, músculo y programa de entrenamiento.
- Implementar triggers para auditoría de cambios y validaciones automáticas de negocio.
- Crear funciones definidas por el usuario (escalares y tipo tabla) para cálculos reutilizables.
- Optimizar consultas frecuentes mediante índices estratégicos.

---

### 1.3 Alcance del Proyecto

**Incluido en esta versión:**
- Módulo de Gestión de Ejercicios (catálogo por músculo y tipo)
- Módulo de Programas de Entrenamiento (splits, días, rutinas predefinidas)
- Módulo de Sesiones de Entrenamiento (log de sets por sesión)
- Módulo de Análisis de Progreso (1RM estimado, sobrecarga progresiva, PRs)
- Módulo de Reportes (resúmenes semanales, estadísticas por ejercicio)
- Implementación SQL completa: DDL, DML, vistas, índices, SPs, funciones, triggers

**Fuera de alcance en esta versión:**
- Módulo de Administración y Seguridad (gestión de usuarios/roles, backups automatizados)
- Interfaz web o móvil (la aplicación es estrictamente CLI)
- Sincronización en la nube

---

### 1.4 Descripción de Procesos Principales

| # | Proceso | Descripción |
|---|---------|-------------|
| P1 | Gestión de Catálogo | El usuario puede agregar, modificar y consultar ejercicios del catálogo por grupo muscular, tipo (compuesto/aislamiento) y equipamiento. |
| P2 | Gestión de Programas | Creación y selección de programas de entrenamiento (splits) con sus días y ejercicios asignados. Pre-cargados: Upper/Lower, PPL, ULPPL (splits recomendados por su efectividad). |
| P3 | Registro de Sesión | Al iniciar entrenamiento se crea una sesión. El usuario registra series (sets), repeticiones y peso por ejercicio. |
| P4 | Cálculo de 1RM | Por cada set registrado, el sistema calcula automáticamente el 1RM estimado usando la **fórmula de Epley**: `1RM = peso × (1 + reps/30)`. |
| P5 | Control de PR | El sistema compara el 1RM estimado actual contra el histórico y actualiza el récord personal si corresponde. |
| P6 | Análisis de Sobrecarga | Al consultar estadísticas, el sistema compara el volumen/carga de la sesión actual vs la última sesión del mismo día. |
| P7 | Generación de Reportes | El sistema genera resúmenes semanales con volumen total, mejores lifts y progresión por ejercicio. |

---

### 1.5 Identificación de Entidades Principales

| Entidad | Descripción |
|---------|-------------|
| `muscle_group` | Grupos musculares (pecho, espalda, piernas, hombros, etc.) |
| `exercise` | Catálogo maestro de ejercicios (nombre, músculo, tipo, equipamiento) |
| `program` | Programa de entrenamiento (ej: "Upper/Lower 4-Day") |
| `program_day` | Día dentro de un programa (ej: "Upper A — Strength") |
| `routine_exercise` | Ejercicios asignados a un día de programa (con series y reps objetivo) |
| `workout_session` | Sesión de entrenamiento realizada (fecha, usuario, programa y día) |
| `workout_set` | Set individual registrado (ejercicio, reps, peso, 1RM calculado) |
| `personal_record` | Récord personal por ejercicio (máximo 1RM histórico) |
| `audit_log` | Registro de auditoría de cambios en sets y PRs |
| `guide_article` | Guías y artículos informativos de fitness (contenido en Markdown) |
| `active_program` | Tabla de control (fila única) que guarda el programa y día activos del usuario |

---

### 1.6 Reglas de Negocio Relevantes

1. **RN-01:** Un `workout_set` debe estar asociado obligatoriamente a una `workout_session` activa.
2. **RN-02:** El 1RM estimado se calcula automáticamente al insertar un `workout_set` (trigger AFTER INSERT).
3. **RN-03:** Un PR se actualiza solo si el nuevo 1RM supera el 1RM registrado en `personal_record` para ese ejercicio.
4. **RN-04:** No se pueden registrar sets con peso ≤ 0 o repeticiones ≤ 0 (CHECK constraint).
5. **RN-05:** Un `program_day` pertenece a un único `program`.
6. **RN-06:** La `workout_session` registra la fecha y hora de inicio; la de fin se actualiza al cerrar la sesión.
7. **RN-07:** El campo `is_pr` en `workout_set` se establece en `TRUE` automáticamente si el set rompe el PR actual.
8. **RN-08:** El volumen de un set = `peso × reps` (campo calculado por trigger).
9. **RN-09:** No se pueden registrar sets en una sesión ya cerrada (`ended_at IS NOT NULL`), garantizando la inmutabilidad del historial (trigger BEFORE INSERT).
10. **RN-10:** Toda operación INSERT/UPDATE/DELETE sobre `workout_set`, y todo cambio de `max_1rm` en `personal_record`, queda registrada en `audit_log` con los datos anteriores y nuevos en formato JSONB (RF-10, RNF-07).
11. **RN-11:** Un ejercicio no puede eliminarse si está referenciado por un set o una rutina (`ON DELETE RESTRICT`); un `personal_record` es único por ejercicio (relación 1:1).

---

### 1.7 Justificación Tecnológica

| Tecnología | Justificación |
|-----------|--------------|
| **PostgreSQL** | SGBD relacional open-source de clase enterprise. Soporta PL/pgSQL, triggers, CTE, funciones de ventana, índices parciales y todas las características requeridas por el curso. |
| **Docker** | Permite levantar PostgreSQL de forma reproducible y aislada, sin instalación directa. Facilita el despliegue consistente del entorno. |
| **Python + Typer + Rich** | Stack de la aplicación CLI. Se conecta a PostgreSQL vía `psycopg2`. Demuestra integración real entre app y BD. |
| **PostgreSQL Nativo** | El diseño del sistema en PostgreSQL aprovecha características enterprise avanzadas (procedimientos almacenados, triggers complejos, vistas y funciones) para asegurar la integridad, consistencia y el rendimiento de la base de datos. |

---

### 1.8 Normalización del Modelo Relacional

El esquema está normalizado hasta la **Tercera Forma Normal (3FN)**. A continuación se justifica el cumplimiento de cada forma normal y se documentan las dos desnormalizaciones deliberadas por diseño.

**Primera Forma Normal (1FN) — valores atómicos, sin grupos repetidos:**
Todas las tablas cumplen 1FN. No existen atributos multivaluados ni listas embebidas; cada columna almacena un único valor. La única excepción aparente es `routine_exercise.reps_target VARCHAR(20)`, que guarda rangos objetivo como `"6-8"` o `"8-12"`. Se trata como un **valor atómico de presentación** (una etiqueta de rango prescrito, no dos datos independientes sobre los que se opere aritméticamente en la BD), por lo que no rompe 1FN en la práctica.

**Segunda Forma Normal (2FN) — sin dependencias parciales de una clave compuesta:**
Se cumple de forma trivial porque **todas las tablas usan una clave primaria sustituta de una sola columna** (`id SERIAL`). Al no existir claves primarias compuestas, no puede haber dependencias parciales. Las claves candidatas naturales se protegen con restricciones `UNIQUE` (p. ej. `exercise.name`, `program_day(program_id, day_order)`, `routine_exercise(program_day_id, exercise_id)`, `personal_record.exercise_id`).

**Tercera Forma Normal (3FN) — sin dependencias transitivas:**
Cada atributo no clave depende únicamente de la clave primaria. No se duplican datos de entidades relacionadas: `exercise` guarda `muscle_group_id` (FK) en lugar del nombre del músculo; `workout_set` referencia `session_id` y `exercise_id` por FK sin copiar sus datos; `personal_record` apunta al `set_id` en vez de replicar peso, reps y fecha del set.

**Desnormalizaciones deliberadas (por rendimiento e integridad):**
La tabla `workout_set` almacena tres campos que son **derivables** de `weight_kg` y `reps`:

| Campo | Fórmula de derivación | Justificación de almacenarlo |
|-------|----------------------|------------------------------|
| `estimated_1rm` | Epley: `weight × (1 + reps/30)` | Evita recalcular en cada consulta de historial/PRs; consultado con altísima frecuencia. |
| `volume` | `weight × reps` | Se agrega (`SUM`) en casi todas las vistas de reporte; precalcularlo elimina cómputo repetido. |
| `is_pr` | Comparación contra `personal_record` | Permite filtrar sets-PR con un índice parcial (`WHERE is_pr = TRUE`) sin subconsultas. |

Estos campos **no violan 3FN en sentido estricto** (no son dependencias transitivas entre atributos no clave: cada uno depende de la clave del propio set, no de otro atributo no clave por una cadena). Constituyen una **redundancia controlada**: los triggers `trg_calculate_1rm` y `trg_update_pr` los rellenan y mantienen consistentes automáticamente, de modo que la aplicación nunca los calcula ni puede desincronizarlos. Es el patrón recomendado de desnormalización — redundancia gestionada por el motor, no por el código cliente.

> **Nota sobre gestores:** en PostgreSQL todas las tablas son *heaps* y todos los índices son secundarios; no existe el concepto de índice *clustered/nonclustered* de SQL Server como propiedad mantenida. La optimización se logra con índices B-tree, parciales y en expresión (ver Fase 4), no con ordenamiento físico de la tabla.

---

## 2. Módulos del Sistema

### 2.1 Módulo de Ejercicios
CRUD sobre el catálogo maestro de ejercicios. Clasificación por grupo muscular, tipo de movimiento (compuesto/aislamiento) y equipamiento requerido.

### 2.2 Módulo de Programas
Gestión de programas de entrenamiento y rutinas diarias. Incluye programas pre-cargados (splits conocidos y recomendados por su efectividad) y permite creación de programas personalizados.

### 2.3 Módulo de Sesiones
Núcleo del sistema. Registro de entrenamientos en tiempo real: creación de sesión, log de sets y cierre de sesión.

### 2.4 Módulo de Análisis y PRs
Motor analítico. Calcula 1RM estimado (Epley), detecta PRs, y analiza sobrecarga progresiva comparando sesiones. Interactúa con triggers y funciones de la BD.

### 2.5 Módulo de Reportes
Generación de resúmenes en formato Markdown/texto. Consulta vistas pre-definidas en la BD para informes de entrenamiento semanal.

### 2.6 Módulo de Guías
Consulta de artículos informativos de fitness (`gymops guide list` / `gymops guide read`) almacenados en la tabla `guide_article` con contenido en Markdown, renderizado directamente en la terminal.

---

## 3. Entorno Tecnológico

```
Sistema Operativo:    Linux (Ubuntu)
Gestor de BD:         PostgreSQL 16 (Docker)
Lenguaje App:         Python 3.12
Conector BD:          psycopg2 (SQL directo, sin ORM)
Gestor de paquetes:   uv
CLI Framework:        Typer
UI de terminal:       Rich (salida formateada y colores)
Control de versiones: Git + GitHub
```

---

## 4. Diagrama de Entidades

Notación: `1 ──< N` indica una relación uno-a-muchos (el lado `<` es el "muchos", donde vive la FK). Las flechas apuntan de la tabla hija (FK) a la tabla padre (PK).

```
                    program
                       ▲ 1
                       │
                       │ N
                  program_day ◄──────────────┐
                    ▲ 1     ▲ 1              │ N
                    │       │ N              │
                    │ N   workout_session    │
          routine_exercise    ▲ 1            │
                    │ N       │ N            │
                    │      workout_set       │
                    ▼ 1       │ N            │
   muscle_group ──< exercise ─┤             (workout_session.program_day_id)
        1        N   ▲ 1      │ N
                     │        ▼ 1
                     │   personal_record  (1:1 por ejercicio, vía UNIQUE)
                     │        │
                     └────────┘  (personal_record.exercise_id → exercise.id;
                                  personal_record.set_id → workout_set.id)

   audit_log         → tabla independiente, sin FKs (preserva el historial aunque
                       se borren registros de origen). Poblada por triggers.
   active_program     → tabla de control de fila única (program_id, day_id).
   guide_article      → tabla independiente de contenido informativo.
```

**Relaciones (claves foráneas):**

| Tabla hija (FK) | Columna | Tabla padre | Regla ON DELETE |
|-----------------|---------|-------------|-----------------|
| `exercise` | `muscle_group_id` | `muscle_group` | RESTRICT |
| `program_day` | `program_id` | `program` | CASCADE |
| `routine_exercise` | `program_day_id` | `program_day` | CASCADE |
| `routine_exercise` | `exercise_id` | `exercise` | RESTRICT |
| `workout_session` | `program_day_id` | `program_day` | SET NULL |
| `workout_set` | `session_id` | `workout_session` | CASCADE |
| `workout_set` | `exercise_id` | `exercise` | RESTRICT |
| `personal_record` | `exercise_id` | `exercise` | CASCADE (UNIQUE → 1:1) |
| `personal_record` | `set_id` | `workout_set` | SET NULL |

`audit_log`, `guide_article` y `active_program` no participan en la malla de FKs de dominio: `audit_log` es deliberadamente independiente para conservar la trazabilidad, y `active_program` es estado de sesión de la aplicación.

---

## 5. Resumen de Implementación SQL

El proyecto implementa todos los requerimientos de manipulación y programación SQL avanzada del curso:

| Componente | Cantidad | Archivo | Ejemplos |
|-----------|:--------:|---------|----------|
| Tablas | 11 | `01_ddl.sql` (+ `active_program`) | `workout_set`, `personal_record`, `audit_log` |
| Datos seed | 10 músculos, 51 ejercicios, 3 programas (15 días), 6 guías | `02_seed.sql` | Splits recomendados por su efectividad |
| Consultas avanzadas | 10 | `04_queries.sql` | CTE, `LAG()`, `RANK()`, self-join, running total |
| Vistas | 9 | `05_views.sql` | `v_current_prs`, `v_exercise_progress`, `v_session_summary` |
| Índices | 15 | `06_indexes.sql` | B-tree, compuestos, parciales (`WHERE is_pr`), en expresión (`LOWER(name)`) |
| Procedimientos almacenados | 5 | `07_procedures.sql` | `sp_log_set`, `sp_start_session`, `sp_weekly_digest` |
| Funciones UDF | 6 | `08_functions.sql` | Escalares (`fn_epley_1rm`) y tipo tabla (`fn_exercise_history`) |
| Triggers | 6 | `09_triggers.sql` | Validación, cálculo de 1RM, detección de PR, auditoría |

Todos estos objetos están conectados a comandos del CLI de GymOps; el mapeo detallado por fase (con el código SQL de cada uno) se documenta en el manual de usuario entregado al curso.

---

*Documento sujeto a actualizaciones conforme avance el desarrollo del proyecto.*
