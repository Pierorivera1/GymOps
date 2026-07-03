# Manual de Usuario — GymOps 🏋️

Bienvenido a **GymOps**, tu gestor de entrenamientos personal en la terminal. Este proyecto final para el curso de **Base de Datos II (FIEI/UNI)** combina una aplicación CLI rápida y elegante desarrollada en Python con una potente base de datos relacional en **PostgreSQL 16**.

GymOps está diseñado especialmente para **personas sin experiencia previa en el gimnasio**. Olvídate de planificar complejas rutinas o cargar pesadas aplicaciones llenas de publicidad: GymOps viene precargado con rutinas científicas conocidas y recomendadas por su efectividad para que solo tengas que llegar al gimnasio, seleccionar tu rutina y empezar a registrar. Asimismo, si eres un atleta intermedio o avanzado, el sistema te permite diseñar tus propios programas de entrenamiento personalizados.

---

## 1. Requisitos Previos e Instalación

Para ejecutar GymOps localmente, necesitas tener instalado:
* **Python 3.12+**
* **Docker** y Docker Compose
* **uv** (el gestor rápido de entornos y paquetes de Python)

### Paso 1: Levantar PostgreSQL en Docker
Ejecuta el siguiente comando para levantar el servidor de base de datos PostgreSQL 16 de manera aislada y reproducible:

```bash
docker run --name gymops-db \
  -e POSTGRES_USER=gymops \
  -e POSTGRES_PASSWORD=gymops_pass \
  -e POSTGRES_DB=gymops_db \
  -p 5432:5432 \
  -d postgres:16
```

### Paso 2: Clonar e instalar la aplicación CLI
Clona el repositorio e instala el proyecto en modo editable usando `uv`:

```bash
# Clonar
git clone https://github.com/Pierorivera1/GymOps-FIEI.git
cd GymOps-FIEI

# Crear entorno virtual e instalar dependencias
uv venv
source .venv/bin/activate
uv pip install -e .
```

### Paso 3: Inicializar la Base de Datos
Ejecuta los scripts SQL principales en orden utilizando el cliente `psql`. Esto creará el esquema y poblará la base de datos con los datos iniciales (splits conocidos y recomendados por su efectividad, y el catálogo de ejercicios):

```bash
psql -h localhost -U gymops -d gymops_db -f proyecto_bdII/sql/01_ddl.sql
psql -h localhost -U gymops -d gymops_db -f proyecto_bdII/sql/02_seed.sql
```
*(Nota: Al invocar cualquier comando de GymOps por primera vez, el sistema ejecutará automáticamente las vistas, índices, procedimientos, funciones y triggers restantes de forma transparente).*

---

## 2. Flujo de Uso Paso a Paso (Para Principiantes)

Si eres nuevo en el gimnasio, sigue esta guía simple para empezar tu entrenamiento:

### Paso 2.1: Establece el idioma en español
GymOps es bilingüe. Configúralo en español para ver todas las guías y tablas traducidas:
```bash
gymops set-language es
```

### Paso 2.2: Explora las rutinas predefinidas
Visualiza los programas de entrenamiento disponibles para ver cuál se adapta mejor a tu disponibilidad semanal:
```bash
gymops list-programs
```
Verás rutinas listas y recomendadas por su efectividad, tales como:
* `Upper/Lower 4-Day` (Torso/Pierna - 4 días a la semana)
* `ULPPL 5-Day` (Torso/Pierna/Empuje/Tirón/Pierna - 5 días a la semana)
* `PPL 6-Day` (Empuje/Tirón/Pierna - 6 días a la semana)

### Paso 2.3: Elige tu programa activo
Selecciona la rutina que planeas seguir (por ejemplo, el split de Torso/Pierna de 4 días):
```bash
gymops select-program "Upper/Lower 4-Day"
```

### Paso 2.4: Al llegar al gimnasio: Elige el día de hoy
Al iniciar tu sesión de entrenamiento, dile a la aplicación qué día vas a entrenar hoy. Esto activará los ejercicios sugeridos y las repeticiones objetivo para el día:
```bash
gymops set-day "Upper A — Strength"
```

### Paso 2.5: Registra tus series de entrenamiento (sets)
Durante o después de cada ejercicio, registra el número de series, repeticiones y peso levantado. Por ejemplo, si hiciste 4 series de Press de Banca con barra con 80 kg:
```bash
gymops log --exercise "Barbell Bench Press" --sets 4 --reps 5 --weight 80
```
**¿Qué ocurre en la base de datos bajo el capó?**
1. Se inicia una sesión de entrenamiento activa en la tabla `workout_session` si no existía.
2. Un trigger `BEFORE INSERT` valida que el peso y repeticiones sean mayores a 0.
3. Un trigger `AFTER INSERT` calcula tu **1RM estimado** (Repetición Máxima Estimada) usando la **Fórmula de Epley** (`1RM = peso * (1 + reps/30)`) y calcula el volumen de entrenamiento de cada serie.
4. El motor SQL detecta automáticamente si has roto tu récord personal (PR) histórico en ese ejercicio y actualiza la tabla `personal_record` en tiempo real.
5. Se escribe automáticamente un registro en la tabla de auditoría `audit_log`.

---

## 3. Comandos de Consulta y Análisis de Progreso

### 3.1. Récords Personales (PRs)
Visualiza tus mejores marcas históricas ordenadas por ejercicio:
```bash
gymops prs
```
Muestra una tabla ordenada con el peso máximo levantado, el 1RM estimado y la fecha exacta en la que lograste tu marca.

### 3.2. Historial de un Ejercicio
Consulta todo tu historial registrado para un ejercicio en específico para saber qué peso cargaste en semanas anteriores:
```bash
gymops history --exercise "Barbell Bench Press"
```

### 3.3. Estadísticas de Sobrecarga Progresiva
Compara tu sesión de hoy directamente contra la sesión anterior para evaluar si has logrado progresar (hacerte más fuerte, sacar más repeticiones o cargar más peso):
```bash
gymops stats --exercise "Barbell Bench Press"
```
**Posibles resultados:**
* 🟢 **Progreso:** Muestra el incremento en tu fuerza estimada con un porcentaje (ej. `+5.00% ▲`).
* 🟡 **Meseta:** Te indica que tu 1RM estimado se mantuvo igual y te sugiere añadir 1-2.5 kg o subir repeticiones.
* 🔴 **Descanso necesario:** Si tu fuerza disminuyó, te recuerda que la fatiga acumulada es normal y te recomienda cuidar el sueño, descanso y nutrición.

### 3.4. Resumen Semanal de Progreso (Digest)
Genera un reporte completo de tu última semana de entrenamientos en formato Markdown:
```bash
gymops digest
```
Esto crea un archivo `digest_YYYY-MM-DD.md` que incluye un desglose de series totales completadas, ejercicios entrenados, volumen por grupo muscular, un resumen de las últimas semanas y PRs rotos durante el período. Utiliza las vistas `v_workout_history` y `v_weekly_digest` junto con el procedimiento almacenado `sp_weekly_digest` para procesar la información en la base de datos de manera óptima.

---

## 4. Gestión Avanzada: Crear Rutinas y Ejercicios Propios

Si prefieres personalizar tu entrenamiento, GymOps te proporciona herramientas flexibles:

### 4.1. Agregar Ejercicios al Catálogo
Si deseas registrar un ejercicio que no viene en el catálogo base:
```bash
gymops add-exercise --name "Dumbbell Incline Bench Press" --muscle-group "Chest" --type compound
```

### 4.2. Asistente Interactivo de Programas
Crea un programa de entrenamiento a tu medida ejecutando:
```bash
gymops add-program
```
El asistente interactivo te guiará paso a paso en la terminal para:
1. Definir el nombre del programa.
2. Crear cada día de entrenamiento (ej: "Día de Empuje", "Día de Jalón").
3. Asignar ejercicios del catálogo a cada día.
4. Establecer las series y repeticiones objetivo para cada ejercicio.

---

## 5. Detalles Técnicos de la Base de Datos (PostgreSQL 16)

GymOps está sustentado por una base de datos PostgreSQL normalizada en **Tercera Forma Normal (3FN)**. A continuación se presentan las entidades principales:

* `muscle_group`: Grupos musculares principales (Pecho, Espalda, Piernas, etc.).
* `exercise`: Catálogo maestro de ejercicios con su tipo de movimiento (compuesto o aislamiento).
* `program` y `program_day`: Estructuras de las rutinas de entrenamiento.
* `routine_exercise`: Tabla de rompimiento que asocia ejercicios con días específicos indicando las series/repeticiones objetivo.
* `workout_session` y `workout_set`: Registro del entrenamiento en vivo del usuario.
* `personal_record`: Tabla que mantiene la mejor marca de 1RM lograda en la historia por el usuario para cada ejercicio.
* `audit_log`: Registro inmutable de auditoría para auditorías de cambios y validaciones (RF-10, RNF-07).

---

## 6. Guía por Fase del Proyecto

Esta sección sirve como **referencia rápida** para quien quiera demostrar, fase por fase (según `PLANNING.md` §4), el tema SQL correspondiente. Todas las vistas, procedimientos almacenados y funciones tipo tabla del proyecto están conectados a un comando de la CLI. Solo los scripts de demostración standalone (consultas avanzadas de la Fase 2) y las verificaciones de índices (Fase 4) se ejecutan con `psql`, porque por su naturaleza no corresponden a una acción de usuario de la app. Debajo de cada comando se incluye el código SQL completo que ese comando utiliza.

