-- =============================================================================
-- GymOps — Base de Datos II
-- Script 02: SEED — Datos iniciales
-- Autor: Piero Rivera
-- =============================================================================

-- =============================================================================
-- 1. GRUPOS MUSCULARES
-- =============================================================================
INSERT INTO muscle_group (name, description) VALUES
    ('Pecho',      'Músculos pectorales: mayor y menor'),
    ('Espalda',    'Dorsal ancho, trapecio, romboides y erectores espinales'),
    ('Hombros',    'Deltoides anterior, lateral y posterior'),
    ('Bíceps',     'Bíceps braquial y braquiorradial'),
    ('Tríceps',    'Tríceps braquial: cabezas larga, lateral y medial'),
    ('Piernas',    'Cuádriceps, isquiotibiales y glúteos'),
    ('Glúteos',    'Glúteo mayor, medio y menor'),
    ('Abdomen',    'Recto abdominal, oblicuos y transverso'),
    ('Pantorrilla','Gastrocnemio y sóleo'),
    ('Antebrazos', 'Flexores y extensores del antebrazo');

-- =============================================================================
-- 2. EJERCICIOS (50+ del catálogo base)
-- =============================================================================

-- PECHO
INSERT INTO exercise (name, muscle_group_id, type, equipment, description) VALUES
    ('Press de Banca con Barra',          1, 'compound',  'barbell',   'Press de banca con barra — ejercicio principal de pecho'),
    ('Press Inclinado con Barra',  1, 'compound',  'barbell',   'Press inclinado con barra — enfoque en pecho superior'),
    ('Press Declinado con Barra',  1, 'compound',  'barbell',   'Press declinado con barra — pecho inferior'),
    ('Press de Banca con Mancuernas',         1, 'compound',  'dumbbell',  'Press de banca con mancuernas'),
    ('Press Inclinado con Mancuernas',       1, 'compound',  'dumbbell',  'Press inclinado con mancuernas'),
    ('Aperturas en Polea',                    1, 'isolation', 'cable',     'Aperturas en polea — énfasis en aducción del pecho'),
    ('Aperturas con Mancuernas',                 1, 'isolation', 'dumbbell',  'Aperturas con mancuernas'),
    ('Fondos de Pecho',                    1, 'compound',  'bodyweight','Fondos en paralelas con énfasis en pecho'),
    ('Flexiones',                      1, 'compound',  'bodyweight','Flexiones de pecho');

-- ESPALDA
INSERT INTO exercise (name, muscle_group_id, type, equipment, description) VALUES
    ('Remo con Barra',                  2, 'compound',  'barbell',   'Remo con barra — ejercicio principal de espalda'),
    ('Dominadas',                      2, 'compound',  'bodyweight','Dominadas con agarre prono'),
    ('Dominadas Supinas',                      2, 'compound',  'bodyweight','Dominadas con agarre supino — mayor activación de bíceps'),
    ('Jalón al Pecho',                 2, 'compound',  'cable',     'Jalón al pecho en polea — enfoque en dorsal ancho'),
    ('Remo Sentado en Polea',             2, 'compound',  'cable',     'Remo sentado en polea — dorsal y romboides'),
    ('Remo con Mancuerna',                 2, 'compound',  'dumbbell',  'Remo con mancuerna a una mano'),
    ('Jalón a la Cara',                    2, 'isolation', 'cable',     'Jalón a la cara — deltoides posterior y manguito rotador'),
    ('Peso Muerto',                     2, 'compound',  'barbell',   'Peso muerto convencional — ejercicio rey de fuerza'),
    ('Peso Muerto Rumano',            2, 'compound',  'barbell',   'Peso muerto rumano — isquiotibiales y lumbar');

