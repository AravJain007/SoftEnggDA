FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Create static directory if it doesn't exist
RUN mkdir -p static
# Create data directory for persistent storage
RUN mkdir -p data && chmod 777 data

# Copy static files
COPY static/ ./static/

# Copy Python code
COPY app.py .

EXPOSE 8501

CMD ["python", "app.py"] 