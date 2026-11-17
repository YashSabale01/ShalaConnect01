# Stage 1: Build & Runtime using official lightweight Python image
FROM python:3.11-slim

# Set environment variables for Python performance & container reliability
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_ENV=production \
    PORT=5000

# Set working directory
WORKDIR /app

# Install system security updates & create non-root user for security best practice
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -u 1000 appuser

# Copy dependency manifest first to leverage Docker layer caching
COPY requirements.txt .

# Install dependencies without cache to minimize image size
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source code
COPY app.py .

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose internal application port
EXPOSE 5000

# Define container health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/healthz || exit 1

# Execute the application
CMD ["python", "app.py"]