-- HOMBROS
INSERT INTO exercise (name, muscle_group_id, type, equipment, description) VALUES
    ('Press Militar',               3, 'compound',  'barbell',   'Press militar con barra — deltoides anterior y lateral'),
    ('Press de Hombros con Mancuernas',      3, 'compound',  'dumbbell',  'Press de hombros con mancuernas'),
    ('Elevaciones Laterales',                3, 'isolation', 'dumbbell',  'Elevaciones laterales — deltoides lateral'),
    ('Elevaciones Laterales en Polea',          3, 'isolation', 'cable',     'Elevaciones laterales en polea'),
    ('Aperturas Posteriores',                3, 'isolation', 'dumbbell',  'Aperturas posteriores — deltoides posterior'),
    ('Press Arnold',                 3, 'compound',  'dumbbell',  'Press Arnold — trabaja los 3 haces del deltoides');

-- BÍCEPS
INSERT INTO exercise (name, muscle_group_id, type, equipment, description) VALUES
    ('Curl con Barra',                 4, 'isolation', 'barbell',   'Curl con barra — ejercicio principal de bíceps'),
    ('Curl con Mancuernas',                4, 'isolation', 'dumbbell',  'Curl con mancuernas alternado'),
    ('Curl Inclinado con Mancuernas',        4, 'isolation', 'dumbbell',  'Curl inclinado — mayor estiramiento del bíceps'),
    ('Curl Martillo',                  4, 'isolation', 'dumbbell',  'Curl martillo — énfasis en braquiorradial'),
    ('Curl en Polea',                   4, 'isolation', 'cable',     'Curl en polea baja'),
    ('Curl Predicador',                4, 'isolation', 'barbell',   'Curl en banco predicador');

-- TRÍCEPS
INSERT INTO exercise (name, muscle_group_id, type, equipment, description) VALUES
    ('Extensión de Tríceps en Polea',              5, 'isolation', 'cable',     'Extensión en polea alta — cabeza lateral del tríceps'),
    ('Extensión de Tríceps sobre la Cabeza',    5, 'isolation', 'dumbbell',  'Extensión sobre la cabeza — cabeza larga del tríceps'),
    ('Press Francés',                5, 'isolation', 'barbell',   'Press francés con barra — tríceps completo'),
    ('Fondos de Tríceps',                   5, 'compound',  'bodyweight','Fondos en paralelas — énfasis en tríceps'),
    ('Press de Banca Agarre Cerrado',       5, 'compound',  'barbell',   'Press agarre cerrado — tríceps y pecho');

-- PIERNAS
INSERT INTO exercise (name, muscle_group_id, type, equipment, description) VALUES
    ('Sentadilla con Barra',                6, 'compound',  'barbell',   'Sentadilla con barra — ejercicio rey de piernas'),
    ('Sentadilla Frontal',                  6, 'compound',  'barbell',   'Sentadilla frontal — mayor énfasis en cuádriceps'),
    ('Prensa de Piernas',                    6, 'compound',  'machine',   'Prensa de piernas en máquina'),
    ('Sentadilla Búlgara',        6, 'compound',  'dumbbell',  'Sentadilla búlgara — cuádriceps y glúteos'),
    ('Sentadilla Hack',                   6, 'compound',  'machine',   'Hack squat en máquina'),
    ('Extensión de Piernas',                6, 'isolation', 'machine',   'Extensión de piernas — cuádriceps aislado'),
    ('Curl Femoral',                     6, 'isolation', 'machine',   'Curl de piernas — isquiotibiales aislado'),
    ('Peso Muerto Piernas Rígidas',           6, 'compound',  'barbell',   'Peso muerto piernas rígidas — isquiotibiales');

-- GLÚTEOS
INSERT INTO exercise (name, muscle_group_id, type, equipment, description) VALUES
    ('Empuje de Cadera',                   7, 'compound',  'barbell',   'Empuje de cadera con barra — glúteo mayor'),
    ('Patada de Glúteo en Polea',               7, 'isolation', 'cable',     'Patada trasera en polea — glúteo medio y mayor'),
    ('Puente de Glúteos',                 7, 'isolation', 'bodyweight','Puente de glúteos en el suelo');