### Fase 1 — DDL y Datos (`sql/01_ddl.sql`, `sql/02_seed.sql`)
**Objetivo:** Mostrar la estructura de tablas y los datos precargados (splits y catálogo de ejercicios).
```bash
psql -h localhost -U gymops -d gymops_db -f proyecto_bdII/sql/01_ddl.sql
psql -h localhost -U gymops -d gymops_db -f proyecto_bdII/sql/02_seed.sql
gymops list-programs
```

**Código SQL — tablas creadas por `01_ddl.sql`:**
```sql
CREATE TABLE muscle_group (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(50)  NOT NULL UNIQUE,
    description TEXT
);
CREATE TABLE exercise (
    id               SERIAL PRIMARY KEY,
    name             VARCHAR(100) NOT NULL UNIQUE,
    muscle_group_id  INT          NOT NULL REFERENCES muscle_group(id) ON DELETE RESTRICT,
    type             VARCHAR(20)  NOT NULL CHECK (type IN ('compound', 'isolation')),
    equipment        VARCHAR(50)  NOT NULL DEFAULT 'barbell',
    description      TEXT,
    created_at       TIMESTAMP    NOT NULL DEFAULT NOW()
);
CREATE TABLE program (
    id             SERIAL PRIMARY KEY,
    name           VARCHAR(100) NOT NULL UNIQUE,
    description    TEXT,
    days_per_week  SMALLINT     NOT NULL CHECK (days_per_week BETWEEN 1 AND 7),
    author         VARCHAR(100),
    created_at     TIMESTAMP    NOT NULL DEFAULT NOW()
);
CREATE TABLE program_day (
    id          SERIAL PRIMARY KEY,
    program_id  INT          NOT NULL REFERENCES program(id) ON DELETE CASCADE,
    name        VARCHAR(100) NOT NULL,
    day_order   SMALLINT     NOT NULL CHECK (day_order >= 1),
    focus       VARCHAR(100),
    UNIQUE (program_id, day_order)
);
CREATE TABLE routine_exercise (
    id              SERIAL PRIMARY KEY,
    program_day_id  INT          NOT NULL REFERENCES program_day(id) ON DELETE CASCADE,
    exercise_id     INT          NOT NULL REFERENCES exercise(id)     ON DELETE RESTRICT,
    sets_target     SMALLINT     NOT NULL CHECK (sets_target > 0),
    reps_target     VARCHAR(20)  NOT NULL,   -- permite rangos: "6-8", "8-12", "12-15"
    rest_seconds    SMALLINT,
    notes           TEXT,
    order_in_day    SMALLINT     NOT NULL DEFAULT 1,
    UNIQUE (program_day_id, exercise_id)
);
CREATE TABLE workout_session (
    id              SERIAL PRIMARY KEY,
    program_day_id  INT          REFERENCES program_day(id) ON DELETE SET NULL,
    started_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
    ended_at        TIMESTAMP,
    notes           TEXT,
    CONSTRAINT chk_session_dates CHECK (ended_at IS NULL OR ended_at > started_at)
);
CREATE TABLE workout_set (
    id              SERIAL PRIMARY KEY,
    session_id      INT            NOT NULL REFERENCES workout_session(id) ON DELETE CASCADE,
    exercise_id     INT            NOT NULL REFERENCES exercise(id)         ON DELETE RESTRICT,
    set_number      SMALLINT       NOT NULL CHECK (set_number > 0),
    reps            SMALLINT       NOT NULL CHECK (reps > 0),
    weight_kg       NUMERIC(6,2)   NOT NULL CHECK (weight_kg > 0),
    estimated_1rm   NUMERIC(6,2),             -- calculado por trigger
    volume          NUMERIC(8,2),             -- weight_kg * reps, calculado por trigger
    is_pr           BOOLEAN        NOT NULL DEFAULT FALSE,
    logged_at       TIMESTAMP      NOT NULL DEFAULT NOW()
);
CREATE TABLE personal_record (
    id           SERIAL PRIMARY KEY,
    exercise_id  INT           NOT NULL UNIQUE REFERENCES exercise(id) ON DELETE CASCADE,
    max_1rm      NUMERIC(6,2)  NOT NULL CHECK (max_1rm > 0),
    achieved_at  TIMESTAMP     NOT NULL DEFAULT NOW(),
    set_id       INT           REFERENCES workout_set(id) ON DELETE SET NULL
);
CREATE TABLE audit_log (
    id          SERIAL PRIMARY KEY,
    table_name  VARCHAR(50)  NOT NULL,
    operation   VARCHAR(10)  NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    old_data    JSONB,
    new_data    JSONB,
    changed_at  TIMESTAMP    NOT NULL DEFAULT NOW()
);
CREATE TABLE guide_article (
    id          SERIAL PRIMARY KEY,
    title       VARCHAR(150) UNIQUE NOT NULL,
    slug        VARCHAR(100) UNIQUE NOT NULL,
    category    VARCHAR(50) NOT NULL,
    content_md  TEXT NOT NULL,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);
```

**Código SQL — `gymops list-programs`** (verifica que el seed cargó los programas):
```sql
SELECT id, name, CASE WHEN author = 'system' THEN 'system' ELSE 'user' END AS created_by
FROM program
ORDER BY name;

SELECT id, program_id, name, day_order
FROM program_day
WHERE program_id = %s
ORDER BY day_order;
```
*(El seed de `02_seed.sql` inserta 10 grupos musculares, 51 ejercicios y los 3 programas con sus días y ejercicios — ver el archivo para el detalle de los INSERTs.)*

### Fase 2 — DML y Consultas Avanzadas (`sql/03_dml.sql`, `sql/04_queries.sql`)
**Objetivo:** Demostrar INSERT/UPDATE simples desde la app y las consultas avanzadas (CTE, window functions, RANK) del script dedicado.

DML simple vía CLI:
```bash
gymops add-exercise --name "Dumbbell Incline Bench Press" --muscle-group "Chest" --type compound
gymops add-program
gymops select-program "Upper/Lower 4-Day"
gymops set-day "Upper A — Strength"
```

**Código SQL — `gymops add-exercise`:**
```sql
SELECT id FROM muscle_group WHERE LOWER(name) = LOWER(%s);

-- Si el grupo muscular no existe, se crea:
INSERT INTO muscle_group (name) VALUES (%s) RETURNING id;

INSERT INTO exercise (name, muscle_group_id, type) VALUES (%s, %s, %s);
```

**Código SQL — `gymops add-program`** (asistente interactivo):
```sql
SELECT id FROM program WHERE LOWER(name) = LOWER(%s);   -- valida duplicado

INSERT INTO program (name, author, days_per_week)
VALUES (%s, 'user', %s) RETURNING id, name, author;

INSERT INTO program_day (program_id, name, day_order)
VALUES (%s, %s, %s) RETURNING id;                        -- por cada día

INSERT INTO routine_exercise
    (program_day_id, exercise_id, sets_target, reps_target, order_in_day)
VALUES (%s, %s, %s, %s, %s);                             -- por cada ejercicio
```

**Código SQL — `gymops select-program` / `gymops set-day`** (upsert con ON CONFLICT):
```sql
INSERT INTO active_program (id, program_id, day_id)
VALUES (1, %s, NULL)
ON CONFLICT(id) DO UPDATE SET
    program_id = EXCLUDED.program_id,
    day_id = NULL;

INSERT INTO active_program (id, program_id, day_id)
VALUES (1, %s, %s)
ON CONFLICT(id) DO UPDATE SET day_id = EXCLUDED.day_id;
```

Consultas avanzadas (no las ejecuta la CLI; se corren directo con `psql`):
```bash
psql -h localhost -U gymops -d gymops_db -f proyecto_bdII/sql/04_queries.sql
```

