# --- Stage 1: build Tailwind CSS ---
FROM node:20-alpine AS cssbuilder
WORKDIR /app

# Install JS deps (best cache behavior)
COPY package.json package-lock.json ./
RUN npm ci

# Copy only what Tailwind needs to scan/build
COPY tailwind.config.js postcss.config.js ./
COPY static/src ./static/src
COPY templates ./templates

# Build the compiled CSS output
RUN npm run build:css


# --- Stage 2: Python runtime (your original image) ---
FROM python:3.11-slim
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Ensure the compiled CSS is present in the runtime image
COPY --from=cssbuilder /app/static/css/tailwind.css ./static/css/tailwind.css

EXPOSE 8080
ENV FLASK_HOST=0.0.0.0
ENV FLASK_PORT=8080
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