-- ABDOMEN
INSERT INTO exercise (name, muscle_group_id, type, equipment, description) VALUES
    ('Plancha',                        8, 'isolation', 'bodyweight','Plancha isométrica — core completo'),
    ('Crunch en Polea',                 8, 'isolation', 'cable',     'Crunch en polea — recto abdominal'),
    ('Elevación de Piernas Colgado',            8, 'isolation', 'bodyweight','Elevación de piernas colgado — abdomen inferior');

-- PANTORRILLA
INSERT INTO exercise (name, muscle_group_id, type, equipment, description) VALUES
    ('Elevación de Talones de Pie',          9, 'isolation', 'machine',   'Elevación de talones de pie — gastrocnemio'),
    ('Elevación de Talones Sentado',            9, 'isolation', 'machine',   'Elevación de talones sentado — sóleo');

-- =============================================================================
-- 3. PROGRAMAS DE ENTRENAMIENTO (Predeterminados)
-- =============================================================================

-- Programa 1: Upper/Lower 4-Day
INSERT INTO program (name, description, days_per_week, author) VALUES
    ('Superior/Inferior 4 Días', 'Split superior/inferior de 4 días por semana. Enfoque en fuerza e hipertrofia.', 4, 'system');

-- Días del Upper/Lower 4-Day
INSERT INTO program_day (program_id, name, day_order, focus) VALUES
    (1, 'Superior A — Fuerza',      1, 'Superior — Fuerza (cargas altas, reps bajas)'),
    (1, 'Inferior A — Fuerza',      2, 'Inferior — Fuerza (sentadilla y peso muerto)'),
    (1, 'Superior B — Hipertrofia',   3, 'Superior — Hipertrofia (volumen moderado)'),
    (1, 'Inferior B — Hipertrofia',   4, 'Inferior — Hipertrofia (volumen y tiempo bajo tensión)');

-- Ejercicios Upper A (Fuerza)
INSERT INTO routine_exercise (program_day_id, exercise_id, sets_target, reps_target, rest_seconds, order_in_day) VALUES
    (1, (SELECT id FROM exercise WHERE name = 'Press de Banca con Barra'),        4, '3-5',   180, 1),
    (1, (SELECT id FROM exercise WHERE name = 'Remo con Barra'),                4, '3-5',   180, 2),
    (1, (SELECT id FROM exercise WHERE name = 'Press Militar'),             3, '6-8',   120, 3),
    (1, (SELECT id FROM exercise WHERE name = 'Dominadas'),                    3, '6-8',   120, 4),
    (1, (SELECT id FROM exercise WHERE name = 'Press Inclinado con Mancuernas'),     3, '8-12',  90,  5),
    (1, (SELECT id FROM exercise WHERE name = 'Jalón a la Cara'),                  3, '12-15', 60,  6);

-- Ejercicios Lower A (Fuerza)
INSERT INTO routine_exercise (program_day_id, exercise_id, sets_target, reps_target, rest_seconds, order_in_day) VALUES
    (2, (SELECT id FROM exercise WHERE name = 'Sentadilla con Barra'),              4, '3-5',   240, 1),
    (2, (SELECT id FROM exercise WHERE name = 'Peso Muerto Rumano'),          3, '6-8',   180, 2),
    (2, (SELECT id FROM exercise WHERE name = 'Prensa de Piernas'),                  3, '8-12',  120, 3),
    (2, (SELECT id FROM exercise WHERE name = 'Curl Femoral'),                   3, '10-12', 90,  4),
    (2, (SELECT id FROM exercise WHERE name = 'Elevación de Talones de Pie'),        4, '10-15', 60,  5);