**Código SQL — consultas avanzadas de `04_queries.sql`:**
```sql
-- =============================================================================
-- Q1: Top ejercicios por volumen total en las últimas 4 semanas
--     Técnicas: JOIN, GROUP BY, SUM, HAVING, ORDER BY
-- =============================================================================
SELECT
    ex.name                             AS ejercicio,
    mg.name                             AS musculo,
    COUNT(DISTINCT ws.session_id)       AS sesiones,
    COUNT(ws.id)                        AS total_series,
    SUM(ws.reps)                        AS total_reps,
    ROUND(SUM(ws.volume)::numeric, 1)   AS volumen_total_kg
FROM workout_set ws
JOIN exercise       ex   ON ws.exercise_id     = ex.id
JOIN muscle_group   mg   ON ex.muscle_group_id = mg.id
JOIN workout_session sess ON ws.session_id     = sess.id
WHERE sess.started_at >= NOW() - INTERVAL '28 days'
GROUP BY ex.name, mg.name
HAVING COUNT(ws.id) >= 3                -- solo ejercicios con al menos 3 series registradas
ORDER BY volumen_total_kg DESC
LIMIT 10;

-- =============================================================================
-- Q2: Progresión de 1RM por ejercicio a lo largo del tiempo
--     Técnicas: CTE, LAG() window function, diferencia porcentual
-- =============================================================================
WITH historial_1rm AS (
    SELECT
        ex.name                             AS ejercicio,
        sess.started_at::date               AS fecha,
        MAX(ws.estimated_1rm)               AS max_1rm_sesion
    FROM workout_set ws
    JOIN exercise        ex   ON ws.exercise_id  = ex.id
    JOIN workout_session sess ON ws.session_id   = sess.id
    GROUP BY ex.name, sess.started_at::date
),
con_progresion AS (
    SELECT
        ejercicio,
        fecha,
        max_1rm_sesion,
        LAG(max_1rm_sesion) OVER (
            PARTITION BY ejercicio
            ORDER BY fecha
        )                                   AS _1rm_sesion_anterior,
        ROUND(
            (max_1rm_sesion - LAG(max_1rm_sesion) OVER (
                PARTITION BY ejercicio ORDER BY fecha
            )) /
            NULLIF(LAG(max_1rm_sesion) OVER (
                PARTITION BY ejercicio ORDER BY fecha
            ), 0) * 100
        , 2)                                AS cambio_pct
    FROM historial_1rm
)
SELECT
    ejercicio,
    fecha,
    max_1rm_sesion                          AS "1RM_sesion_kg",
    _1rm_sesion_anterior                    AS "1RM_anterior_kg",
    COALESCE(cambio_pct, 0)                 AS "cambio_%",
    CASE
        WHEN cambio_pct > 0  THEN '▲ Mejora'
        WHEN cambio_pct < 0  THEN '▼ Baja'
        WHEN cambio_pct = 0  THEN '─ Meseta'
        ELSE                      '· Primera sesión'
    END                                     AS tendencia
FROM con_progresion
WHERE ejercicio = 'Barbell Bench Press'
ORDER BY fecha;

-- =============================================================================
-- Q3: Comparar sesión actual vs sesión anterior por ejercicio
--     Técnicas: Self JOIN, CASE, Subconsulta correlacionada
-- =============================================================================
WITH sesiones_por_ejercicio AS (
    SELECT
        ex.name                             AS ejercicio,
        sess.started_at::date               AS fecha,
        ROUND(AVG(ws.weight_kg)::numeric, 2)    AS peso_promedio,
        SUM(ws.reps)                        AS reps_totales,
        ROUND(SUM(ws.volume)::numeric, 1)   AS volumen_total,
        MAX(ws.estimated_1rm)               AS mejor_1rm,
        ROW_NUMBER() OVER (
            PARTITION BY ex.name
            ORDER BY sess.started_at DESC
        )                                   AS n_sesion
    FROM workout_set ws
    JOIN exercise        ex   ON ws.exercise_id = ex.id
    JOIN workout_session sess ON ws.session_id  = sess.id
    GROUP BY ex.name, sess.started_at::date
)
SELECT
    actual.ejercicio,
    actual.fecha                            AS fecha_actual,
    anterior.fecha                          AS fecha_anterior,
    actual.mejor_1rm                        AS "1RM_actual",
    anterior.mejor_1rm                      AS "1RM_anterior",
    ROUND((actual.mejor_1rm - anterior.mejor_1rm)::numeric, 2)  AS dif_1rm,
    actual.volumen_total                    AS volumen_actual,
    anterior.volumen_total                  AS volumen_anterior,
    CASE
        WHEN actual.mejor_1rm > anterior.mejor_1rm THEN '💪 Sobrecarga progresiva'
        WHEN actual.mejor_1rm = anterior.mejor_1rm THEN '📊 Meseta'
        ELSE                                             '📉 Disminución'
    END                                     AS resultado
FROM sesiones_por_ejercicio actual
JOIN sesiones_por_ejercicio anterior
    ON actual.ejercicio = anterior.ejercicio
    AND actual.n_sesion = 1
    AND anterior.n_sesion = 2;

-- =============================================================================
-- Q4: Ejercicios sin entrenamiento en los últimos 14 días
--     Técnicas: LEFT JOIN, IS NULL, subconsulta, filtro temporal
-- =============================================================================
SELECT
    ex.name         AS ejercicio,
    mg.name         AS musculo,
    ex.type         AS tipo,
    MAX(ws.logged_at)::date AS ultima_sesion
FROM exercise ex
JOIN muscle_group mg ON ex.muscle_group_id = mg.id
LEFT JOIN workout_set ws ON ws.exercise_id = ex.id
GROUP BY ex.name, mg.name, ex.type
HAVING MAX(ws.logged_at) < NOW() - INTERVAL '14 days'
    OR MAX(ws.logged_at) IS NULL
ORDER BY ultima_sesion NULLS FIRST, mg.name;

-- =============================================================================
-- Q5: Ranking de PRs por grupo muscular
--     Técnicas: CTE, RANK(), JOIN múltiple
-- =============================================================================
WITH ranking_prs AS (
    SELECT
        mg.name                             AS musculo,
        ex.name                             AS ejercicio,
        pr.max_1rm,
        pr.achieved_at::date                AS fecha_pr,
        RANK() OVER (
            PARTITION BY mg.name
            ORDER BY pr.max_1rm DESC
        )                                   AS ranking
    FROM personal_record pr
    JOIN exercise       ex   ON pr.exercise_id     = ex.id
    JOIN muscle_group   mg   ON ex.muscle_group_id = mg.id
)
SELECT
    musculo,
    ranking,
    ejercicio,
    max_1rm                                 AS "1RM_max_kg",
    fecha_pr
FROM ranking_prs
WHERE ranking <= 3
ORDER BY musculo, ranking;

-- =============================================================================
-- Q6: Distribución de volumen de entrenamiento por día de la semana
--     Técnicas: EXTRACT, TO_CHAR, GROUP BY, CASE, ORDER BY personalizado
-- =============================================================================
SELECT
    CASE EXTRACT(DOW FROM sess.started_at)
        WHEN 0 THEN 'Domingo'
        WHEN 1 THEN 'Lunes'
        WHEN 2 THEN 'Martes'
        WHEN 3 THEN 'Miércoles'
        WHEN 4 THEN 'Jueves'
        WHEN 5 THEN 'Viernes'
        WHEN 6 THEN 'Sábado'
    END                                     AS dia_semana,
    COUNT(DISTINCT sess.id)                 AS sesiones,
    COUNT(ws.id)                            AS total_series,
    ROUND(SUM(ws.volume)::numeric, 1)       AS volumen_total_kg,
    ROUND(AVG(ws.volume)::numeric, 1)       AS volumen_promedio_serie
FROM workout_session sess
JOIN workout_set ws ON ws.session_id = sess.id
GROUP BY EXTRACT(DOW FROM sess.started_at)
ORDER BY EXTRACT(DOW FROM sess.started_at);

-- =============================================================================
-- Q7: Volumen semanal por grupo muscular (últimas 6 semanas)
--     Técnicas: DATE_TRUNC, GROUP BY múltiple, SUM, ORDER BY
-- =============================================================================
SELECT
    DATE_TRUNC('week', sess.started_at)::date   AS semana,
    mg.name                                      AS musculo,
    COUNT(ws.id)                                 AS series,
    SUM(ws.reps)                                 AS total_reps,
    ROUND(SUM(ws.volume)::numeric, 1)            AS volumen_kg
FROM workout_set ws
JOIN exercise       ex   ON ws.exercise_id     = ex.id
JOIN muscle_group   mg   ON ex.muscle_group_id = mg.id
JOIN workout_session sess ON ws.session_id     = sess.id
WHERE sess.started_at >= NOW() - INTERVAL '42 days'
GROUP BY DATE_TRUNC('week', sess.started_at), mg.name
ORDER BY semana DESC, volumen_kg DESC;

-- =============================================================================
-- Q8: Resumen completo de sesión (total, mejor 1RM, duración)
--     Técnicas: JOIN, EXTRACT, AGG functions, subconsulta escalar
-- =============================================================================
SELECT
    sess.id                                         AS sesion_id,
    pd.name                                         AS dia_programa,
    sess.started_at::date                           AS fecha,
    EXTRACT(EPOCH FROM (sess.ended_at - sess.started_at)) / 60
                                                    AS duracion_minutos,
    COUNT(ws.id)                                    AS total_series,
    SUM(ws.reps)                                    AS total_reps,
    ROUND(SUM(ws.volume)::numeric, 1)               AS volumen_total_kg,
    ROUND(MAX(ws.estimated_1rm)::numeric, 2)        AS mejor_1rm_sesion,
    COUNT(CASE WHEN ws.is_pr THEN 1 END)            AS prs_logrados
FROM workout_session sess
LEFT JOIN program_day pd  ON sess.program_day_id = pd.id
LEFT JOIN workout_set ws  ON ws.session_id       = sess.id
GROUP BY sess.id, pd.name, sess.started_at, sess.ended_at
ORDER BY sess.started_at DESC;

-- =============================================================================
-- Q9: Ejercicios por encima del promedio de 1RM de su grupo muscular
--     Técnicas: Subconsulta correlacionada, AVG, comparación
-- =============================================================================
SELECT
    ex.name                                 AS ejercicio,
    mg.name                                 AS musculo,
    pr.max_1rm                              AS "1RM_personal",
    ROUND(avg_grupo.promedio_1rm::numeric, 2)   AS "1RM_promedio_grupo",
    ROUND((pr.max_1rm - avg_grupo.promedio_1rm)::numeric, 2) AS diferencia
FROM personal_record pr
JOIN exercise     ex  ON pr.exercise_id     = ex.id
JOIN muscle_group mg  ON ex.muscle_group_id = mg.id
JOIN (
    SELECT
        ex2.muscle_group_id,
        AVG(pr2.max_1rm)    AS promedio_1rm
    FROM personal_record pr2
    JOIN exercise ex2 ON pr2.exercise_id = ex2.id
    GROUP BY ex2.muscle_group_id
) avg_grupo ON ex.muscle_group_id = avg_grupo.muscle_group_id
WHERE pr.max_1rm > avg_grupo.promedio_1rm
ORDER BY mg.name, diferencia DESC;

-- =============================================================================
-- Q10: Acumulado de volumen con ventana deslizante (running total)
--      Técnicas: SUM OVER (window function acumulativa), CTE
-- =============================================================================
WITH volumen_diario AS (
    SELECT
        sess.started_at::date               AS fecha,
        ROUND(SUM(ws.volume)::numeric, 1)   AS volumen_dia
    FROM workout_set ws
    JOIN workout_session sess ON ws.session_id = sess.id
    GROUP BY sess.started_at::date
)
SELECT
    fecha,
    volumen_dia,
    ROUND(SUM(volumen_dia) OVER (
        ORDER BY fecha
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )::numeric, 1)                          AS volumen_acumulado,
    ROUND(AVG(volumen_dia) OVER (
        ORDER BY fecha
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    )::numeric, 1)                          AS media_movil_3_dias
FROM volumen_diario
ORDER BY fecha;
```

