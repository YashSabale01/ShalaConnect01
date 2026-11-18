# CONTAINERIZATION & KUBERNETES DEPLOYMENT
## SHALACONNECT – SPRING BOOT CLOUD-NATIVE APPLICATION

| Field | Details |
| :--- | :--- |
| **Student Name** | Yash Sabale |
| **Program / Branch** | B.Tech – Computer Engineering |
| **Institute** | MIT Academy of Engineering, Pune |
| **Academic Year** | 2026–2027 |
| **Submission Date** | 18 November 2026 |

---

### Abstract
This project demonstrates the containerization and Kubernetes deployment of **ShalaConnect**, an enterprise-grade cloud-native school management platform built with **Java 21 and Spring Boot 3**. The backend microservice was packaged into an optimized multi-stage Docker image named `shalaconnect-backend:v1` using Eclipse Temurin JRE 21 Alpine, executed as a Docker container, and deployed to a Kubernetes cluster managed via Docker Desktop (kind provisioning). A Kubernetes Deployment manages the Spring Boot Pod with liveness and readiness health probes hitting `/api/health`. A Kubernetes NodePort Service (`backend-service`) exposes the application on port `30080` targeting port `8080`. The Spring Boot service connects to a containerized PostgreSQL 16 database instance with automated schema migrations. The application was verified and accessed via `kubectl port-forward` on `localhost:8080` and the interactive web interface on `localhost:3000`.

---

### 1. Introduction
Containerization packages an enterprise application together with its JDK/JRE runtime and configuration dependencies so that it runs reliably across development, staging, and cloud production environments. Docker provides reproducible container builds through multi-stage Dockerfiles. Kubernetes orchestrates the multi-tier microservices architecture, providing automated scheduling, self-healing, health probes, and service discovery across Pods.

---

### 2. Project Objectives
- Containerize a production-grade **Java Spring Boot 3** web application.
- Author an optimized multi-stage `Dockerfile` leveraging Maven dependency caching and lightweight JRE runtime.
- Build the custom Docker image locally (`shalaconnect-backend:v1`).
- Execute and verify the containerized Spring Boot backend connected to PostgreSQL.
- Create Kubernetes Deployment and Service manifests (`backend.yaml`, `postgres.yaml`, `frontend.yaml`).
- Deploy the microservices stack onto Kubernetes and configure health probes on `/api/health`.
- Expose the Spring Boot backend via a Kubernetes `NodePort` Service on port `30080`.
- Verify Pods, Deployments, ReplicaSets, Services, and live application endpoints.

---

### 3. Application Overview
**ShalaConnect** is an integrated school management platform designed for Cluster Resource Centre Coordinators (CRCCs) and Headmasters to monitor school performance, student attendance, dynamic evaluation forms, and academic records.

#### Key Backend Architecture Components:
- **Framework**: Spring Boot 3 with Spring Data JPA and Hibernate ORM.
- **Security & Session**: Stateless JWT token authentication and BCrypt password encryption.
- **Database Layer**: PostgreSQL 16 relational database with HikariCP connection pooling.
- **Key REST Controllers**:
  - `HealthController` (`/api/health`): Cluster health verification returning status `UP`.
  - `AuthController` (`/api/auth`): Role-based JWT authentication.
  - `SchoolController` (`/api/schools`): Cluster school administration.
  - `AttendanceController` (`/api/attendance`): Student and faculty attendance tracking.
  - `FormController` (`/api/forms`): Dynamic survey and inspection questionnaires.

---

### 4. Technology Stack and Environment

| Component | Technology / Value |
| :--- | :--- |
| **Operating System** | Microsoft Windows 11 |
| **Application Framework** | Java 21 / Spring Boot 3.2.3 / Maven |
| **Database** | PostgreSQL 16 Alpine |
| **Frontend Framework** | React 18 / Vite / Tailwind CSS / Nginx |
| **Container Platform** | Docker Desktop 29.9.3 |
| **Backend Docker Image** | `shalaconnect-backend:v1` |
| **Frontend Docker Image** | `shalaconnect-frontend:v1` |
| **Kubernetes Engine** | Docker Desktop Kubernetes (kind v1.36.1) |
| **Backend Workload** | Deployment: `backend-deployment`; 1 replica |
| **Backend Service** | `backend-service`; NodePort 30080 → targetPort 8080 |
| **Backend Port** | 8080 (REST API `/api/health`) |
| **Frontend Port** | 3000 (React Web Portal) |

---