-- Ejercicios Upper B (Hipertrofia)
INSERT INTO routine_exercise (program_day_id, exercise_id, sets_target, reps_target, rest_seconds, order_in_day) VALUES
    (3, (SELECT id FROM exercise WHERE name = 'Press Inclinado con Barra'), 4, '8-12',  90,  1),
    (3, (SELECT id FROM exercise WHERE name = 'Jalón al Pecho'),                4, '8-12',  90,  2),
    (3, (SELECT id FROM exercise WHERE name = 'Press de Hombros con Mancuernas'),     3, '10-12', 90,  3),
    (3, (SELECT id FROM exercise WHERE name = 'Remo Sentado en Polea'),            3, '10-12', 90,  4),
    (3, (SELECT id FROM exercise WHERE name = 'Aperturas en Polea'),                   3, '12-15', 60,  5),
    (3, (SELECT id FROM exercise WHERE name = 'Elevaciones Laterales'),               4, '15-20', 45,  6),
    (3, (SELECT id FROM exercise WHERE name = 'Curl con Barra'),                3, '10-12', 60,  7),
    (3, (SELECT id FROM exercise WHERE name = 'Extensión de Tríceps en Polea'),             3, '10-12', 60,  8);

-- Ejercicios Lower B (Hipertrofia)
INSERT INTO routine_exercise (program_day_id, exercise_id, sets_target, reps_target, rest_seconds, order_in_day) VALUES
    (4, (SELECT id FROM exercise WHERE name = 'Sentadilla Búlgara'),      4, '8-12',  120, 1),
    (4, (SELECT id FROM exercise WHERE name = 'Prensa de Piernas'),                  4, '10-15', 90,  2),
    (4, (SELECT id FROM exercise WHERE name = 'Extensión de Piernas'),              3, '12-15', 60,  3),
    (4, (SELECT id FROM exercise WHERE name = 'Curl Femoral'),                   3, '10-12', 60,  4),
    (4, (SELECT id FROM exercise WHERE name = 'Empuje de Cadera'),                 3, '10-12', 90,  5),
    (4, (SELECT id FROM exercise WHERE name = 'Elevación de Talones Sentado'),          4, '12-15', 60,  6);

-- Programa 2: PPL 6-Day
INSERT INTO program (name, description, days_per_week, author) VALUES
    ('Empuje/Tirón/Pierna 6 Días', 'Push/Pull/Legs 6 días por semana. Alta frecuencia y volumen para hipertrofia avanzada.', 6, 'system');

-- Días del PPL 6-Day
INSERT INTO program_day (program_id, name, day_order, focus) VALUES
    (2, 'Empuje A — Fuerza',      1, 'Empuje con énfasis en fuerza (pecho, hombros, tríceps)'),
    (2, 'Tirón A — Fuerza',      2, 'Tirón con énfasis en fuerza (espalda, bíceps)'),
    (2, 'Pierna A — Fuerza',      3, 'Piernas con énfasis en fuerza (cuádriceps dominante)'),
    (2, 'Empuje B — Hipertrofia',   4, 'Empuje con énfasis en hipertrofia'),
    (2, 'Tirón B — Hipertrofia',   5, 'Tirón con énfasis en hipertrofia'),
    (2, 'Pierna B — Hipertrofia',   6, 'Piernas con énfasis en hipertrofia (isquiotibiales dominante)');

-- Programa 3: ULPPL 5-Day
INSERT INTO program (name, description, days_per_week, author) VALUES
    ('Híbrido UL+ETP 5 Días', 'Hybrid Upper/Lower + Push/Pull/Legs. 5 días por semana, balance entre fuerza e hipertrofia.', 5, 'system');

-- Días del ULPPL 5-Day
INSERT INTO program_day (program_id, name, day_order, focus) VALUES
    (3, 'Superior — Fuerza',        1, 'Superior: press y remos pesados'),
    (3, 'Inferior — Fuerza',        2, 'Inferior: sentadilla y peso muerto'),
    (3, 'Empuje — Hipertrofia',      3, 'Empuje: pecho, hombros, tríceps con volumen'),
    (3, 'Tirón — Hipertrofia',      4, 'Tirón: espalda y bíceps con volumen'),
    (3, 'Pierna — Hipertrofia',      5, 'Piernas: cuádriceps e isquiotibiales con volumen');

