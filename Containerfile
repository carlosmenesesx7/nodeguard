FROM python:3.11-slim

WORKDIR /app

# Instalar kubectl
RUN apt-get update && apt-get install -y curl && \
    curl -LO "https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

COPY collector.py .

RUN pip install --no-cache-dir requests

CMD ["python", "collector.py"]