### Fase 3 — Vistas (`sql/05_views.sql`)
**Objetivo:** Mostrar el uso de vistas SQL en la app y las que solo existen en el script.

Cada vista tiene su comando en la CLI:
```bash
gymops prs                                      # v_current_prs
gymops digest                                    # v_workout_history, v_weekly_digest y v_current_prs
gymops sessions                                  # v_session_summary
gymops progress --exercise "Barbell Bench Press" # v_exercise_progress
gymops muscle-volume                             # v_muscle_volume_week
gymops list-exercises                            # v_exercise_catalog
gymops show-program "Upper/Lower 4-Day"          # v_program_overview
gymops pr-timeline                               # v_pr_timeline
```

**Código SQL — `v_current_prs`** (usada por `gymops prs` y `gymops digest`):
```sql
CREATE VIEW v_current_prs AS
SELECT
    pr.id                                                        AS pr_id,
    ex.id                                                        AS exercise_id,
    ex.name                                                      AS ejercicio,
    mg.name                                                      AS musculo,
    ex.type                                                      AS tipo,
    ROUND(pr.max_1rm::numeric, 2)                               AS "1rm_max_kg",
    ws.weight_kg                                                 AS peso_en_pr_kg,
    ws.reps                                                      AS reps_en_pr,
    pr.achieved_at::date                                         AS fecha_pr,
    sess.started_at::date                                        AS fecha_sesion
FROM personal_record pr
JOIN exercise       ex   ON pr.exercise_id  = ex.id
JOIN muscle_group   mg   ON ex.muscle_group_id = mg.id
LEFT JOIN workout_set  ws   ON pr.set_id    = ws.id
LEFT JOIN workout_session sess ON ws.session_id = sess.id
ORDER BY mg.name, pr.max_1rm DESC;
```

**Código SQL — `v_workout_history`** (usada por `gymops digest`):
```sql
CREATE VIEW v_workout_history AS
SELECT
    ws.id                                                        AS set_id,
    sess.id                                                      AS session_id,
    ws.logged_at::date                                           AS fecha,
    ws.logged_at::time                                           AS hora,
    pd.name                                                      AS dia_programa,
    mg.name                                                      AS musculo,
    ex.name                                                      AS ejercicio,
    ex.type                                                      AS tipo,
    ws.set_number                                                AS num_serie,
    ws.reps,
    ws.weight_kg                                                 AS peso_kg,
    ROUND(ws.estimated_1rm::numeric, 2)                         AS "1rm_estimado_kg",
    ROUND(ws.volume::numeric, 1)                                 AS volumen_kg,
    ws.is_pr                                                     AS es_pr
FROM workout_set ws
JOIN workout_session sess ON ws.session_id     = sess.id
JOIN exercise       ex   ON ws.exercise_id     = ex.id
JOIN muscle_group   mg   ON ex.muscle_group_id = mg.id
LEFT JOIN program_day pd  ON sess.program_day_id = pd.id
ORDER BY ws.logged_at DESC;
```

**Código SQL — `v_weekly_digest`** (usada por `gymops digest`, sección "Recent Weeks Overview"):
```sql
CREATE VIEW v_weekly_digest AS
SELECT
    DATE_TRUNC('week', sess.started_at)::date                   AS semana_inicio,
    mg.name                                                      AS musculo,
    COUNT(DISTINCT sess.id)                                      AS sesiones,
    COUNT(ws.id)                                                 AS total_series,
    SUM(ws.reps)                                                 AS total_reps,
    ROUND(SUM(ws.volume)::numeric, 1)                            AS volumen_kg,
    ROUND(MAX(ws.estimated_1rm)::numeric, 2)                     AS mejor_1rm_semana,
    COUNT(ws.id) FILTER (WHERE ws.is_pr)                         AS prs_semana,
    ROUND(AVG(ws.weight_kg)::numeric, 2)                         AS peso_promedio_kg
FROM workout_session sess
JOIN workout_set    ws  ON ws.session_id     = sess.id
JOIN exercise       ex  ON ws.exercise_id    = ex.id
JOIN muscle_group   mg  ON ex.muscle_group_id = mg.id
GROUP BY DATE_TRUNC('week', sess.started_at), mg.name
ORDER BY semana_inicio DESC, volumen_kg DESC;
```

**Código SQL — `v_session_summary`** (usada por `gymops sessions`):
```sql
CREATE VIEW v_session_summary AS
SELECT
    sess.id                                                     AS session_id,
    pd.name                                                     AS programa_dia,
    sess.started_at                                             AS inicio,
    sess.ended_at                                               AS fin,
    ROUND(
        EXTRACT(EPOCH FROM (sess.ended_at - sess.started_at)) / 60
    )::int                                                      AS duracion_min,
    COUNT(DISTINCT ws.exercise_id)                              AS ejercicios_distintos,
    COUNT(ws.id)                                                AS total_series,
    COALESCE(SUM(ws.reps), 0)                                   AS total_reps,
    COALESCE(ROUND(SUM(ws.volume)::numeric, 1), 0)              AS volumen_total_kg,
    COALESCE(ROUND(MAX(ws.estimated_1rm)::numeric, 2), 0)       AS mejor_1rm_sesion,
    COUNT(ws.id) FILTER (WHERE ws.is_pr)                        AS prs_logrados,
    sess.notes                                                  AS notas,
    CASE
        WHEN sess.ended_at IS NULL THEN 'Activa'
        ELSE 'Completada'
    END                                                         AS estado
FROM workout_session sess
LEFT JOIN program_day pd ON sess.program_day_id = pd.id
LEFT JOIN workout_set ws  ON ws.session_id      = sess.id
GROUP BY sess.id, pd.name, sess.started_at, sess.ended_at, sess.notes
ORDER BY sess.started_at DESC;
```

**Código SQL — `v_exercise_progress`** (usada por `gymops progress`):
```sql
CREATE VIEW v_exercise_progress AS
WITH sesion_maxima AS (
    SELECT
        ws.exercise_id,
        sess.started_at::date                                    AS fecha,
        MAX(ws.estimated_1rm)                                    AS max_1rm,
        MAX(ws.weight_kg)                                        AS max_peso,
        SUM(ws.volume)                                           AS volumen_dia
    FROM workout_set ws
    JOIN workout_session sess ON ws.session_id = sess.id
    GROUP BY ws.exercise_id, sess.started_at::date
)
SELECT
    ex.name                                                      AS ejercicio,
    mg.name                                                      AS musculo,
    sm.fecha,
    ROUND(sm.max_1rm::numeric, 2)                               AS "1rm_estimado_kg",
    ROUND(sm.max_peso::numeric, 2)                              AS peso_maximo_kg,
    ROUND(sm.volumen_dia::numeric, 1)                           AS volumen_kg,
    ROUND(
        (sm.max_1rm - LAG(sm.max_1rm) OVER (
            PARTITION BY sm.exercise_id ORDER BY sm.fecha
        ))::numeric, 2
    )                                                            AS delta_1rm,
    ROUND(
        ((sm.max_1rm - LAG(sm.max_1rm) OVER (
            PARTITION BY sm.exercise_id ORDER BY sm.fecha
        )) / NULLIF(LAG(sm.max_1rm) OVER (
            PARTITION BY sm.exercise_id ORDER BY sm.fecha
        ), 0) * 100)::numeric, 2
    )                                                            AS "cambio_pct",
    RANK() OVER (
        PARTITION BY sm.exercise_id ORDER BY sm.max_1rm DESC
    )                                                            AS ranking_historico
FROM sesion_maxima sm
JOIN exercise     ex ON sm.exercise_id     = ex.id
JOIN muscle_group mg ON ex.muscle_group_id = mg.id
ORDER BY ex.name, sm.fecha;
```

**Código SQL — `v_muscle_volume_week`** (usada por `gymops muscle-volume`):
```sql
CREATE VIEW v_muscle_volume_week AS
SELECT
    DATE_TRUNC('week', sess.started_at)::date                   AS semana,
    mg.id                                                        AS muscle_group_id,
    mg.name                                                      AS musculo,
    COUNT(DISTINCT sess.id)                                      AS sesiones,
    COUNT(ws.id)                                                 AS series,
    SUM(ws.reps)                                                 AS total_reps,
    ROUND(SUM(ws.volume)::numeric, 1)                           AS volumen_kg,
    ROUND(AVG(ws.weight_kg)::numeric, 2)                        AS peso_promedio_kg,
    COUNT(ws.id) FILTER (WHERE ws.is_pr)                        AS prs
FROM workout_session sess
JOIN workout_set    ws  ON ws.session_id      = sess.id
JOIN exercise       ex  ON ws.exercise_id     = ex.id
JOIN muscle_group   mg  ON ex.muscle_group_id = mg.id
WHERE sess.started_at >= NOW() - INTERVAL '56 days'
GROUP BY DATE_TRUNC('week', sess.started_at), mg.id, mg.name
ORDER BY semana DESC, volumen_kg DESC;
```

