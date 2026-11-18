# CONTAINERIZATION & KUBERNETES DEPLOYMENT
## SHALACONNECT – SCHOOL MANAGEMENT PORTAL

| Field | Details |
| :--- | :--- |
| **Student Name** | Yash Sabale |
| **Program / Branch** | B.Tech – Computer Engineering |
| **Institute** | MIT Academy of Engineering, Pune |
| **Academic Year** | 2026–2027 |
| **Submission Date** | 17 November 2026 |

---

### Abstract
This project demonstrates the containerization and Kubernetes deployment of **ShalaConnect**, a cloud-native school management web microservice. The application was packaged into a Docker image named `shalaconnect:1.0`, executed as a standalone Docker container, and then deployed to a single-node Kubernetes cluster provided by Docker Desktop using the kind provisioning method. A Kubernetes Deployment manages the application Pod, while a NodePort Service exposes the application on port 30080 inside the cluster. During verification, direct access through the NodePort on localhost was refused in this Docker Desktop kind environment. The application was successfully accessed using `kubectl port-forward` from `localhost:8080` to the Service port `5000`.

---

### 1. Introduction
Containerization packages an application together with its runtime dependencies so that it can run consistently across environments. Docker provides the image and container runtime workflow. Kubernetes provides orchestration capabilities such as Deployments, Pods, Services, health checks, and desired-state management.

---

### 2. Project Objectives
- Create and run a Flask-based ShalaConnect school management application.
- Create a Docker image using a Dockerfile and build the image locally.
- Run the application as a Docker container and verify browser access.
- Enable a Kubernetes cluster through Docker Desktop.
- Deploy the Docker image using a Kubernetes Deployment manifest.
- Expose the application through a Kubernetes NodePort Service.
- Verify Pods, Deployments, Services, logs, endpoints, and application access.

---

### 3. Application Overview
ShalaConnect is an integrated school management portal designed for recording and monitoring academic telemetry, student attendance records, faculty administration, and cluster health. The interface includes an executive dashboard, attendance metrics, active module status, and cluster telemetry. The project uses Python with Flask for the web application, clean responsive HTML/CSS for the user interface, and standard REST endpoints.

Main application routes include:
- `/` (Executive Dashboard with Pod hostname, IP, uptime, and academic metrics)
- `/health` (Health probe endpoint for Kubernetes liveness & readiness checks)

---

### 4. Technology Stack and Environment

| Component | Technology / Value |
| :--- | :--- |
| **Operating system** | Microsoft Windows 11 |
| **Application framework** | Python 3.11 / Flask 3.0.3 |
| **Container platform** | Docker Desktop 29.9.3 |
| **Docker image** | `shalaconnect:1.0` |
| **Kubernetes** | Docker Desktop Kubernetes, kind, v1.36.1 |
| **Kubernetes workload** | Deployment: `shalaconnect`; one replica |
| **Kubernetes service** | `shalaconnect-service`; NodePort 30080 → targetPort 5000 |
| **Application port** | 5000 |
| **Kubernetes access used**| `kubectl port-forward localhost:8080 → Service port 5000` |

---

### 5. Project Structure
The project directory is `D:\devops assignments\shalaconect01\cloud-native-app`. The Kubernetes manifests are stored in the `k8s` subfolder. The main files used for deployment are:
- `app.py` – Flask application entry point and route definitions.
- `requirements.txt` – Python package dependencies (`flask==3.0.3`).
- `Dockerfile` – Instructions to build the application container image.
- `.dockerignore` – Files and folders excluded from the Docker build context.
- `k8s/deployment.yaml` – Kubernetes Deployment definition.
- `k8s/service.yaml` – Kubernetes NodePort Service definition.

---

### 6. Docker Containerization

#### 6.1 Dockerfile
```dockerfile
FROM python:3.11-slim
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["python", "app.py"]
```
The Dockerfile selects a lightweight Python base image (`python:3.11-slim`), sets `/app` as the working directory, installs the requirements, copies the application source, exposes port 5000, and starts the Flask application with `python app.py`.

#### 6.2 Build the Docker Image
The image was built from `D:\devops assignments\shalaconect01\cloud-native-app` with:
```powershell
docker build -t shalaconnect:1.0 .
```

#### 6.3 Run and Verify the Container
```powershell
docker run -d --name shalaconnect-container -p 5000:5000 shalaconnect:1.0
docker ps
```
The running container was named `shalaconnect-container`. Docker mapped host port 5000 to container port 5000. The application was verified in a browser at `http://localhost:5000`.

---

### 7. Kubernetes Cluster Setup
Kubernetes was enabled in Docker Desktop. The selected provisioning method was kind, with one node and Kubernetes version 1.36.1. The cluster was verified using the following commands:
```powershell
kubectl version --client
kubectl get nodes
```
The node `desktop-control-plane` reported status `Ready`.

---

### 8. Kubernetes Deployment
The Deployment manifest defines the ShalaConnect workload and requests one replica using the locally built image `shalaconnect:1.0`. The manifest also configures the application container port and health probes on the `/health` endpoint. The Deployment was applied with:
```powershell
kubectl apply -f k8s\deployment.yaml
```
The Deployment and Pod were verified using:
```powershell
kubectl get deployments
kubectl get pods
```
The observed result was Deployment `shalaconnect` with 1/1 ready replica and a Pod in `Running` state with 1/1 readiness and zero restarts.

---

### 9. Kubernetes Service
The NodePort Service manifest was applied using:
```powershell
kubectl apply -f k8s\service.yaml
```
The service name is `shalaconnect-service`. Its Service port is 5000, targetPort is 5000, and NodePort is 30080.
```powershell
kubectl get services
kubectl describe service shalaconnect-service
```

---

### 10. Verification and Troubleshooting
The Pod was Running and the Service endpoint was populated. Flask logs confirmed that the application listened on all addresses (`0.0.0.0`) and that Kubernetes health checks to `/health` returned HTTP 200. In this Docker Desktop kind environment, browsing directly to `http://localhost:30080` returned `ERR_CONNECTION_REFUSED` because the kind node container runs inside Docker without direct host port forwarding.

To verify application access without changing the manifests, `kubectl port-forward` was used:
```powershell
kubectl port-forward service/shalaconnect-service 8080:5000
```
The terminal reported forwarding from `127.0.0.1:8080` to Service port `5000`. The ShalaConnect dashboard then opened successfully at `http://localhost:8080`.

---

### 11. Final Verification Commands
```powershell
kubectl get all
kubectl get pods -o wide
kubectl get services
kubectl logs deployment/shalaconnect
kubectl describe service shalaconnect-service
```

---

### 12. Results
- The ShalaConnect application was packaged into a Docker image successfully.
- The Docker container ran and served the application through host port 5000.
- A one-node Kubernetes cluster was enabled and reported Ready.
- The Kubernetes Deployment, Pod, ReplicaSet, and NodePort Service were created successfully.
- The application was accessed through Kubernetes using `kubectl port-forward` at `localhost:8080`.

---

### 13. Conclusion
The assignment demonstrated the complete workflow from a local Flask application to a Docker container and a Kubernetes-managed workload. Docker provided a repeatable image and container execution environment. Kubernetes managed the application Pod through a Deployment and exposed it through a Service. The final browser test through `kubectl port-forward` confirmed that the application was accessible from the Kubernetes workload.

---

### 14. Submission Notes
- **GitHub Repository URL**: [https://github.com/YashSabale01/ShalaConnect01](https://github.com/YashSabale01/ShalaConnect01)
- **Course**: DevOps & Cloud-Native Engineering, MIT Academy of Engineering, Pune.
