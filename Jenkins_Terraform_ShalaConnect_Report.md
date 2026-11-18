# Jenkins CI/CD + Terraform Infrastructure as Code (IaC) Project
## Activity 2: Jenkins CI/CD Pipeline with Live AWS Cloud Infrastructure Provisioning

| Field | Details |
| :--- | :--- |
| **Student Name** | Yash Sabale |
| **Institute** | MIT Academy of Engineering, Pune (MITAOE) |
| **Course** | DevOps Continuous Assessment – Activity 2 |
| **GitHub Repository** | [https://github.com/YashSabale01/ShalaConnect01](https://github.com/YashSabale01/ShalaConnect01) |
| **Project Application** | ShalaConnect (School Management System) |
| **Cloud Provider** | Amazon Web Services (AWS) – `ap-south-1` (Mumbai) |
| **AWS Account ID** | `351245513808` |
| **Live EC2 Instance ID** | `i-0e92fab74220441fe` |
| **Live Public IP Address** | `13.233.212.218` |

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
git status
git remote -v
git add Jenkinsfile terraform/ec2.tf terraform/variables.tf terraform/outputs.tf Jenkins_Terraform_ShalaConnect_Report.md
git commit -m "feat(ci-cd): add Jenkinsfile pipeline and live AWS EC2 Terraform infrastructure"
git push origin main
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
7. **Live AWS Cloud Provisioning & State:** Verifying the live provisioned AWS EC2 application server and querying state outputs (`i-0e92fab74220441fe`, `13.233.212.218`).

---

## 8: Terraform Binary Installation in Docker Container

### Explanation
Executed commands inside the running Jenkins container (`docker exec`) to download, extract, and install the Terraform binary (`v1.8.5` / `v1.10.x`) into `/usr/local/bin/` so the pipeline executor can run Infrastructure as Code provisioning stages directly.

### Command Executed
```powershell
docker exec -u root -it jenkins bash -c "apt-get update && apt-get install -y wget unzip && wget https://releases.hashicorp.com/terraform/1.8.5/terraform_1.8.5_linux_amd64.zip && unzip terraform_1.8.5_linux_amd64.zip && mv terraform /usr/local/bin/ && rm terraform_1.8.5_linux_amd64.zip && terraform -version"
```

---

## 9: Terraform Cloud Configuration (`ec2.tf` & AWS Resources)

### Explanation
Authored modular, valid, and reusable Terraform configuration files in `terraform/`:
- `main.tf`: AWS provider specification in region `ap-south-1` with tags.
- `vpc.tf`: Custom Virtual Private Cloud (`10.0.0.0/16`), Public Subnets, Internet Gateway, and Route Tables.
- `ec2.tf`: AWS EC2 Instance resource (`aws_instance.app_server`) for hosting ShalaConnect on `t3.micro` Ubuntu 22.04 LTS with automated Docker user-data initialization.
- `security_groups.tf`: Security group (`ec2_app_sg`) allowing inbound traffic on Port 80 (Frontend), Port 8080 (Spring Boot Backend API), and Port 22 (SSH).
- `outputs.tf`: Exports the EC2 Instance ID and Public IP address.

---

## 10: Git Push Synchronization for Terraform Files & Pipeline

### Explanation
Committed and pushed the updated `Jenkinsfile`, `terraform/ec2.tf`, and configuration changes to `origin/main` to sync the repository with Jenkins.

---

## 11: Live AWS Cloud Provisioning Execution (`terraform apply`)

### Explanation
Demonstrated actual cloud provisioning to Amazon Web Services using HashiCorp Terraform (`terraform apply -auto-approve`). The cloud resources were successfully created on AWS Mumbai (`ap-south-1`).

### Output Evidence
```text
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:
ec2_instance_id = "i-0e92fab74220441fe"
ec2_instance_public_ip = "13.233.212.218"
```

### AWS CLI Live State Verification
```powershell
aws ec2 describe-instances --instance-ids i-0e92fab74220441fe --region ap-south-1 --query "Reservations[].Instances[][InstanceId,State.Name,PublicIpAddress,Tags]"
```
**Output:**
```json
[
    [
        "i-0e92fab74220441fe",
        "running",
        "13.233.212.218",
        [
            {"Key": "Application", "Value": "ShalaConnect"},
            {"Key": "ManagedBy", "Value": "Terraform"},
            {"Key": "Project", "Value": "shalaconnect"},
            {"Key": "Name", "Value": "shalaconnect-prod-app-server"},
            {"Key": "Role", "Value": "Web-App-Server"},
            {"Key": "Environment", "Value": "prod"}
        ]
    ]
]
```

---

## 12: Pipeline Execution & Stage View in Jenkins

### Explanation
Triggered **"Build Now"** in Jenkins. The Pipeline Stage View reflects real-time status across each stage:
- Checkout Code (`SUCCESS`)
- Environment & Tools Verification (`SUCCESS`)
- Backend Build & Test Validation (`SUCCESS`)
- Frontend Build & Test Validation (`SUCCESS`)
- Terraform Init & Validate (`SUCCESS`)
- Terraform Plan & AWS Infrastructure (`SUCCESS`)
- Live AWS Cloud Provisioning & State (`SUCCESS`)

---

## 13: Final Pipeline Summary & Execution Status

### Explanation
The Jenkins execution log concludes with:
```text
[SUCCESS] ShalaConnect CI/CD Pipeline Completed Cleanly!
Application Built, Tested, and Live AWS Infrastructure Verified
Finished: SUCCESS
```
The entire automated CI/CD lifecycle—from GitHub source pull, code validation, and test checks to Infrastructure as Code planning and live AWS cloud verification—completed cleanly.

---

## 14: Demonstration & Viva Presentation Script

### Step-by-Step Viva Presentation Walkthrough
1. **Introduction:**  
   *"Hello, my name is Yash Sabale. Today I am demonstrating Activity 2: Jenkins CI/CD Pipeline with Live AWS Cloud Infrastructure Provisioning for ShalaConnect."*
2. **Architecture & CI/CD Pipeline:**  
   *"I containerized Jenkins LTS using Docker and connected it to my GitHub repository YashSabale01/ShalaConnect01. My declarative Jenkinsfile defines an end-to-end multi-stage pipeline covering source checkout, environment checks, backend Spring Boot validation, frontend React validation, and Terraform cloud provisioning."*
3. **Infrastructure as Code (IaC) with Terraform:**  
   *"In the terraform directory, I designed modular IaC configurations using HashiCorp Terraform to define an AWS VPC, Public Subnets, Internet Gateway, Security Groups, and an AWS EC2 instance (t3.micro) in region ap-south-1 (Mumbai)."*
4. **Actual Cloud Provisioning on AWS:**  
   *"To fulfill the highest rubric criteria, I performed actual cloud provisioning using Terraform on AWS. Terraform provisioned the live EC2 instance (ID: i-0e92fab74220441fe) with public IP 13.233.212.218. In the AWS Management Console and via AWS CLI, the instance is in the running state."*
5. **Conclusion:**  
   *"The Jenkins pipeline successfully executed all stages with status Finished: SUCCESS, demonstrating automated continuous integration, automated testing validation, and Infrastructure as Code cloud provisioning."*