-- =============================================================================
-- Programa 4 (Artículos y Guías informativas de fitness)
-- =============================================================================
INSERT INTO guide_article (title, slug, category, content_md) VALUES
    ('¿Cómo empezar en el gimnasio? (Guía de Iniciación)', 'como-empezar', 'Principiantes', 
'# ¿Cómo empezar en el gimnasio? (Guía de Iniciación)

¡Bienvenido al entrenamiento de fuerza! Si estás dando tus primeros pasos en el gimnasio, es común sentir incertidumbre o intentar entrenar al fallo de inmediato. Sin embargo, la ciencia deportiva demuestra que el cuerpo requiere una **Fase de Adaptación Anatómica**.

## La Fase de Adaptación Anatómica (2 a 4 semanas)
Antes de buscar levantar el máximo peso posible o hacer entrenamientos exhaustivos, tus músculos, articulaciones, tendones y sistema nervioso deben adaptarse al nuevo estímulo.
- **Cargas bajas a moderadas:** Mantén una intensidad de esfuerzo cómoda (RPE 6-7, sintiendo que te quedan 3 o 4 repeticiones en reserva).
- **Enfoque en la técnica:** Dedica cada serie a aprender el patrón del movimiento (la trayectoria de la barra, la estabilidad del torso y la respiración).
- **Frecuencia:** Entre 3 y 4 días de entrenamiento por semana es ideal para empezar.

## 🏋️ Integración en GymOps
En GymOps, esta fase es libre. Al iniciar tu gimnasio, simplemente usa el CLI para registrar tus primeros levantamientos:
1. Usa `gymops list-programs` para ver los programas prediseñados.
2. Selecciona uno con `gymops select-program`.
3. Al entrenar, registra tus series usando `gymops log --exercise "Sentadilla con Barra" --sets 3 --reps 10 --weight 30`.

No te preocupes por romper récords en tus primeras semanas; tu prioridad número uno es acumular registros consistentes y construir el hábito.'),

    ('¿Cómo elegir mi rutina de entrenamiento?', 'elegir-rutina', 'Planificación',
'# ¿Cómo elegir mi rutina de entrenamiento?

La consistencia es el factor más importante para ganar masa muscular y fuerza. La mejor rutina no es la que promete más ganancias sobre el papel, sino **la que mejor se adapta a tu estilo de vida y horario**.

## Comparativa de Programas por Disponibilidad

### Rutina de 4 Días (Upper/Lower)
- **Estructura:** 2 días de torso (Upper) y 2 días de pierna (Lower) a la semana.
- **Ideal para:** Estudiantes que realizan prácticas pre-profesionales o personas con horarios ocupados. 
- **Ventaja:** Al entrenar solo 4 días, tienes 3 días completos de descanso, facilitando la recuperación y el balance con tu vida académica/laboral.

### Rutina de 5 Días (ULPPL)
- **Estructura:** Torso, Piernas, Empuje, Tirón, Piernas.
- **Ideal para:** Quienes buscan un balance intermedio. Requiere compromiso constante de lunes a viernes.

### Rutina de 6 Días (PPL)
- **Estructura:** Empuje (Push), Tirón (Pull), Piernas (Legs) repetido dos veces.
- **Ideal para:** Estudiantes en sus primeros ciclos de universidad con bastante tiempo libre o vacaciones.
- **Ventaja:** Mayor volumen de entrenamiento semanal. Sin embargo, requiere una excelente gestión del sueño y la nutrición para no sobreentrenarse.

## 🏋️ Integración en GymOps
GymOps viene precargado con splits conocidos y recomendados por su efectividad. Puedes explorarlos y activar el tuyo usando:
- `gymops list-programs` para ver los programas y cuántos días requiere cada uno.
- `gymops select-program "Empuje/Tirón/Pierna 6 Días"` (o el nombre que elijas) para activarlo.
- `gymops set-day` para indicarle a la app en qué sesión estás hoy.'),

    ('¿Cuánto tiempo debo descansar entre series?', 'tiempo-descanso', 'Entrenamiento',
'# ¿Cuánto tiempo debo descansar entre series?

El tiempo de descanso entre series es una variable de entrenamiento frecuentemente subestimada. Muchos creen que descansar poco (menos de 1 minuto) es mejor para quemar grasa o sentir "bombeo", pero la ciencia demuestra lo contrario.

## Tiempos de Descanso Recomendados

### Ejercicios Compuestos (2 a 3+ minutos)
*Ejemplos: Sentadilla, Peso Muerto, Press de Banca, Remos con Barra.*
- Estos ejercicios mueven mucha masa muscular y generan fatiga del sistema nervioso central.
- Necesitas descansar **al menos 2 a 3 minutos** (incluso hasta 4 o 5 minutos si vas muy pesado) para disipar la fatiga y asegurar que puedas rendir con la misma fuerza en la siguiente serie.

### Ejercicios de Aislamiento (1 a 2 minutos)
*Ejemplos: Bicep Curls, Lateral Raises, Extensiones de Tríceps.*
- Trabajan una sola articulación y generan fatiga local, no sistémica.
- Un descanso de **1 a 2 minutos** es más que suficiente para que el músculo se recupere.

*Nota:* No descanses más de 4 o 5 minutos de forma pasiva, ya que puedes comenzar a "enfriarte" y perder concentración.

## 🏋️ Integración en GymOps
Después de ejecutar el comando para guardar tu serie:
`gymops log --exercise "Press de Banca con Barra" --sets 3 --reps 8 --weight 80`

Mira la terminal, respira y pon un cronómetro. Si fue press de banca (compuesto), descansa 3 minutos. Si fue curl de bíceps (aislamiento), descansa 1.5 minutos antes de hacer tu siguiente set.'),

    ('¿Qué es la sobrecarga progresiva y cómo aplicarla?', 'sobrecarga-progresiva', 'Entrenamiento',
'# ¿Qué es la Sobrecarga Progresiva?

El cuerpo humano es una máquina de adaptación extremadamente eficiente. Si levantas los mismos 50 kg para 8 repeticiones todas las semanas, tu cuerpo no tendrá ninguna razón biológica para construir nuevo tejido muscular o volverse más fuerte.

## El Principio de Sobrecarga Progresiva
Consiste en **incrementar gradualmente el estímulo y la tensión mecánica** sobre tus músculos con el tiempo. Puedes lograr esto de varias formas:
1.  **Aumentar el peso:** Levantar 52.5 kg en lugar de 50 kg.
2.  **Aumentar las repeticiones:** Hacer 9 repeticiones con el mismo peso con el que antes solo hacías 8.
3.  **Mejorar la técnica y el control:** Hacer el recorrido más lento y controlado con el mismo peso.
4.  **Aumentar las series:** Pasar de hacer 3 series a hacer 4 series semanales de un ejercicio.

## 🏋️ Integración en GymOps
GymOps fue construido en torno a este principio fundamental:
Cuando completas un entrenamiento de un ejercicio, en tu siguiente sesión puedes ejecutar:
`gymops stats --exercise "Press de Banca con Barra"`

La aplicación comparará el peso y repeticiones de hoy contra los de la última sesión y te calculará tu porcentaje de progreso de fuerza. Si agregaste peso o una repetición extra, verás un cartel verde de **PROGRESSIVE OVERLOAD SUCCESS!** impulsado por el cálculo matemático del 1RM.'),

    ('¿Qué es el 1RM Estimado y la Fórmula de Epley?', 'epley-1rm', 'Teoría / Ciencia',
'# ¿Qué es el 1RM Estimado y la Fórmula de Epley?

El **1RM (One Repetition Maximum)** es el peso máximo absoluto que puedes levantar para una sola repetición en un ejercicio con técnica perfecta. Sin embargo, intentar probar tu 1RM real con frecuencia en ejercicios pesados es peligroso y genera una fatiga neural extrema.

## La Fórmula de Epley
Para evitar este peligro, GymOps estima tu 1RM a través del rendimiento de tus series normales (por ejemplo, calcular tu 1RM basándose en que lograste levantar 80 kg para 8 repeticiones). Para ello, utiliza la **fórmula de Epley**:

$$1RM = Peso \times (1 + Reps/30)$$

*Ejemplo:* Si levantas 100 kg para 5 repeticiones:
$$1RM = 100 \times (1 + 5/30) = 116.6 \text{ kg}$$

Esto te permite saber que tu fuerza máxima teórica es de 116.6 kg, sin necesidad de tener que colocar ese peso real en la barra y arriesgarte a una lesión.

## 🏋️ Integración en GymOps
Esta fórmula es el motor analítico de tu aplicación. 
En PostgreSQL, un trigger llamado `trg_calculate_1rm` se ejecuta inmediatamente después de que insertas una fila en `workout_set`. El trigger toma el peso y las repeticiones, calcula el 1RM estimado y lo escribe en la base de datos automáticamente. Toda tu progresión y récords personales (PRs) mostrados en `gymops prs` se basan en este cálculo matemático en tiempo real.'),

    ('Ejercicios Compuestos vs. Ejercicios de Aislamiento', 'compuestos-vs-aislamiento', 'Entrenamiento',
'# Ejercicios Compuestos vs. de Aislamiento

Para estructurar una rutina de entrenamiento balanceada y efectiva, es necesario entender las diferencias fundamentales entre los dos tipos de movimientos que realizas en el gimnasio.

## Ejercicios Compuestos (Multiarticulares)
*Ejemplos: Sentadillas, Peso Muerto, Press Militar, Press de Banca, Remos, Dominadas.*
- **Definición:** Movimientos que involucran dos o más articulaciones y reclutan varios grupos musculares al mismo tiempo.
- **Propósito:** Son la base de la ganancia de fuerza y masa muscular. Permiten cargar mucho peso y generan una gran respuesta hormonal y neuromuscular.
- **Rango sugerido:** Generalmente de **6 a 10 repeticiones** para un balance óptimo de tensión mecánica.

## Ejercicios de Aislamiento (Uniarticulares)
*Ejemplos: Curl de Bíceps, Extensiones de Tríceps, Elevaciones Laterales, Extensiones de Piernas.*
- **Definición:** Movimientos enfocados en una sola articulación, aislando un músculo específico.
- **Propósito:** Corregir asimetrías musculares, acumular volumen de entrenamiento adicional sin fatigar el sistema nervioso central y buscar el "estrés metabólico".
- **Rango sugerido:** Generalmente de **8 a 12 repeticiones** con pesos moderados.

## 🏋️ Integración en GymOps
GymOps diferencia estos ejercicios de forma nativa:
- Cuando registras un ejercicio en el catálogo con `gymops add-exercise`, debes clasificarlo como `compound` o `isolation`.
- Al crear una rutina personalizada con `gymops add-program` o al registrar una serie con `gymops log`, el CLI de GymOps lee esta clasificación de PostgreSQL y te sugiere los rangos de repeticiones correspondientes (6-10 para compuestos y 8-12 para aislamiento) para asegurar que entrenas de forma óptima.');

-- =============================================================================
-- Verificación del seed
-- =============================================================================
SELECT 'muscle_group'   AS tabla, COUNT(*) AS registros FROM muscle_group
UNION ALL
SELECT 'exercise',       COUNT(*) FROM exercise
UNION ALL
SELECT 'program',        COUNT(*) FROM program
UNION ALL
SELECT 'program_day',    COUNT(*) FROM program_day
UNION ALL
SELECT 'routine_exercise', COUNT(*) FROM routine_exercise
UNION ALL
SELECT 'guide_article',  COUNT(*) FROM guide_article
ORDER BY tabla;
