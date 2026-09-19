# =========================
# Stage 1: Builder
# =========================
FROM python:3.12-alpine AS builder
WORKDIR /app

# Create virtual environment
RUN python -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt


# =========================
# Stage 2: Production
# =========================
FROM python:3.12-alpine AS production
WORKDIR /app

# Create non-root user
RUN adduser -D -s /bin/sh appuser
# Copy installed packages from builder
COPY --from=builder /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

# Copy application files
COPY app.py .
COPY templates ./templates

# Give application ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch from root to non-root user
USER appuser

EXPOSE 5000

# Container health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# Production server
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]