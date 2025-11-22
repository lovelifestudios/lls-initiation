FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .
COPY templates/ templates/

# KEEP: This is the internal container port. AWS handles external mapping.
EXPOSE 8080

ENV FLASK_HOST=0.0.0.0
ENV FLASK_PORT=8080

# CRITICAL CHANGE: Use Gunicorn for production
# Assumes: Your Flask app instance is named 'app' in 'app.py'
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
