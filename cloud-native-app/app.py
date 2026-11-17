from flask import Flask, jsonify, render_template_string
import os
import socket
import datetime

app = Flask(__name__)

# Track start time for uptime calculation
START_TIME = datetime.datetime.now()

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cloud-Native App | Kubernetes & Docker</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%); color: #f8fafc; min-height: 100vh; display: flex; justify-content: center; align-items: center; padding: 20px; }
        .container { background: rgba(30, 41, 59, 0.85); border: 1px solid #334155; border-radius: 16px; padding: 32px; max-width: 650px; width: 100%; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.5), 0 8px 10px -6px rgba(0, 0, 0, 0.5); backdrop-filter: blur(12px); }
        .header { display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #334155; padding-bottom: 20px; margin-bottom: 24px; }
        .header h1 { font-size: 1.5rem; color: #38bdf8; display: flex; align-items: center; gap: 10px; }
        .badge { background: #0284c7; color: white; padding: 4px 12px; border-radius: 9999px; font-size: 0.8rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; }
        .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 24px; }
        .card { background: #0f172a; border: 1px solid #1e293b; border-radius: 10px; padding: 16px; }
        .card-label { font-size: 0.75rem; text-transform: uppercase; color: #94a3b8; letter-spacing: 0.05em; margin-bottom: 6px; }
        .card-value { font-size: 1rem; font-weight: 600; color: #f1f5f9; word-break: break-all; }
        .status-healthy { color: #4ade80; display: inline-flex; align-items: center; gap: 6px; }
        .status-healthy::before { content: ""; display: inline-block; width: 10px; height: 10px; border-radius: 50%; background: #4ade80; box-shadow: 0 0 12px #4ade80; }
        .footer { text-align: center; color: #64748b; font-size: 0.85rem; border-top: 1px solid #334155; padding-top: 16px; }
        .pod-highlight { color: #fbbf24; font-family: 'Courier New', Courier, monospace; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 Cloud-Native App</h1>
            <span class="badge">v1.0.0</span>
        </div>
        
        <div class="grid">
            <div class="card">
                <div class="card-label">Pod / Container Hostname</div>
                <div class="card-value pod-highlight">{{ hostname }}</div>
            </div>
            <div class="card">
                <div class="card-label">Server IP Address</div>
                <div class="card-value">{{ ip_address }}</div>
            </div>
            <div class="card">
                <div class="card-label">Application Status</div>
                <div class="card-value status-healthy">Healthy & Running</div>
            </div>
            <div class="card">
                <div class="card-label">Environment</div>
                <div class="card-value">{{ environment }}</div>
            </div>
        </div>

        <div class="card" style="margin-bottom: 24px;">
            <div class="card-label">Server Uptime</div>
            <div class="card-value" id="uptime">{{ uptime }}</div>
        </div>

        <div class="footer">
            Containerized with Docker &amp; Orchestrated with Kubernetes
        </div>
    </div>
</body>
</html>
"""

@app.route("/")
def home():
    hostname = socket.gethostname()
    try:
        ip_address = socket.gethostbyname(hostname)
    except Exception:
        ip_address = "127.0.0.1"
    
    uptime = str(datetime.datetime.now() - START_TIME).split(".")[0]
    environment = os.getenv("APP_ENV", "production")
    
    return render_template_string(
        HTML_TEMPLATE,
        hostname=hostname,
        ip_address=ip_address,
        uptime=uptime,
        environment=environment
    )

@app.route("/healthz")
def healthz():
    return jsonify({
        "status": "healthy",
        "hostname": socket.gethostname(),
        "timestamp": datetime.datetime.now().isoformat()
    }), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
