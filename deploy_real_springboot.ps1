# ==============================================================================
# ShalaConnect Spring Boot - Complete Build, Containerization & K8s Deployment
# Student: Yash Sabale | MIT Academy of Engineering, Pune
# ==============================================================================

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  ShalaConnect: Spring Boot Cloud-Native Deployment Pipeline      " -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan

# Set PATH to include Docker CLI
$dockerBin = "D:\Docker\Docker\resources\bin"
if ($env:PATH -notlike "*$dockerBin*") {
    $env:PATH = "$dockerBin;" + $env:PATH
}

# ------------------------------------------------------------------------------
# STEP 1: Verify Prerequisites (Docker Engine & Kubernetes Node)
# ------------------------------------------------------------------------------
Write-Host "`n[STEP 1] Verifying Docker Engine & Kubernetes Cluster Status..." -ForegroundColor Green
docker version --format 'Client Version: {{.Client.Version}}, Server Version: {{.Server.Version}}'
kubectl get nodes
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Kubernetes cluster is not accessible. Please ensure Docker Desktop has Kubernetes enabled." -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------------------------
# STEP 2: Build Spring Boot Backend Docker Image
# ------------------------------------------------------------------------------
Write-Host "`n[STEP 2] Building Spring Boot Docker Image (shalaconnect-backend:v1)..." -ForegroundColor Green
docker build -t shalaconnect-backend:v1 backend/
docker build -t shalaconnect-frontend:v1 frontend/

Write-Host "`nDocker Images Successfully Built:" -ForegroundColor Cyan
docker images | Select-String "shalaconnect"

# ------------------------------------------------------------------------------
# STEP 3: Deploy Full-Stack to Kubernetes (Postgres, Backend, Frontend)
# ------------------------------------------------------------------------------
Write-Host "`n[STEP 3] Deploying Manifests to Kubernetes..." -ForegroundColor Green
kubectl apply -f k8s-shalaconnect/postgres.yaml
kubectl apply -f k8s-shalaconnect/backend.yaml
kubectl apply -f k8s-shalaconnect/frontend.yaml

Write-Host "`nWaiting for Pods to reach 'Running' state..." -ForegroundColor Yellow
kubectl rollout status deployment/postgres-deployment --timeout=60s
kubectl rollout status deployment/backend-deployment --timeout=90s
kubectl rollout status deployment/frontend-deployment --timeout=60s

# ------------------------------------------------------------------------------
# STEP 4: Verify Running Pods & Services
# ------------------------------------------------------------------------------
Write-Host "`n[STEP 4] Kubernetes Cluster Resources Status:" -ForegroundColor Cyan
kubectl get deployments
kubectl get pods -o wide
kubectl get services

# ------------------------------------------------------------------------------
# STEP 5: Verify Spring Boot Tomcat & Hibernate Logs
# ------------------------------------------------------------------------------
Write-Host "`n[STEP 5] Inspecting Spring Boot Backend Logs:" -ForegroundColor Green
kubectl logs deployment/backend-deployment --tail=20

# ------------------------------------------------------------------------------
# STEP 6: Setup Port Forwarding for Application Access
# ------------------------------------------------------------------------------
Write-Host "`n[STEP 6] Application Access Ready:" -ForegroundColor Green
Write-Host "  -> Spring Boot Health API: http://localhost:8080/api/health" -ForegroundColor Yellow
Write-Host "  -> React Web Portal:       http://localhost:3000" -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan
