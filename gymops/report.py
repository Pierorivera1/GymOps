"""
GymOps report generator.

Generates the weekly CI Workout Digest as a Markdown file.
This file is published as a GitHub Actions artifact named 'ci-workout-digest'.
"""

from datetime import date, timedelta
from pathlib import Path

from gymops.db import (
    get_all_prs,
    get_weekly_digest_sp,
    get_weekly_digest_stats,
    get_weekly_digest_view,
)


def generate_digest(days: int = 7, output_dir: Path = Path(".")) -> str:
    """
    Generate a Markdown digest of recent workout activity using database views.

    Scans the last N days of workout history using database views, counts total sets logged,
    lists new/updated PRs during the period, and writes a Markdown file.

    Args:
        days: Number of days to include in the digest window.
        output_dir: Directory where the digest file will be written.

    Returns:
        The filename of the generated digest (e.g., 'digest_2026-06-22.md').
    """
    today = date.today()
    since = today - timedelta(days=days)
    filename = f"digest_{today.isoformat()}.md"
    output_path = output_dir / filename

    stats = get_weekly_digest_stats(days=days)
    all_prs = get_all_prs()

    total_sets = sum(item["sets_logged"] for item in stats)
    exercises_count = len(stats)

    # Build the Markdown content
    lines: list[str] = [
        "# GymOps · Resumen de Entrenamiento CI",
        "",
        (
            f"**Período:** {since.isoformat()} → "
            f"{today.isoformat()} ({days} días)  "
        ),
        f"**Series Registradas:** {total_sets}  ",
        f"**Ejercicios Entrenados:** {exercises_count}  ",
        "",
        "---",
        "",
        "## 📊 Resumen de Entrenamiento",
        "",
        "| Ejercicio | Series | Mejor Peso (kg) | Mejor 1RM Est. (kg) |",
        "|:----------|-------:|----------------:|--------------------:|",
    ]

    for item in stats:
        lines.append(
            f"| {item['exercise_name']} | {item['sets_logged']} | {item['best_weight']:.1f} | {item['best_1rm']:.1f} |"
        )

    # Weekly per-muscle summary (stored procedure sp_weekly_digest)
    muscle_week = get_weekly_digest_sp()
    lines += [
        "",
        "---",
        "",
        "## 💪 Esta Semana por Grupo Muscular",
        "",
    ]
    if muscle_week:
        lines += [
            "| Músculo | Sesiones | Series | Volumen (kg) | PRs | Mejor Ejercicio |",
            "|:--------|---------:|-------:|-------------:|----:|:----------------|",
        ]
        for m in muscle_week:
            lines.append(
                f"| {m['muscle_group']} | {m['sessions_count']} | {m['total_sets']} | "
                f"{float(m['total_volume_kg']):.1f} | {m['prs_in_week']} | {m['top_exercise'] or '—'} |"
            )
    else:
        lines.append("_Sin sesiones cerradas esta semana._")

    # Recent weeks overview (view v_weekly_digest)
    recent_weeks = get_weekly_digest_view(weeks=4)
    lines += [
        "",
        "---",
        "",
        "## 📅 Resumen de Semanas Recientes",
        "",
    ]
    if recent_weeks:
        lines += [
            "| Semana | Músculo | Series | Volumen (kg) | Mejor 1RM (kg) | PRs |",
            "|:-------|:--------|-------:|-------------:|---------------:|----:|",
        ]
        for w in recent_weeks:
            lines.append(
                f"| {w['semana_inicio']} | {w['musculo']} | {w['total_series']} | "
                f"{float(w['volumen_kg']):.1f} | {float(w['mejor_1rm_semana']):.1f} | {w['prs_semana']} |"
            )
    else:
        lines.append("_Sin datos de entrenamiento en las últimas 4 semanas._")

    lines += [
        "",
        "---",
        "",
        "## 🏆 Récords Personales",
        "",
    ]

    if all_prs:
        lines += [
            "| Ejercicio | Peso Máx (kg) | 1RM Est. (kg) | Fecha |",
            "|:----------|--------------:|--------------:|------:|",
        ]
        for pr in all_prs:
            lines.append(
                f"| {pr.exercise_name} | {pr.max_weight:.1f} | "
                f"{pr.max_epley_1rm:.1f} | {str(pr.timestamp)[:10]} |"
            )
    else:
        lines.append("_Aún no se han establecido récords personales._")

    lines += [
        "",
        "---",
        "",
        f"_Generado por GymOps el {today.isoformat()}_",
    ]

    output_path.write_text("\n".join(lines), encoding="utf-8")
    return filename
