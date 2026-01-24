FROM python:3.13-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Create supervisord configuration
RUN echo '[supervisord]\n\
nodaemon=true\n\
logfile=/dev/null\n\
logfile_maxbytes=0\n\
\n\
[program:backend]\n\
command=uv run uvicorn backend.main:app --host 0.0.0.0 --port 8000\n\
directory=/app\n\
user=user\n\
autostart=true\n\
autorestart=true\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n\
\n\
[program:frontend]\n\
command=uv run streamlit run frontend/app.py --server.port=7860 --server.address=0.0.0.0\n\
directory=/app\n\
user=user\n\
autostart=true\n\
autorestart=true\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n\
' > /etc/supervisord.conf

RUN useradd -m -u 1000 user
USER user
ENV PATH="/home/user/.local/bin:$PATH"

# Install uv.
COPY --from=ghcr.io/astral-sh/uv:0.9.18 /uv /uvx /bin/

# Copy the application into the container.
COPY --chown=user . /app

# Install the application dependencies.
WORKDIR /app
ENV UV_HTTP_TIMEOUT=6000

RUN uv sync

# Expose both ports (7860 is required for HF Spaces)
EXPOSE 7860 8000

# Health check on frontend
HEALTHCHECK CMD curl --fail http://localhost:7860/_stcore/health || exit 1

# Run supervisord to manage both services
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]