FROM python:3.12-slim
WORKDIR /app
COPY main.py requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
ENV API_URL=https://api.tusaas.com/metrics
ENV API_KEY=changeme
ENV CHECK_INTERVAL=300
CMD ["python", "main.py"]
