# Cloud-Native Application Automation Script
# Executes Build, Local Container Testing, and prepares Kubernetes manifests

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Activity 1: Cloud-Native Containerization & Deployment   " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

# Ensure Docker binary directory is in PATH for this session
$dockerBin = "D:\Docker\Docker\resources\bin"
if ($env:PATH -notlike "*$dockerBin*") {
    $env:PATH = "$dockerBin;" + $env:PATH
}

# Step 1: Docker Build
Write-Host "`n[Step 1] Building Docker Image: cloud-native-app:v1..." -ForegroundColor Green
docker build -t cloud-native-app:v1 .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker build failed! Please check if Docker Desktop is running." -ForegroundColor Red
    exit 1
}

Write-Host "`n[Step 1 Complete] Docker Image successfully built!" -ForegroundColor Cyan
docker images cloud-native-app:v1

# Step 2: Docker Run
Write-Host "`n[Step 2] Testing Container Execution..." -ForegroundColor Green
docker rm -f local-cloud-container 2>$null
docker run -d -p 5000:5000 --name local-cloud-container cloud-native-app:v1
Start-Sleep -Seconds 3

docker ps --filter "name=local-cloud-container"
Write-Host "`nApplication Health Endpoint Check (http://localhost:5000/healthz):" -ForegroundColor Yellow
try {
    $res = Invoke-RestMethod -Uri "http://localhost:5000/healthz" -TimeoutSec 5
    $res | ConvertTo-Json
    Write-Host "`nContainer is healthy and accessible at http://localhost:5000" -ForegroundColor Green
} catch {
    Write-Host "Could not query http://localhost:5000/healthz" -ForegroundColor Red
}

Write-Host "`n-> Take Screenshot 1 (Docker Build & Images) and Screenshot 2 (Container Run & Browser) now!" -ForegroundColor Magenta
Write-Host "Press ENTER after taking screenshots to clean up local container and proceed to Kubernetes..." -ForegroundColor Yellow
Read-Host

docker stop local-cloud-container
docker rm local-cloud-container

# Step 3 & 4: Kubernetes Deployment & Service
Write-Host "`n[Step 3 & 4] Checking Kubernetes Cluster..." -ForegroundColor Green
try {
    kubectl cluster-info
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`nDeploying to Kubernetes..." -ForegroundColor Green
        kubectl apply -f k8s/deployment.yaml
        kubectl apply -f k8s/service.yaml
        
        Write-Host "`nWaiting for Pods to be ready..." -ForegroundColor Yellow
        kubectl rollout status deployment/cloud-native-deployment
        
        Write-Host "`n--- Kubernetes Resources Status ---" -ForegroundColor Cyan
        kubectl get deployments
        kubectl get replicasets
        kubectl get pods -o wide
        kubectl get services
        
        Write-Host "`nApplication accessible via NodePort: http://localhost:30080" -ForegroundColor Green
        Write-Host "-> Take Screenshot 3 (kubectl get pods) and Screenshot 4 (kubectl get services & Browser http://localhost:30080)" -ForegroundColor Magenta
    }
} catch {
    Write-Host "Kubernetes is not enabled yet in Docker Desktop." -ForegroundColor Yellow
    Write-Host "Please enable Kubernetes in Docker Desktop Settings -> Kubernetes -> Enable Kubernetes." -ForegroundColor Yellow
}
