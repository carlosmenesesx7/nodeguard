#!/usr/bin/env python3
import os
import subprocess
import re
import time
import datetime
import requests

# Leer configuración del cliente
API_KEY = os.getenv("API_KEY")
API_URL = os.getenv("API_URL")
CHECK_INTERVAL = int(os.getenv("CHECK_INTERVAL", "300"))

# Leer clusters desde .env
CLUSTERS = []
clusters_str = os.getenv("CLUSTERS", "")
for c in clusters_str.split(","):
    if ":" in c:
        name, context = c.split(":")
        CLUSTERS.append({"name": name.strip(), "context": context.strip()})

# Función para obtener top nodes
def obtener_top_nodes(context):
    try:
        cmd = f"kubectl --context={context} top nodes"
        salida = subprocess.check_output(cmd, shell=True, text=True)
        return salida
    except subprocess.CalledProcessError:
        return None

# Parsear output de kubectl top nodes
def parsear_top_nodes(output):
    nodos = []
    lines = output.strip().split("\n")
    if len(lines) < 2:
        return nodos
    for line in lines[1:]:
        parts = re.split(r'\s+', line)
        if len(parts) < 5:
            continue
        try:
            nodos.append({
                "name": parts[0],
                "cpu": int(parts[2].replace("%", "")),
                "mem": int(parts[4].replace("%", ""))
            })
        except:
            continue
    return nodos

# Enviar métricas a API
def enviar_metricas(cluster_name, nodes):
    payload = {
        "cluster": cluster_name,
        "nodes": nodes,
        "timestamp": datetime.datetime.utcnow().isoformat()
    }
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    try:
        resp = requests.post(API_URL, json=payload, headers=headers, timeout=5)
        print(f"{cluster_name} - Status: {resp.status_code}")
    except Exception as e:
        print(f"Error enviando métricas: {e}")

# Loop principal
def main():
    print("🚀 NodeGuard iniciado...")
    if not CLUSTERS:
        print("⚠️ No se detectaron clusters. Verifica tu archivo .nodeguard.env")
        return

    while True:
        for cluster in CLUSTERS:
            output = obtener_top_nodes(cluster["context"])
            if output:
                nodes = parsear_top_nodes(output)
                enviar_metricas(cluster["name"], nodes)
        time.sleep(CHECK_INTERVAL)

if __name__ == "__main__":
    main()