### 5. Project Structure
```text
shalaconect01/
├── backend/                        # Java 21 Spring Boot Microservice
│   ├── pom.xml                     # Maven dependency definitions
│   ├── Dockerfile                  # Multi-stage Maven build & JRE 21 runtime
│   └── src/main/java/com/shalaconnect/
│       ├── ShalaConnectApplication.java
│       └── controller/
│           ├── HealthController.java     # GET /api/health
│           ├── AuthController.java       # POST /api/auth/login
│           ├── SchoolController.java     # GET /api/schools
│           └── AttendanceController.java # GET /api/attendance
├── frontend/                       # React 18 Vite Client
│   ├── package.json
│   ├── Dockerfile                  # Node.js builder + Nginx Alpine runtime
│   └── src/
├── database/
│   └── init.sql                    # PostgreSQL extensions (uuid-ossp, pgcrypto)
└── k8s-shalaconnect/               # Kubernetes Deployment & Service Manifests
    ├── postgres.yaml               # PostgreSQL Deployment & ClusterIP Service (5432)
    ├── backend.yaml                # Spring Boot Deployment & NodePort Service (30080)
    └── frontend.yaml               # React Frontend Deployment & NodePort Service (30000)
```

---

### 6. Docker Containerization

#### 6.1 Spring Boot Multi-Stage Dockerfile
```dockerfile
# Stage 1: Build JAR using Maven and Temurin JDK 21
FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -q
COPY src ./src
RUN mvn clean package -DskipTests -q

# Stage 2: Minimal Production JRE Runtime
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=builder /app/target/*.jar app.jar
RUN mkdir -p uploads && chmod 777 uploads && chown -R appuser:appgroup /app
USER appuser
EXPOSE 8080
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
```

#### 6.2 Build the Docker Image
```powershell
docker build -t shalaconnect-backend:v1 backend/
docker images shalaconnect-backend:v1
```

---

### 7. Kubernetes Deployment & Service Manifests

#### 7.1 Backend Manifest (`k8s-shalaconnect/backend.yaml`)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-deployment
  labels:
    app: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
        - name: backend
          image: shalaconnect-backend:v1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080
          env:
            - name: PORT
              value: "8080"
            - name: DB_URL
              value: "jdbc:postgresql://postgres:5432/school_management"
            - name: DB_USERNAME
              value: "postgres"
            - name: DB_PASSWORD
              value: "postgres"
            - name: DDL_AUTO
              value: "update"
          livenessProbe:
            httpGet:
              path: /api/health
              port: 8080
            initialDelaySeconds: 20
            periodSeconds: 15
          readinessProbe:
            httpGet:
              path: /api/health
              port: 8080
            initialDelaySeconds: 15
            periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  type: NodePort
  selector:
    app: backend
  ports:
    - name: http
      port: 8080
      targetPort: 8080
      nodePort: 30080
```

---

### 8. Appendix: Evidence Screenshots

#### Figure 1: Verification of Docker Engine and Kubernetes Node
Command: `docker version; kubectl get nodes`  
*Caption:* Verifying Docker Engine v29.9.3 and Kubernetes control-plane node `desktop-control-plane` in `Ready` status.

#### Figure 2: Spring Boot Docker Image Multi-Stage Build
Command: `docker build -t shalaconnect-backend:v1 backend/`  
*Caption:* Multi-stage Docker build utilizing Maven 3.9.6 for packaging and Eclipse Temurin 21 JRE Alpine for lightweight runtime.

#### Figure 3: Verification of Built Container Images
Command: `docker images | Select-String "shalaconnect"`  
*Caption:* Inspecting the local Docker registry confirming `shalaconnect-backend:v1` and `shalaconnect-frontend:v1`.

#### Figure 4: Applying Kubernetes Manifests
Command: `kubectl apply -f k8s-shalaconnect/postgres.yaml; kubectl apply -f k8s-shalaconnect/backend.yaml; kubectl apply -f k8s-shalaconnect/frontend.yaml`  
*Caption:* Declarative deployment of the multi-tier microservices stack on Kubernetes.

#### Figure 5: Kubernetes Pods and NodePort Services Status
Command: `kubectl get pods -o wide; kubectl get services`  
*Caption:* Verifying all Pods in `1/1 Running` status and `backend-service` exposed via NodePort `30080`.

#### Figure 6: Live Spring Boot Logs & Database Connection
Command: `kubectl logs deployment/backend-deployment --tail=30`  
*Caption:* Live container logs showing embedded Tomcat started on port 8080 and HikariCP connection established to PostgreSQL.

#### Figure 7: Spring Boot API Health Check Response
URL: `http://localhost:8080/api/health`  
*Caption:* Browser verification of the Spring Boot HealthController returning status code 200 OK and JSON telemetry `{"status": "UP", "service": "ShalaConnect API"}`.

#### Figure 8: ShalaConnect Web Portal User Interface
URL: `http://localhost:3000`  
*Caption:* Browser interface of the ShalaConnect (शाळाकनेक्ट) platform accessed through the Kubernetes frontend service.

#### Figure 9: Kubernetes Self-Healing Demonstration
Command: `kubectl delete pod <pod-name>; kubectl get pods`  
*Caption:* Demonstrating Kubernetes resilience by deleting a pod and verifying instantaneous automated recreation by the Deployment controller.

---

### 9. Results & Conclusion
The complete **Java Spring Boot 3** application was successfully containerized using multi-stage Docker builds and orchestrated using Kubernetes alongside PostgreSQL and a React frontend. The application demonstrates production-ready features including health probes (`/api/health`), declarative NodePort services, container isolation, and automated self-healing.
