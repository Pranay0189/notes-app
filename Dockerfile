# =========================
# Base image
# =========================
FROM python:3.9-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app/backend

# =========================
# Builder stage
# =========================
FROM base AS builder

# System dependencies required to build mysqlclient
RUN apt-get update && apt-get install -y \
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --upgrade pip \
    && pip install --prefix=/install --no-cache-dir -r requirements.txt

# =========================
# Runtime stage
# =========================
FROM base AS runtime

# Runtime-only system dependencies
RUN apt-get update && apt-get install -y \
    default-libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy Python dependencies from builder
COPY --from=builder /install /usr/local

# Copy application source
COPY . .

# Create non-root user (recommended)
RUN addgroup --system django \
    && adduser --system --ingroup django django \
    && chown -R django:django /app

USER django

EXPOSE 8000

CMD ["gunicorn", "notesapp.wsgi:application", "--bind", "0.0.0.0:8000"]
