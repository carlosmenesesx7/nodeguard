import subprocess
import requests
import time
import os
import datetime
import re
import logging
import sys
import argparse
import yaml

VERSION = "1.1.0"

DEFAULT_CONFIG_PATH = os.path.expanduser("~/.nodeguard.yaml")

# ---------------- CLI ----------------
def parse_args():
    parser = argparse.ArgumentParser(
        description="🚀 NodeGuard - Kubernetes Node Monitor"
    )

    parser.add_argument("--version", action="store_true", help="Mostrar versión")
    parser.add_argument("--once", action="store_true", help="Ejecutar una sola vez")
    parser.add_argument("--debug", action="store_true", help="Logs detallados")
    parser.add_argument("--config", help="Ruta al archivo config.yaml")

    return parser.parse_args()

# ---------------- CONFIG ----------------
def cargar_config(path):
    if not os.path.exists(path):
        logging.warning(f"No se encontró config.yaml en {path}")
        return {}

    with open(path, "r") as f:
        return yaml.safe_load(f) or {}

def obtener_config(args):
    config_path = args.config or DEFAULT_CONFIG_PATH
    file_config = cargar_config(config_path)

    return {
        "api_key": os.getenv("API_KEY") or file_config.get("api_key"),
        "api_url": os.getenv("API_URL") or file_config.get("api_url"),
        "check_interval": int(os.getenv("CHECK_INTERVAL") or file_config.get("check_interval", 300)),
        "threshold": int(os.getenv("THRESHOLD") or file_config.get("threshold", 95)),
        "clusters": file_config.get("clusters", [])
    }

# ---------------- LOGGING ----------------
def setup_logging(debug=False):
    level = logging.DEBUG if debug else logging.INFO
    logging.basicConfig(level=level, format="%(asctime)s | %(levelname)s | %(message)s")

# ---------------- KUBECTL ----------------
def obtener_top_nodes(context):
    try:
        cmd = ["kubectl", f"--context={context}", "top", "nodes"]
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError:
        logging.error(f"[{context}] Error ejecutando kubectl")
        return None
    except FileNotFoundError:
        logging.error("❌ kubectl no está instalado")
        sys.exit(1)

# ---------------- PARSER ----------------
def parsear_top_nodes(output, threshold):
    nodos = []
    lines = output.strip().split("\n")

    for line in lines[1:]:
        parts = re.split(r'\s+', line)
        if len(parts) < 5:
            continue

        try:
            cpu = int(parts[2].replace("%", ""))
            mem = int(parts[4].replace("%", ""))

            nodos.append({
                "name": parts[0],
                "cpu": cpu,
                "mem": mem,
                "alert": cpu > threshold or mem > threshold
            })
        except:
            continue

    return nodos

# ---------------- API ----------------
def enviar_metricas(cluster_name, nodes, api_url, api_key):
    if not api_url or not api_key:
        logging.debug("Modo local: no se envían métricas")
        return

    payload = {
        "cluster": cluster_name,
        "nodes": nodes,
        "timestamp": datetime.datetime.utcnow().isoformat()
    }

    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }

    try:
        resp = requests.post(api_url, json=payload, headers=headers, timeout=5)

        if 200 <= resp.status_code < 300:
            logging.info(f"[{cluster_name}] ✅ Métricas enviadas")
        else:
            logging.error(f"[{cluster_name}] ❌ Error {resp.status_code}")
    except Exception:
        logging.error(f"[{cluster_name}] ❌ Error enviando métricas")

# ---------------- EJECUCIÓN ----------------
def ejecutar(config, once=False):
    logging.info(f"🚀 NodeGuard v{VERSION} iniciado")

    clusters = config["clusters"]

    if not clusters:
        logging.error("❌ No hay clusters definidos en config.yaml")
        return

    while True:
        for cluster in clusters:
            logging.info(f"🔍 Cluster: {cluster['name']}")

            output = obtener_top_nodes(cluster["context"])

            if output:
                nodes = parsear_top_nodes(output, config["threshold"])

                if nodes:
                    enviar_metricas(
                        cluster["name"],
                        nodes,
                        config["api_url"],
                        config["api_key"]
                    )
                else:
                    logging.warning("⚠️ Sin datos")

        if once:
            break

        time.sleep(config["check_interval"])

# ---------------- MAIN ----------------
def main():
    args = parse_args()

    if args.version:
        print(f"NodeGuard v{VERSION}")
        return

    setup_logging(args.debug)

    config = obtener_config(args)

    if not config["api_key"]:
        logging.warning("⚠️ API_KEY no definida")

    if not config["api_url"]:
        logging.warning("⚠️ API_URL no definida")

    ejecutar(config, once=args.once)

if __name__ == "__main__":
    main()
