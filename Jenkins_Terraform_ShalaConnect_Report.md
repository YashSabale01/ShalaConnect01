# Jenkins CI/CD + Terraform Infrastructure as Code (IaC) Project
## Activity 2: Jenkins CI/CD Pipeline with Live AWS Cloud Infrastructure Provisioning

| Field | Details |
| :--- | :--- |
| **Student Name** | Yash Janardan Sabale |
| **Institute** | MIT Academy of Engineering, Pune (MITAOE) |
| **Course** | DevOps Continuous Assessment – Activity 2 |
| **GitHub Repository** | [https://github.com/YashSabale01/ShalaConnect01](https://github.com/YashSabale01/ShalaConnect01) |
| **Project Application** | ShalaConnect (School Management System) |
| **Cloud Provider** | Amazon Web Services (AWS) – `ap-south-1` (Mumbai) |
| **AWS Account ID** | `351245513808` |
| **Live EC2 Instance ID** | `i-0a560d88a34888e39` |
| **Live Public IP Address** | `13.233.77.225` |

---

## 1: Jenkins Environment Setup & Container Initialization

### Explanation
Initiated the Jenkins LTS container using Docker on Windows PowerShell. To enable direct cloud provisioning to Amazon Web Services from within Jenkins, the container was launched with port mapping (`8080:8080` for web access and `50000:50000` for build agents), persistent storage (`jenkins_home`), and the host's AWS credentials mounted directly into the container (`~/.aws:/root/.aws:ro`).

### Command Executed
```powershell
docker run -d --name jenkins -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v ${HOME}/.aws:/root/.aws:ro jenkins/jenkins:lts-jdk17
```

---

## 2: Jenkins Initial Administrator Authentication

### Explanation
Accessed the Jenkins web portal at `http://localhost:8080` for the initial bootstrap authentication. The auto-generated security token was retrieved directly from the Docker container's secrets store.

### Command Executed
```powershell
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

---

## 3: Plugin Customization & Installation Selection

### Explanation
Configured the Jenkins instance via the Getting Started setup wizard by choosing **"Install suggested plugins"** to automatically install core components including Git, Pipeline, Credentials Binding, and GitHub branch source plugins.

---

## 4: Automated Plugin Installation Progress

### Explanation
Monitored real-time installation of essential pipeline plugins, dependencies, and agent bindings required for declarative multi-stage CI/CD pipeline execution and Git integration.

---

## 5: Repository Cloning & Git Configuration

### Explanation
Configured the local Git repository for ShalaConnect, verifying the remote origin URL pointing to `https://github.com/YashSabale01/ShalaConnect01.git`, ensuring that all pipeline files (`Jenkinsfile`) and Terraform configurations (`terraform/`) are version-controlled and synchronized with GitHub.

### Commands Executed
```powershell
cd "D:\devops assignments\shalaconect01"
git status
git remote -v
```

---

## 6: Pipeline Job Creation & Initial Build Trigger

### Explanation
Navigating the Jenkins dashboard, creating a new **Pipeline** job named `ShalaConnect_CI_CD`, configuring the pipeline definition as **Pipeline script from SCM** pointing to the GitHub repository URL (`https://github.com/YashSabale01/ShalaConnect01.git`), specifying branch `*/main`, and setting script path to `Jenkinsfile`.

---

## 7: Jenkinsfile Declarative Pipeline Script

### Explanation
Authored the declarative `Jenkinsfile` directly in the ShalaConnect repository, defining automated multi-stage workflows covering:
1. **Source Code Checkout:** Pulling the latest commit from GitHub.
2. **Environment & Tools Verification:** Validating Git, Java, and Terraform binary availability.
3. **Backend Build & Test Validation:** Verifying Spring Boot components (`pom.xml`, controllers, services).
4. **Frontend Build & Test Validation:** Validating React Vite frontend files and configurations.
5. **Terraform Init & Validate:** Initializing provider plugins (`hashicorp/aws`) and validating IaC syntax.
6. **Terraform Plan & AWS Infrastructure:** Generating an execution plan for cloud resources including the AWS EC2 instance, VPC, and Security Groups.
7. **Live AWS Cloud Provisioning & State:** Verifying the live provisioned AWS EC2 application server and querying state outputs (`i-0a560d88a34888e39`, `13.233.77.225`).

---

## 8: Terraform Binary Installation in Docker Container

### Explanation
Executed commands inside the running Jenkins container (`docker exec`) to download, extract, and install the Terraform binary (`v1.8.5`) into `/usr/local/bin/` so the pipeline executor can run Infrastructure as Code provisioning stages directly.

### Command Executed
```powershell
docker exec -it jenkins terraform -version
```

---

## 9: Terraform Cloud Configuration (`ec2.tf` & AWS Resources)

### Explanation
Authored modular, valid, and reusable Terraform configuration files in `terraform/`:
- `main.tf`: AWS provider specification in region `ap-south-1` with tags.
- `vpc.tf`: Custom Virtual Private Cloud (`10.0.0.0/16`), Public Subnets, Internet Gateway, and Route Tables.
- `ec2.tf`: AWS EC2 Instance resource (`aws_instance.app_server`) for hosting ShalaConnect on `t3.micro` Ubuntu 22.04 LTS with automated Docker user-data initialization running the real Spring Boot backend and React frontend.
- `security_groups.tf`: Security group (`ec2_app_sg`) allowing inbound traffic on Port 80 (Frontend UI), Port 8080 (Spring Boot Backend API), and Port 22 (SSH).
- `outputs.tf`: Exports the EC2 Instance ID and Public IP address.

---

## 10: Git Push Synchronization for Terraform Files & Pipeline

### Explanation
Committed and pushed the updated `Jenkinsfile`, `terraform/ec2.tf`, and configuration changes to `origin/main` to sync the repository with Jenkins.

### Command Executed
```powershell
git log -1 --stat
```

---

## 11: Live AWS Cloud Provisioning Execution (`terraform apply` & State)

### Explanation
Demonstrated actual cloud provisioning to Amazon Web Services using HashiCorp Terraform (`terraform apply -auto-approve`). The cloud resources (VPC, Subnets, Security Group, IAM profile, and EC2 instance) were successfully created on AWS Mumbai (`ap-south-1`).

### Output Evidence
```text
Apply complete! Resources: 5 added, 0 changed, 2 destroyed.

Outputs:
ec2_instance_id = "i-0a560d88a34888e39"
ec2_instance_public_ip = "13.233.77.225"
```

### AWS CLI Live State Verification
```powershell
aws ec2 describe-instances --instance-ids i-0a560d88a34888e39 --region ap-south-1 --query "Reservations[].Instances[][InstanceId,State.Name,PublicIpAddress,Tags]"
```

**JSON Output:**
```json
[
    [
        "i-0a560d88a34888e39",
        "running",
        "13.233.77.225",
        [
            {"Key": "ManagedBy", "Value": "Terraform"},
            {"Key": "Application", "Value": "ShalaConnect"},
            {"Key": "Environment", "Value": "prod"},
            {"Key": "Role", "Value": "FullStack-SpringBoot-React-Server"},
            {"Key": "Name", "Value": "shalaconnect-prod-app-server"},
            {"Key": "Project", "Value": "shalaconnect"}
        ]
    ]
]
```

---

## 12: Pipeline Execution & Stage View in Jenkins

### Explanation
Triggered automated build in Jenkins. The Pipeline Stage View reflects real-time status across each stage:
- Checkout Code (`SUCCESS`)
- Environment & Tools Verification (`SUCCESS`)
- Backend Build & Test Validation (`SUCCESS`)
- Frontend Build & Test Validation (`SUCCESS`)
- Terraform Init & Validate (`SUCCESS`)
- Terraform Plan & AWS Infrastructure (`SUCCESS`)
- Live AWS Cloud Provisioning & State (`SUCCESS`)

---

## 13: Live AWS EC2 Console & Full-Stack Deployment

### Explanation
The AWS EC2 Management Console in Mumbai (`ap-south-1`) confirms the active cloud provisioning of the ShalaConnect application server:
- **Instance ID:** `i-0a560d88a34888e39`
- **Instance State:** `running`
- **Public IPv4 Address:** `13.233.77.225`
- **Application URL:** `http://13.233.77.225` (React UI)
- **Spring Boot Health API:** `http://13.233.77.225:8080/api/health` (`{"status":"UP","service":"ShalaConnect API"}`)

---

## 14: Demonstration & Viva Presentation Script

### Step-by-Step Viva Presentation Walkthrough
1. **Introduction:**  
   *"Hello, my name is Yash Janardan Sabale. Today I am demonstrating Activity 2: Jenkins CI/CD Pipeline with Live AWS Cloud Infrastructure Provisioning for the ShalaConnect School Management Portal."*
2. **Architecture & CI/CD Pipeline:**  
   *"I containerized Jenkins LTS using Docker and connected it to my GitHub repository YashSabale01/ShalaConnect01. My declarative Jenkinsfile defines an end-to-end multi-stage pipeline covering source checkout, environment checks, backend Spring Boot validation, frontend React validation, and Terraform cloud provisioning."*
3. **Infrastructure as Code (IaC) with Terraform:**  
   *"In the terraform directory, I designed modular IaC configurations using HashiCorp Terraform to define an AWS VPC, Public Subnets, Internet Gateway, Security Groups, IAM Roles, and an AWS EC2 instance (t3.micro) in region ap-south-1 (Mumbai)."*
4. **Actual Cloud Provisioning on AWS:**  
   *"To fulfill the highest rubric criteria, I performed actual cloud provisioning using Terraform on AWS. Terraform provisioned the live EC2 instance (ID: i-0a560d88a34888e39) with public IP 13.233.77.225. In the AWS Management Console and via AWS CLI, the instance is verified in the running state."*
5. **Real Application Deployment:**  
   *"The EC2 instance runs our real containerized Spring Boot Java backend on port 8080 connected to PostgreSQL, and our React frontend on port 80, serving the complete ShalaConnect portal live on http://13.233.77.225."*
6. **Conclusion:**  
   *"The Jenkins pipeline executed all stages with status Finished: SUCCESS, demonstrating automated continuous integration, automated testing validation, and Infrastructure as Code cloud provisioning."*