**Código SQL — `v_exercise_catalog`** (usada por `gymops list-exercises`):
```sql
CREATE VIEW v_exercise_catalog AS
SELECT
    ex.id,
    ex.name                                                      AS ejercicio,
    mg.name                                                      AS musculo,
    ex.type                                                      AS tipo,
    ex.equipment                                                 AS equipamiento,
    COUNT(ws.id)                                                 AS total_sets_registrados,
    MAX(ws.logged_at)::date                                      AS ultima_vez_usado,
    CASE
        WHEN COUNT(ws.id) = 0                   THEN 'Sin uso'
        WHEN MAX(ws.logged_at) < NOW() - INTERVAL '30 days' THEN 'Inactivo'
        ELSE                                         'Activo'
    END                                                          AS estado
FROM exercise ex
JOIN muscle_group mg ON ex.muscle_group_id = mg.id
LEFT JOIN workout_set ws ON ws.exercise_id = ex.id
GROUP BY ex.id, ex.name, mg.name, ex.type, ex.equipment
ORDER BY mg.name, ex.name;
```

**Código SQL — `v_program_overview`** (usada por `gymops show-program`):
```sql
CREATE VIEW v_program_overview AS
SELECT
    p.id                                                         AS program_id,
    p.name                                                       AS programa,
    p.author                                                     AS autor,
    p.days_per_week                                              AS dias_por_semana,
    pd.name                                                      AS dia,
    pd.day_order                                                 AS orden_dia,
    pd.focus                                                     AS enfoque,
    ex.name                                                      AS ejercicio,
    mg.name                                                      AS musculo,
    re.sets_target                                               AS series_objetivo,
    re.reps_target                                               AS reps_objetivo,
    re.rest_seconds                                              AS descanso_seg,
    re.order_in_day                                              AS orden_en_dia
FROM program p
JOIN program_day      pd  ON pd.program_id      = p.id
JOIN routine_exercise re  ON re.program_day_id  = pd.id
JOIN exercise         ex  ON re.exercise_id     = ex.id
JOIN muscle_group     mg  ON ex.muscle_group_id = mg.id
ORDER BY p.id, pd.day_order, re.order_in_day;
```

**Código SQL — `v_pr_timeline`** (usada por `gymops pr-timeline`):
```sql
CREATE VIEW v_pr_timeline AS
SELECT
    ws.logged_at::date                                           AS fecha,
    mg.name                                                      AS musculo,
    ex.name                                                      AS ejercicio,
    ws.weight_kg                                                 AS peso_kg,
    ws.reps,
    ROUND(ws.estimated_1rm::numeric, 2)                         AS "1rm_estimado_kg",
    pd.name                                                      AS sesion_dia,
    ROW_NUMBER() OVER (
        PARTITION BY ws.exercise_id ORDER BY ws.estimated_1rm DESC
    )                                                            AS puesto_historico
FROM workout_set ws
JOIN exercise       ex   ON ws.exercise_id     = ex.id
JOIN muscle_group   mg   ON ex.muscle_group_id = mg.id
JOIN workout_session sess ON ws.session_id     = sess.id
LEFT JOIN program_day pd  ON sess.program_day_id = pd.id
WHERE ws.is_pr = TRUE
ORDER BY ws.logged_at DESC;
```

### Fase 4 — Índices (`sql/06_indexes.sql`)
**Objetivo:** Evidenciar que el planificador de PostgreSQL usa los índices creados en las consultas frecuentes de la app.
```bash
psql -h localhost -U gymops -d gymops_db -c "EXPLAIN ANALYZE SELECT * FROM v_current_prs;"
psql -h localhost -U gymops -d gymops_db -c "EXPLAIN ANALYZE SELECT * FROM fn_exercise_history(1, 10);"
```
Busca en el plan de ejecución referencias a `idx_pr_exercise`, `idx_set_exercise_date` o `idx_set_logged_at` para confirmar que se usan (en vez de un `Seq Scan`).

**Código SQL — índices creados por `06_indexes.sql`:**
```sql
CREATE INDEX idx_set_session
    ON workout_set (session_id);

CREATE INDEX idx_set_exercise_date
    ON workout_set (exercise_id, logged_at DESC);

CREATE INDEX idx_set_logged_at
    ON workout_set (logged_at DESC);

CREATE INDEX idx_set_is_pr
    ON workout_set (exercise_id, estimated_1rm DESC)
    WHERE is_pr = TRUE;

CREATE INDEX idx_set_exercise_1rm
    ON workout_set (exercise_id, estimated_1rm DESC NULLS LAST);

CREATE INDEX idx_pr_exercise
    ON personal_record (exercise_id);

CREATE INDEX idx_pr_max_1rm
    ON personal_record (max_1rm DESC);

CREATE INDEX idx_session_started
    ON workout_session (started_at DESC);

CREATE INDEX idx_session_program_day
    ON workout_session (program_day_id);

CREATE INDEX idx_session_active
    ON workout_session (id)
    WHERE ended_at IS NULL;

CREATE INDEX idx_audit_table_op
    ON audit_log (table_name, operation, changed_at DESC);

CREATE INDEX idx_audit_changed_at
    ON audit_log (changed_at DESC);

CREATE INDEX idx_exercise_muscle
    ON exercise (muscle_group_id);

CREATE INDEX idx_exercise_name_lower
    ON exercise (LOWER(name));

CREATE INDEX idx_routine_day
    ON routine_exercise (program_day_id);
```

### Fase 5 — Procedimientos Almacenados (`sql/07_procedures.sql`)
**Objetivo:** Demostrar los SPs en PL/pgSQL, tanto los que usa la app como los que no.

```bash
gymops log --exercise "Barbell Bench Press" --sets 4 --reps 5 --weight 80   # sp_start_session, sp_log_set, sp_close_session
gymops exercise-stats --exercise "Barbell Bench Press"                       # sp_get_exercise_stats
gymops digest                                                                 # sp_weekly_digest (sección "This Week by Muscle Group")
```

**Código SQL — `sp_start_session`** (invocado por `gymops log` al abrir sesión):
```sql
CREATE OR REPLACE FUNCTION sp_start_session(
    p_program_day_id INT DEFAULT NULL
)
RETURNS TABLE(session_id INT, started_at TIMESTAMP, program_day_name TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_session_id   INT;
    v_day_name     TEXT;
    v_started_at   TIMESTAMP;
BEGIN
    -- Validar que el program_day_id exista si fue proporcionado
    IF p_program_day_id IS NOT NULL THEN
        SELECT name INTO v_day_name
        FROM program_day
        WHERE id = p_program_day_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'program_day_id % no existe en la tabla program_day.', p_program_day_id
                USING ERRCODE = 'no_data_found';
        END IF;
    ELSE
        v_day_name := 'Sesión libre (sin programa)';
    END IF;

    -- Crear la sesión
    INSERT INTO workout_session (program_day_id, started_at)
    VALUES (p_program_day_id, NOW())
    RETURNING id, workout_session.started_at
    INTO v_session_id, v_started_at;

    RAISE NOTICE 'Sesión % iniciada a las % — Día: %', v_session_id, v_started_at, v_day_name;

    RETURN QUERY
    SELECT v_session_id, v_started_at, v_day_name;
END;
$$;
```

