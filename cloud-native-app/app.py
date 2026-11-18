from flask import Flask, jsonify, render_template_string
import os
import socket
import datetime

app = Flask(__name__)

START_TIME = datetime.datetime.now()

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShalaConnect | Cloud-Native School Management Portal</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
        body { background: #f8fafc; color: #1e293b; min-height: 100vh; display: flex; flex-direction: column; }
        header { background: #ffffff; border-bottom: 1px solid #e2e8f0; padding: 16px 32px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
        .logo-group { display: flex; align-items: center; gap: 12px; }
        .logo-icon { width: 40px; height: 40px; background: #2563eb; color: #ffffff; border-radius: 8px; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 1.2rem; }
        .logo-title { font-size: 1.25rem; font-weight: 700; color: #0f172a; }
        .badge { background: #e0f2fe; color: #0284c7; padding: 4px 10px; border-radius: 6px; font-size: 0.75rem; font-weight: 600; text-transform: uppercase; }
        main { flex: 1; max-width: 1100px; width: 100%; margin: 32px auto; padding: 0 20px; }
        .hero { margin-bottom: 24px; }
        .hero h2 { font-size: 1.5rem; color: #0f172a; margin-bottom: 6px; }
        .hero p { color: #64748b; font-size: 0.95rem; }
        .grid-k8s { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 28px; }
        .card { background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.02); }
        .card-label { font-size: 0.75rem; font-weight: 600; text-transform: uppercase; color: #64748b; letter-spacing: 0.05em; margin-bottom: 6px; }
        .card-value { font-size: 1.05rem; font-weight: 700; color: #0f172a; word-break: break-all; }
        .highlight-pod { color: #2563eb; font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace; }
        .status-badge { display: inline-flex; align-items: center; gap: 6px; color: #16a34a; font-weight: 600; font-size: 0.9rem; }
        .status-dot { width: 8px; height: 8px; background: #16a34a; border-radius: 50%; display: inline-block; box-shadow: 0 0 8px #16a34a; }
        .section-title { font-size: 1.15rem; font-weight: 700; margin-bottom: 16px; color: #0f172a; }
        .stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 28px; }
        .stat-card { background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 20px; }
        .stat-num { font-size: 1.8rem; font-weight: 800; color: #2563eb; margin-bottom: 4px; }
        .stat-desc { color: #64748b; font-size: 0.85rem; }
        table { width: 100%; border-collapse: collapse; background: #ffffff; border-radius: 12px; overflow: hidden; border: 1px solid #e2e8f0; }
        th, td { padding: 12px 16px; text-align: left; border-bottom: 1px solid #f1f5f9; font-size: 0.9rem; }
        th { background: #f8fafc; font-weight: 600; color: #475569; }
        footer { border-top: 1px solid #e2e8f0; padding: 20px; text-align: center; color: #94a3b8; font-size: 0.85rem; background: #ffffff; }
    </style>
</head>
<body>
    <header>
        <div class="logo-group">
            <div class="logo-icon">SC</div>
            <div>
                <div class="logo-title">ShalaConnect</div>
                <div style="font-size: 0.75rem; color: #64748b;">School Management Cloud-Native Service</div>
            </div>
        </div>
        <div>
            <span class="badge">v1.0 - Kubernetes</span>
        </div>
    </header>

    <main>
        <div class="hero">
            <h2>Cloud-Native Application Dashboard</h2>
            <p>Containerized with Docker and orchestrated using Kubernetes Deployment &amp; NodePort Service.</p>
        </div>

        <div class="grid-k8s">
            <div class="card">
                <div class="card-label">Pod / Container Hostname</div>
                <div class="card-value highlight-pod">{{ hostname }}</div>
            </div>
            <div class="card">
                <div class="card-label">Server IP Address</div>
                <div class="card-value">{{ ip_address }}</div>
            </div>
            <div class="card">
                <div class="card-label">Health Probe Status</div>
                <div class="card-value status-badge"><span class="status-dot"></span> 200 OK (Healthy)</div>
            </div>
            <div class="card">
                <div class="card-label">Cluster Uptime</div>
                <div class="card-value">{{ uptime }}</div>
            </div>
        </div>

        <div class="section-title">School Telemetry &amp; System Overview</div>
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-num">1,240</div>
                <div class="stat-desc">Enrolled Students Across 12 Divisions</div>
            </div>
            <div class="stat-card">
                <div class="stat-num">98.4%</div>
                <div class="stat-desc">Average Daily Attendance</div>
            </div>
            <div class="stat-card">
                <div class="stat-num">54</div>
                <div class="stat-desc">Active Certified Faculty &amp; Staff</div>
            </div>
        </div>

        <div class="section-title">Connected Academic Modules</div>
        <table>
            <thead>
                <tr>
                    <th>Module</th>
                    <th>Status</th>
                    <th>Target Port</th>
                    <th>Protocol</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>Student Attendance Service</strong></td>
                    <td><span class="status-badge"><span class="status-dot"></span> Active</span></td>
                    <td>5000</td>
                    <td>HTTP / REST</td>
                </tr>
                <tr>
                    <td><strong>Teacher &amp; Staff Administration</strong></td>
                    <td><span class="status-badge"><span class="status-dot"></span> Active</span></td>
                    <td>5000</td>
                    <td>HTTP / REST</td>
                </tr>
                <tr>
                    <td><strong>Cluster Health Telemetry (/health)</strong></td>
                    <td><span class="status-badge"><span class="status-dot"></span> Passing</span></td>
                    <td>5000</td>
                    <td>Liveness / Readiness Probe</td>
                </tr>
            </tbody>
        </table>
    </main>

    <footer>
        ShalaConnect | DevOps &amp; Cloud-Native Engineering Assignment | MIT Academy of Engineering, Pune
    </footer>
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
    
    return render_template_string(
        HTML_TEMPLATE,
        hostname=hostname,
        ip_address=ip_address,
        uptime=uptime
    )

@app.route("/health")
@app.route("/healthz")
def health():
    return jsonify({
        "status": "healthy",
        "service": "shalaconnect-app",
        "hostname": socket.gethostname(),
        "timestamp": datetime.datetime.now().isoformat()
    }), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
