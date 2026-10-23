# ---------- Stage 1: install the packages ----------
FROM python:3.13-slim AS builder
# Start from an official, small Python image. "AS builder" names this stage.

WORKDIR /app
# Work inside /app (created automatically). Like "cd /app".

COPY requirements.txt .
# Copy ONLY the requirements first (see "layer caching" below).

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt
# Install the packages into /install. --no-cache-dir keeps the image smaller.


# ---------- Stage 2: the image that actually runs ----------
FROM python:3.13-slim
# A fresh, clean image. Nothing from stage 1 comes along unless we copy it.

WORKDIR /app

COPY --from=builder /install /usr/local
# Take only the installed packages from stage 1.

COPY app/ ./app/
# Now copy your code.

RUN useradd --create-home appuser
USER appuser
# Create a normal user and switch to it, so the app doesn't run as root.

EXPOSE 8000
# Documents the port the app listens on.

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
# The command that runs when the container starts.