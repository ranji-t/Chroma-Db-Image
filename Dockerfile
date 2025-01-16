# syntax=docker/dockerfile:1

ARG PYTHON_VERSION=3.13.1
# FROM python:${PYTHON_VERSION}-alpine AS base
FROM python:${PYTHON_VERSION}-slim AS base

# Prevents Python from writing pyc files.
ENV PYTHONDONTWRITEBYTECODE=1

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Download dependencies as a separate step to take advantage of Docker's caching.
# Leverage a cache mount to /root/.cache/pip to speed up subsequent builds.
# Leverage a bind mount to requirements.txt to avoid having to copy them into
# into this layer.
RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=requirements.txt,target=requirements.txt \
    apt-get update && apt-get install -y build-essential \
    # apk add --no-cache g++ make \ # For Alpine Images
    && python -m pip install --no-cache-dir -r requirements.txt

# Copy the source code into the container.
COPY . .

# Expose the port that the application listens on.
EXPOSE 8000

ENV ANONYMIZED_TELEMETRY=false

# Run the application.
CMD ["chroma", "run", "--path", "./chroma_data", "--host", "0.0.0.0", "--port", "8765", "--log-path", "./chroma_log/chroma.log"]
