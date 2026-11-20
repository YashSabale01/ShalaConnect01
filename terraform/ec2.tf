# ==============================================================================
# AWS EC2 Instance Configuration for ShalaConnect Application Server
# Real Spring Boot + React + PostgreSQL Full-Stack Architecture
# ==============================================================================

# Data source for latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM Role for EC2 to pull images from Amazon ECR
resource "aws_iam_role" "ec2_ecr_role" {
  name = "${var.project_name}-${var.environment}-ec2-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-ecr-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_ecr_role.name
}

# Security group for ShalaConnect standalone EC2 instance
resource "aws_security_group" "ec2_app_sg" {
  name        = "${var.project_name}-${var.environment}-ec2-sg"
  description = "Allow inbound HTTP, Backend Spring Boot API, and SSH access for ShalaConnect"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Frontend HTTP access (React UI)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Backend Spring Boot API access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "PostgreSQL Database internal access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-sg"
  }
}

# Standalone EC2 instance for hosting the real ShalaConnect full-stack application
resource "aws_instance" "app_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.ec2_app_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true
  user_data_replace_on_change = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # 1. Enable 2GB Swap Memory (ensures high performance for Java + DB on t3.micro)
              fallocate -l 2G /swapfile
              chmod 600 /swapfile
              mkswap /swapfile
              swapon /swapfile
              echo '/swapfile none swap sw 0 0' >> /etc/fstab

              # 2. Install Docker and AWS CLI
              apt-get update -y
              apt-get install -y docker.io awscli
              systemctl enable --now docker

              # 3. Log in to Amazon ECR
              REGION="ap-south-1"
              REGISTRY="351245513808.dkr.ecr.ap-south-1.amazonaws.com"
              aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REGISTRY

              # 4. Start PostgreSQL 16 Database
              docker run -d \
                --name postgres \
                --restart always \
                -e POSTGRES_DB=school_management \
                -e POSTGRES_USER=postgres \
                -e POSTGRES_PASSWORD=postgres \
                -p 5432:5432 \
                postgres:16-alpine

              # 5. Wait for PostgreSQL to become ready
              sleep 10

              # 6. Start Real Spring Boot Java Backend
              docker run -d \
                --name shalaconnect-backend \
                --restart always \
                --net=host \
                -e PORT=8080 \
                -e DB_URL="jdbc:postgresql://localhost:5432/school_management" \
                -e DB_USERNAME=postgres \
                -e DB_PASSWORD=postgres \
                -e DDL_AUTO=update \
                -e ADMIN_EMAIL="admin@shalaconnect.in" \
                -e ADMIN_PASSWORD="Admin@123" \
                -e JWT_SECRET="shalaconnect_super_secret_jwt_key_must_be_at_least_32_chars_long!!" \
                -e ALLOWED_ORIGINS="*" \
                $REGISTRY/shalaconnect-backend:latest

              # 7. Start Real React Vite Frontend
              docker run -d \
                --name shalaconnect-frontend \
                --restart always \
                -p 80:80 \
                -e BACKEND_HOST="localhost" \
                $REGISTRY/shalaconnect-frontend:latest
              EOF

  tags = {
    Name        = "${var.project_name}-${var.environment}-app-server"
    Application = "ShalaConnect"
    Role        = "FullStack-SpringBoot-React-Server"
  }
}

# Allocate a permanent Elastic IP so the public address stays static across reboots
resource "aws_eip" "app_eip" {
  instance = aws_instance.app_server.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-eip"
  }
}