**Código SQL — `sp_log_set`** (invocado por `gymops log` una vez por serie):
```sql
CREATE OR REPLACE FUNCTION sp_log_set(
    p_session_id   INT,
    p_exercise_id  INT,
    p_set_number   SMALLINT,
    p_reps         SMALLINT,
    p_weight_kg    NUMERIC(6,2)
)
RETURNS TABLE(
    set_id        INT,
    estimated_1rm NUMERIC(6,2),
    volume        NUMERIC(8,2),
    is_pr         BOOLEAN,
    pr_message    TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_set_id        INT;
    v_1rm           NUMERIC(6,2);
    v_volume        NUMERIC(8,2);
    v_is_pr         BOOLEAN := FALSE;
    v_pr_msg        TEXT;
    v_current_pr    NUMERIC(6,2);
    v_session_ended TIMESTAMP;
    v_exercise_name VARCHAR(100);
BEGIN
    -- -------------------------------------------------------------------------
    -- Validaciones previas
    -- -------------------------------------------------------------------------

    -- 1. La sesión debe existir y estar activa (ended_at IS NULL)
    SELECT ended_at INTO v_session_ended
    FROM workout_session
    WHERE id = p_session_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La sesión % no existe.', p_session_id
            USING ERRCODE = 'no_data_found';
    END IF;

    IF v_session_ended IS NOT NULL THEN
        RAISE EXCEPTION 'La sesión % ya fue cerrada el %. No se pueden agregar sets.',
            p_session_id, v_session_ended
            USING ERRCODE = 'check_violation';
    END IF;

    -- 2. El ejercicio debe existir
    SELECT name INTO v_exercise_name
    FROM exercise
    WHERE id = p_exercise_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El ejercicio_id % no existe en el catálogo.', p_exercise_id
            USING ERRCODE = 'no_data_found';
    END IF;

    -- 3. Validaciones de negocio
    IF p_reps <= 0 THEN
        RAISE EXCEPTION 'Las repeticiones deben ser mayor a 0. Recibido: %', p_reps
            USING ERRCODE = 'check_violation';
    END IF;

    IF p_weight_kg <= 0 THEN
        RAISE EXCEPTION 'El peso debe ser mayor a 0 kg. Recibido: %', p_weight_kg
            USING ERRCODE = 'check_violation';
    END IF;

    -- -------------------------------------------------------------------------
    -- Cálculos de negocio
    -- -------------------------------------------------------------------------

    -- Fórmula Epley: 1RM = weight * (1 + reps / 30.0)
    v_1rm    := ROUND(p_weight_kg * (1.0 + p_reps::NUMERIC / 30.0), 2);

    -- Volumen del set: weight * reps
    v_volume := ROUND(p_weight_kg * p_reps, 2);

    -- -------------------------------------------------------------------------
    -- Detección de PR
    -- -------------------------------------------------------------------------
    SELECT max_1rm INTO v_current_pr
    FROM personal_record
    WHERE exercise_id = p_exercise_id;

    IF NOT FOUND OR v_1rm > v_current_pr THEN
        v_is_pr := TRUE;
    END IF;

    -- -------------------------------------------------------------------------
    -- Insertar el set
    -- -------------------------------------------------------------------------
    INSERT INTO workout_set (
        session_id, exercise_id, set_number,
        reps, weight_kg, estimated_1rm, volume, is_pr
    )
    VALUES (
        p_session_id, p_exercise_id, p_set_number,
        p_reps, p_weight_kg, v_1rm, v_volume, v_is_pr
    )
    RETURNING id INTO v_set_id;

    -- -------------------------------------------------------------------------
    -- Actualizar o insertar PR
    -- -------------------------------------------------------------------------
    IF v_is_pr THEN
        INSERT INTO personal_record (exercise_id, max_1rm, achieved_at, set_id)
        VALUES (p_exercise_id, v_1rm, NOW(), v_set_id)
        ON CONFLICT (exercise_id) DO UPDATE
            SET max_1rm      = EXCLUDED.max_1rm,
                achieved_at  = EXCLUDED.achieved_at,
                set_id       = EXCLUDED.set_id;

        v_pr_msg := FORMAT(
            '🏆 ¡NUEVO PR en %s! 1RM estimado: %s kg (anterior: %s kg)',
            v_exercise_name,
            v_1rm,
            COALESCE(v_current_pr::TEXT, 'ninguno')
        );

        RAISE NOTICE '%', v_pr_msg;
    ELSE
        v_pr_msg := FORMAT(
            'Set registrado — %s: %s reps × %s kg → 1RM: %s kg',
            v_exercise_name, p_reps, p_weight_kg, v_1rm
        );
    END IF;

    -- -------------------------------------------------------------------------
    -- Registro de auditoría
    -- -------------------------------------------------------------------------
    INSERT INTO audit_log (table_name, operation, old_data, new_data)
    VALUES (
        'workout_set',
        'INSERT',
        NULL,
        jsonb_build_object(
            'set_id',        v_set_id,
            'session_id',    p_session_id,
            'exercise_id',   p_exercise_id,
            'exercise',      v_exercise_name,
            'set_number',    p_set_number,
            'reps',          p_reps,
            'weight_kg',     p_weight_kg,
            'estimated_1rm', v_1rm,
            'volume',        v_volume,
            'is_pr',         v_is_pr
        )
    );

    -- -------------------------------------------------------------------------
    -- Resultado
    -- -------------------------------------------------------------------------
    RETURN QUERY
    SELECT v_set_id, v_1rm, v_volume, v_is_pr, v_pr_msg;
END;
$$;
```

**Código SQL — `sp_close_session`** (invocado por `gymops log` al detectar sesión previa del mismo ejercicio):
```sql
CREATE OR REPLACE FUNCTION sp_close_session(
    p_session_id INT
)
RETURNS TABLE(
    session_id        INT,
    duration_minutes  NUMERIC(8,2),
    total_sets        BIGINT,
    total_volume_kg   NUMERIC(12,2),
    prs_achieved      BIGINT,
    exercises_worked  BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_started_at   TIMESTAMP;
    v_ended_at     TIMESTAMP;
    v_duration     NUMERIC(8,2);
    v_total_sets   BIGINT;
    v_total_vol    NUMERIC(12,2);
    v_prs          BIGINT;
    v_exercises    BIGINT;
BEGIN
    -- Verificar que la sesión exista
    SELECT started_at, ended_at
    INTO v_started_at, v_ended_at
    FROM workout_session
    WHERE id = p_session_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La sesión % no existe.', p_session_id
            USING ERRCODE = 'no_data_found';
    END IF;

    -- Verificar que no esté ya cerrada
    IF v_ended_at IS NOT NULL THEN
        RAISE EXCEPTION 'La sesión % ya fue cerrada el %. Use sp_get_exercise_stats para consultar.',
            p_session_id, v_ended_at
            USING ERRCODE = 'check_violation';
    END IF;

    -- Verificar que tenga al menos un set registrado
    SELECT COUNT(*) INTO v_total_sets
    FROM workout_set
    WHERE workout_set.session_id = p_session_id;

    IF v_total_sets = 0 THEN
        RAISE WARNING 'La sesión % no tiene sets registrados. Cerrando de todos modos.', p_session_id;
    END IF;

    -- Cerrar la sesión
    UPDATE workout_session
    SET ended_at = NOW()
    WHERE id = p_session_id
    RETURNING ended_at INTO v_ended_at;

    -- Calcular duración en minutos
    v_duration := ROUND(EXTRACT(EPOCH FROM (v_ended_at - v_started_at)) / 60.0, 2);

    -- Calcular estadísticas de la sesión
    SELECT
        COUNT(*)                                   AS total_sets,
        COALESCE(SUM(volume), 0)                   AS total_volume,
        COUNT(*) FILTER (WHERE is_pr = TRUE)       AS prs,
        COUNT(DISTINCT exercise_id)                AS exercises
    INTO v_total_sets, v_total_vol, v_prs, v_exercises
    FROM workout_set
    WHERE workout_set.session_id = p_session_id;

    RAISE NOTICE '✅ Sesión % cerrada — Duración: % min | Sets: % | Volumen: % kg | PRs: % | Ejercicios: %',
        p_session_id, v_duration, v_total_sets, v_total_vol, v_prs, v_exercises;

    RETURN QUERY
    SELECT
        p_session_id,
        v_duration,
        v_total_sets,
        v_total_vol,
        v_prs,
        v_exercises;
END;
$$;
```

**Código SQL — `sp_get_exercise_stats`** (invocado por `gymops exercise-stats`):
```sql
CREATE OR REPLACE FUNCTION sp_get_exercise_stats(
    p_exercise_id INT
)
RETURNS TABLE(
    exercise_name       VARCHAR(100),
    muscle_group        VARCHAR(50),
    current_pr_1rm      NUMERIC(6,2),
    pr_achieved_at      TIMESTAMP,
    best_session_volume NUMERIC(12,2),
    avg_reps            NUMERIC(5,2),
    avg_weight_kg       NUMERIC(6,2),
    total_sets_logged   BIGINT,
    total_sessions      BIGINT,
    last_session_date   TIMESTAMP,
    days_since_last     INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_name     VARCHAR(100);
    v_muscle   VARCHAR(50);
BEGIN
    -- Verificar que el ejercicio exista
    SELECT e.name, mg.name
    INTO v_name, v_muscle
    FROM exercise e
    JOIN muscle_group mg ON mg.id = e.muscle_group_id
    WHERE e.id = p_exercise_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El ejercicio_id % no existe en el catálogo.', p_exercise_id
            USING ERRCODE = 'no_data_found';
    END IF;

    RETURN QUERY
    WITH sets_data AS (
        -- Todos los sets del ejercicio con datos de sesión
        SELECT
            ws.session_id,
            ws.reps,
            ws.weight_kg,
            ws.estimated_1rm,
            ws.volume,
            ws.logged_at
        FROM workout_set ws
        WHERE ws.exercise_id = p_exercise_id
    ),
    session_volumes AS (
        -- Volumen total por sesión
        SELECT
            session_id,
            SUM(volume) AS session_volume
        FROM sets_data
        GROUP BY session_id
    )
    SELECT
        v_name                                           AS exercise_name,
        v_muscle                                         AS muscle_group,
        pr.max_1rm                                       AS current_pr_1rm,
        pr.achieved_at                                   AS pr_achieved_at,
        MAX(sv.session_volume)                           AS best_session_volume,
        ROUND(AVG(sd.reps), 2)                           AS avg_reps,
        ROUND(AVG(sd.weight_kg), 2)                      AS avg_weight_kg,
        COUNT(sd.reps)                                   AS total_sets_logged,
        COUNT(DISTINCT sd.session_id)                    AS total_sessions,
        MAX(sd.logged_at)                                AS last_session_date,
        EXTRACT(DAY FROM NOW() - MAX(sd.logged_at))::INT AS days_since_last
    FROM sets_data sd
    LEFT JOIN session_volumes sv ON sv.session_id = sd.session_id
    LEFT JOIN personal_record pr ON pr.exercise_id = p_exercise_id
    GROUP BY pr.max_1rm, pr.achieved_at;
END;
$$;
```

