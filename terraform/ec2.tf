# ==============================================================================
# AWS EC2 Instance Configuration for ShalaConnect Application Server
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

# Security group for ShalaConnect standalone EC2 instance
resource "aws_security_group" "ec2_app_sg" {
  name        = "${var.project_name}-${var.environment}-ec2-sg"
  description = "Allow inbound HTTP, Backend API, and SSH access for ShalaConnect"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Frontend HTTP access"
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

# Standalone EC2 instance for hosting ShalaConnect application
resource "aws_instance" "app_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.ec2_app_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              echo "Initializing ShalaConnect Host Server..."
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl enable --now docker
              echo "Server initialized successfully."
              EOF

  tags = {
    Name        = "${var.project_name}-${var.environment}-app-server"
    Application = "ShalaConnect"
    Role        = "Web-App-Server"
  }
}
