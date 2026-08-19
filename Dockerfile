# syntax=docker/dockerfile:1
FROM python:3.12-slim

# Set environment variables for Python and GymOps
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    GYMOPS_DB_HOST=db \
    GYMOPS_DB_PORT=5432 \
    GYMOPS_DB_USER=gymops \
    GYMOPS_DB_PASSWORD=gymops_pass \
    GYMOPS_DB_NAME=gymops_db

WORKDIR /app

# Install uv from official image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Copy project specification files
COPY pyproject.toml uv.lock README.md ./

# Copy application source code and SQL assets
COPY gymops/ gymops/
COPY proyecto_bdII/ proyecto_bdII/

# Install the application and dependencies using uv in system Python
RUN uv pip install --system --no-cache -e .

# CLI entrypoint
ENTRYPOINT ["gymops"]
CMD ["--help"]