**Código SQL — `sp_weekly_digest`** (invocado por `gymops digest`):
```sql
CREATE OR REPLACE FUNCTION sp_weekly_digest(
    p_week_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE(
    week_start         DATE,
    week_end           DATE,
    muscle_group       VARCHAR(50),
    sessions_count     BIGINT,
    total_sets         BIGINT,
    total_volume_kg    NUMERIC(12,2),
    prs_in_week        BIGINT,
    top_exercise       VARCHAR(100),
    top_exercise_vol   NUMERIC(12,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_week_start DATE;
    v_week_end   DATE;
    v_row_count  INT;
BEGIN
    -- Calcular lunes y domingo de la semana que contiene p_week_date
    v_week_start := DATE_TRUNC('week', p_week_date::TIMESTAMP)::DATE;
    v_week_end   := v_week_start + INTERVAL '6 days';

    RAISE NOTICE 'Generando digest para la semana % al %', v_week_start, v_week_end;

    -- Verificar si hay datos para esa semana
    SELECT COUNT(*) INTO v_row_count
    FROM workout_session ws
    WHERE ws.started_at::DATE BETWEEN v_week_start AND v_week_end
      AND ws.ended_at IS NOT NULL;

    IF v_row_count = 0 THEN
        RAISE WARNING 'No se encontraron sesiones cerradas entre % y %.', v_week_start, v_week_end;
    END IF;

    RETURN QUERY
    WITH week_sets AS (
        -- Todos los sets de sesiones cerradas en la semana
        SELECT
            wset.id           AS set_id,
            wset.session_id,
            wset.exercise_id,
            wset.volume,
            wset.is_pr,
            wsess.started_at
        FROM workout_set wset
        JOIN workout_session wsess ON wsess.id = wset.session_id
        WHERE wsess.started_at::DATE BETWEEN v_week_start AND v_week_end
          AND wsess.ended_at IS NOT NULL
    ),
    by_muscle AS (
        -- Agrupación por grupo muscular
        SELECT
            mg.name                              AS muscle_name,
            COUNT(DISTINCT ws.session_id)        AS sessions,
            COUNT(ws.set_id)                     AS sets_count,
            COALESCE(SUM(ws.volume), 0)          AS vol_total,
            COUNT(*) FILTER (WHERE ws.is_pr)     AS prs_count
        FROM week_sets ws
        JOIN exercise e       ON e.id  = ws.exercise_id
        JOIN muscle_group mg  ON mg.id = e.muscle_group_id
        GROUP BY mg.name
    ),
    top_ex AS (
        -- Ejercicio con mayor volumen por grupo muscular
        SELECT DISTINCT ON (e.muscle_group_id)
            mg.name           AS mg_name,
            e.name            AS ex_name,
            SUM(ws.volume) OVER (PARTITION BY ws.exercise_id) AS ex_vol
        FROM week_sets ws
        JOIN exercise e       ON e.id  = ws.exercise_id
        JOIN muscle_group mg  ON mg.id = e.muscle_group_id
        ORDER BY e.muscle_group_id, ex_vol DESC
    )
    SELECT
        v_week_start                    AS week_start,
        v_week_end::DATE                AS week_end,
        bm.muscle_name                  AS muscle_group,
        bm.sessions                     AS sessions_count,
        bm.sets_count                   AS total_sets,
        bm.vol_total                    AS total_volume_kg,
        bm.prs_count                    AS prs_in_week,
        tx.ex_name                      AS top_exercise,
        tx.ex_vol                       AS top_exercise_vol
    FROM by_muscle bm
    LEFT JOIN top_ex tx ON tx.mg_name = bm.muscle_name
    ORDER BY bm.vol_total DESC;
END;
$$;
```

### Fase 6 — Funciones UDF (`sql/08_functions.sql`)
**Objetivo:** Mostrar funciones escalares y de tipo tabla.

Funciones tipo tabla vía CLI:
```bash
gymops history --exercise "Barbell Bench Press" --limit 10   # fn_exercise_history
gymops stats --exercise "Barbell Bench Press"                 # fn_exercise_history
gymops muscle-volume --week 2026-06-22                        # fn_weekly_volume (lunes de la semana a analizar)
```

**Código SQL — `fn_exercise_history`** (invocada por `gymops history` y `gymops stats`):
```sql
CREATE OR REPLACE FUNCTION fn_exercise_history(
    p_exercise_id  INT,
    p_n_sessions   INT DEFAULT 5
)
RETURNS TABLE(
    session_id     INT,
    session_date   TIMESTAMP,
    set_number     SMALLINT,
    reps           SMALLINT,
    weight_kg      NUMERIC(6,2),
    estimated_1rm  NUMERIC(6,2),
    volume         NUMERIC(8,2),
    is_pr          BOOLEAN,
    set_rank       BIGINT       -- posición del set dentro de la sesión
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_exercise_name VARCHAR(100);
BEGIN
    -- Verificar ejercicio
    SELECT name INTO v_exercise_name
    FROM exercise
    WHERE id = p_exercise_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'fn_exercise_history: ejercicio_id % no existe.', p_exercise_id;
    END IF;

    IF p_n_sessions IS NULL OR p_n_sessions <= 0 THEN
        RAISE EXCEPTION 'fn_exercise_history: n_sessions debe ser > 0. Recibido: %', p_n_sessions;
    END IF;

    RAISE NOTICE 'Historial de "%" — últimas % sesiones', v_exercise_name, p_n_sessions;

    RETURN QUERY
    WITH ranked_sessions AS (
        -- Obtener las N sesiones más recientes con este ejercicio
        SELECT DISTINCT ws.session_id,
               wsess.started_at AS session_date,
               DENSE_RANK() OVER (ORDER BY wsess.started_at DESC) AS session_rank
        FROM workout_set ws
        JOIN workout_session wsess ON wsess.id = ws.session_id
        WHERE ws.exercise_id = p_exercise_id
    ),
    top_sessions AS (
        SELECT rs.session_id, rs.session_date
        FROM ranked_sessions rs
        WHERE rs.session_rank <= p_n_sessions
    )
    SELECT
        ws.session_id,
        ts.session_date,
        ws.set_number,
        ws.reps,
        ws.weight_kg,
        ws.estimated_1rm,
        ws.volume,
        ws.is_pr,
        ROW_NUMBER() OVER (
            PARTITION BY ws.session_id
            ORDER BY ws.set_number
        ) AS set_rank
    FROM workout_set ws
    JOIN top_sessions ts ON ts.session_id = ws.session_id
    WHERE ws.exercise_id = p_exercise_id
    ORDER BY ts.session_date DESC, ws.set_number;
END;
$$;
```

**Código SQL — `fn_weekly_volume`** (invocada por `gymops muscle-volume --week`):
```sql
CREATE OR REPLACE FUNCTION fn_weekly_volume(
    p_week_start DATE DEFAULT DATE_TRUNC('week', CURRENT_DATE)::DATE
)
RETURNS TABLE(
    week_start       DATE,
    week_end         DATE,
    muscle_group     VARCHAR(50),
    total_sets       BIGINT,
    total_volume_kg  NUMERIC(12,2),
    unique_exercises BIGINT,
    unique_sessions  BIGINT,
    prs_achieved     BIGINT,
    avg_volume_set   NUMERIC(8,2)    -- volumen promedio por set
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_week_end DATE;
BEGIN
    v_week_end := p_week_start + INTERVAL '6 days';

    RAISE NOTICE 'Volumen semanal: % → %', p_week_start, v_week_end;

    RETURN QUERY
    SELECT
        p_week_start                                          AS week_start,
        v_week_end                                            AS week_end,
        mg.name                                               AS muscle_group,
        COUNT(ws.id)                                          AS total_sets,
        COALESCE(ROUND(SUM(ws.volume), 2), 0)                AS total_volume_kg,
        COUNT(DISTINCT ws.exercise_id)                        AS unique_exercises,
        COUNT(DISTINCT ws.session_id)                         AS unique_sessions,
        COUNT(ws.id) FILTER (WHERE ws.is_pr = TRUE)          AS prs_achieved,
        COALESCE(ROUND(AVG(ws.volume), 2), 0)                AS avg_volume_set
    FROM workout_set ws
    JOIN workout_session wsess ON wsess.id  = ws.session_id
    JOIN exercise e            ON e.id      = ws.exercise_id
    JOIN muscle_group mg       ON mg.id     = e.muscle_group_id
    WHERE wsess.started_at::DATE BETWEEN p_week_start AND v_week_end
      AND wsess.ended_at IS NOT NULL         -- sólo sesiones cerradas
    GROUP BY mg.name
    ORDER BY total_volume_kg DESC;
END;
$$;
```

Las funciones escalares (`fn_epley_1rm`, `fn_volume`, `fn_is_pr`, `fn_session_volume`) no tienen comando propio: son cálculos internos que se ejecutan automáticamente dentro de los triggers y SPs cada vez que corres `gymops log` (igual que los índices, se demuestran de forma indirecta).

### Fase 7 — Triggers (`sql/09_triggers.sql`)
**Objetivo:** Demostrar la validación, el cálculo automático de 1RM/volumen, la detección de PR y la auditoría, todo disparado por triggers.
```bash
gymops log --exercise "Barbell Bench Press" --sets 4 --reps 5 --weight 82.5
```
El mismo comando de la Fase 5 dispara, en orden: `trg_validate_set` y `trg_prevent_closed_session` (BEFORE INSERT), luego `trg_calculate_1rm`, `trg_update_pr` y `trg_audit_set` (AFTER INSERT); si se actualiza un PR, `trg_update_pr` dispara además `trg_audit_pr` sobre `personal_record`. Para verificar el efecto en la auditoría:
```bash
psql -h localhost -U gymops -d gymops_db -c "SELECT * FROM audit_log ORDER BY changed_at DESC LIMIT 5;"
```

**Código SQL — `trg_validate_set`** (BEFORE INSERT — valida reps, peso y set_number):
```sql
CREATE OR REPLACE FUNCTION fn_trg_validate_set_row()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar reps > 0
    IF NEW.reps IS NULL OR NEW.reps <= 0 THEN
        RAISE EXCEPTION
            '[trg_validate_set] Reps inválidas: %. Deben ser > 0.',
            NEW.reps
            USING ERRCODE = 'check_violation';
    END IF;

    -- Validar weight_kg > 0
    IF NEW.weight_kg IS NULL OR NEW.weight_kg <= 0 THEN
        RAISE EXCEPTION
            '[trg_validate_set] Peso inválido: % kg. Debe ser > 0.',
            NEW.weight_kg
            USING ERRCODE = 'check_violation';
    END IF;

    -- Validar set_number > 0
    IF NEW.set_number IS NULL OR NEW.set_number <= 0 THEN
        RAISE EXCEPTION
            '[trg_validate_set] set_number inválido: %. Debe ser > 0.',
            NEW.set_number
            USING ERRCODE = 'check_violation';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validate_set
    BEFORE INSERT ON workout_set
    FOR EACH ROW
    EXECUTE FUNCTION fn_trg_validate_set_row();
```

**Código SQL — `trg_prevent_closed_session`** (BEFORE INSERT — bloquea sets en sesiones cerradas):
```sql
CREATE OR REPLACE FUNCTION fn_trg_prevent_closed_session_row()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_ended_at TIMESTAMP;
BEGIN
    SELECT ended_at INTO v_ended_at
    FROM workout_session
    WHERE id = NEW.session_id;

    IF v_ended_at IS NOT NULL THEN
        RAISE EXCEPTION
            '[trg_prevent_closed_session] La sesión % fue cerrada el %. '
            'No se pueden registrar sets en una sesión cerrada.',
            NEW.session_id, v_ended_at
            USING ERRCODE = 'check_violation';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_prevent_closed_session
    BEFORE INSERT ON workout_set
    FOR EACH ROW
    EXECUTE FUNCTION fn_trg_prevent_closed_session_row();
```

**Código SQL — `trg_calculate_1rm`** (AFTER INSERT — calcula 1RM Epley y volumen):
```sql
CREATE OR REPLACE FUNCTION fn_trg_calculate_1rm_row()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_1rm    NUMERIC(6,2);
    v_volume NUMERIC(8,2);
BEGIN
    -- Fórmula Epley: 1RM = weight * (1 + reps/30)
    -- Para 1 rep: el 1RM es igual al peso levantado
    IF NEW.reps = 1 THEN
        v_1rm := NEW.weight_kg;
    ELSE
        v_1rm := ROUND(NEW.weight_kg * (1.0 + NEW.reps::NUMERIC / 30.0), 2);
    END IF;

    -- Volumen del set
    v_volume := ROUND(NEW.weight_kg * NEW.reps, 2);

    -- Actualizar los campos calculados en el mismo registro
    UPDATE workout_set
    SET estimated_1rm = v_1rm,
        volume        = v_volume
    WHERE id = NEW.id;

    RETURN NULL;  -- AFTER trigger, no hay NEW para retornar
END;
$$;

CREATE TRIGGER trg_calculate_1rm
    AFTER INSERT ON workout_set
    FOR EACH ROW
    EXECUTE FUNCTION fn_trg_calculate_1rm_row();
```

**Código SQL — `trg_update_pr`** (AFTER INSERT/UPDATE — detecta y actualiza PRs):
```sql
CREATE OR REPLACE FUNCTION fn_trg_update_pr_row()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_1rm        NUMERIC(6,2);
    v_current_pr NUMERIC(6,2);
BEGIN
    -- Recalcular 1RM (puede que aún sea NULL si el TRG-03 aún no actualizó)
    IF NEW.reps = 1 THEN
        v_1rm := NEW.weight_kg;
    ELSE
        v_1rm := ROUND(NEW.weight_kg * (1.0 + NEW.reps::NUMERIC / 30.0), 2);
    END IF;

    -- Obtener PR actual del ejercicio
    SELECT max_1rm INTO v_current_pr
    FROM personal_record
    WHERE exercise_id = NEW.exercise_id;

    -- Si es PR: upsert en personal_record y marcar el set
    IF NOT FOUND OR v_1rm > v_current_pr THEN

        INSERT INTO personal_record (exercise_id, max_1rm, achieved_at, set_id)
        VALUES (NEW.exercise_id, v_1rm, NOW(), NEW.id)
        ON CONFLICT (exercise_id) DO UPDATE
            SET max_1rm     = EXCLUDED.max_1rm,
                achieved_at = EXCLUDED.achieved_at,
                set_id      = EXCLUDED.set_id;

        -- Marcar el set como PR
        UPDATE workout_set
        SET is_pr = TRUE
        WHERE id = NEW.id;

        RAISE NOTICE '[trg_update_pr] ¡Nuevo PR en ejercicio_id %! 1RM: %.2f kg (anterior: %)',
            NEW.exercise_id, v_1rm, COALESCE(v_current_pr::TEXT, 'ninguno');
    END IF;

    RETURN NULL;
END;
$$;

CREATE TRIGGER trg_update_pr
    AFTER INSERT OR UPDATE ON workout_set
    FOR EACH ROW
    EXECUTE FUNCTION fn_trg_update_pr_row();
```

**Código SQL — `trg_audit_set`** (AFTER INSERT/UPDATE/DELETE — auditoría de workout_set):
```sql
CREATE OR REPLACE FUNCTION fn_trg_audit_set_row()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_data JSONB := NULL;
    v_new_data JSONB := NULL;
    v_op       VARCHAR(10);
BEGIN
    v_op := TG_OP;

    -- Construir JSON de datos anteriores (UPDATE y DELETE)
    IF TG_OP IN ('UPDATE', 'DELETE') THEN
        v_old_data := jsonb_build_object(
            'id',           OLD.id,
            'session_id',   OLD.session_id,
            'exercise_id',  OLD.exercise_id,
            'set_number',   OLD.set_number,
            'reps',         OLD.reps,
            'weight_kg',    OLD.weight_kg,
            'estimated_1rm', OLD.estimated_1rm,
            'volume',       OLD.volume,
            'is_pr',        OLD.is_pr,
            'logged_at',    OLD.logged_at
        );
    END IF;

    -- Construir JSON de datos nuevos (INSERT y UPDATE)
    IF TG_OP IN ('INSERT', 'UPDATE') THEN
        v_new_data := jsonb_build_object(
            'id',           NEW.id,
            'session_id',   NEW.session_id,
            'exercise_id',  NEW.exercise_id,
            'set_number',   NEW.set_number,
            'reps',         NEW.reps,
            'weight_kg',    NEW.weight_kg,
            'estimated_1rm', NEW.estimated_1rm,
            'volume',       NEW.volume,
            'is_pr',        NEW.is_pr,
            'logged_at',    NEW.logged_at
        );
    END IF;

    INSERT INTO audit_log (table_name, operation, old_data, new_data, changed_at)
    VALUES ('workout_set', v_op, v_old_data, v_new_data, NOW());

    RETURN NULL;  -- AFTER trigger
END;
$$;

CREATE TRIGGER trg_audit_set
    AFTER INSERT OR UPDATE OR DELETE ON workout_set
    FOR EACH ROW
    EXECUTE FUNCTION fn_trg_audit_set_row();
```

**Código SQL — `trg_audit_pr`** (AFTER UPDATE — auditoría de cambios de PR):
```sql
CREATE OR REPLACE FUNCTION fn_trg_audit_pr_row()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Solo auditar cuando el max_1rm cambia efectivamente
    IF OLD.max_1rm IS DISTINCT FROM NEW.max_1rm THEN
        INSERT INTO audit_log (table_name, operation, old_data, new_data, changed_at)
        VALUES (
            'personal_record',
            'UPDATE',
            jsonb_build_object(
                'id',          OLD.id,
                'exercise_id', OLD.exercise_id,
                'max_1rm',     OLD.max_1rm,
                'achieved_at', OLD.achieved_at,
                'set_id',      OLD.set_id
            ),
            jsonb_build_object(
                'id',          NEW.id,
                'exercise_id', NEW.exercise_id,
                'max_1rm',     NEW.max_1rm,
                'achieved_at', NEW.achieved_at,
                'set_id',      NEW.set_id
            ),
            NOW()
        );

        RAISE NOTICE '[trg_audit_pr] PR del ejercicio_id % actualizado: %.2f → %.2f kg',
            NEW.exercise_id, OLD.max_1rm, NEW.max_1rm;
    END IF;

    RETURN NULL;
END;
$$;

CREATE TRIGGER trg_audit_pr
    AFTER UPDATE ON personal_record
    FOR EACH ROW
    EXECUTE FUNCTION fn_trg_audit_pr_row();
```

---

¡Felicidades! Ahora estás listo para ir al gimnasio con tu terminal y registrar tu progreso con **GymOps**. ¡La constancia y el registro de cargas son las claves de la sobrecarga progresiva!
