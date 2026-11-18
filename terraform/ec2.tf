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
  user_data_replace_on_change = true

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io
              systemctl enable --now docker
              docker run -d --restart always -p 80:80 --name web nginx:alpine
              docker exec web sh -c "cat << 'HTMLEOF' > /usr/share/nginx/html/index.html
              <!DOCTYPE html>
              <html>
              <head>
                <title>ShalaConnect - Live on AWS EC2</title>
                <style>
                  body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #0b1120; color: #f8fafc; text-align: center; padding-top: 80px; }
                  .box { display: inline-block; background: #1e293b; padding: 40px; border-radius: 16px; border: 1px solid #334155; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.5); max-width: 600px; }
                  h1 { color: #38bdf8; margin: 10px 0; }
                  p { color: #94a3b8; font-size: 16px; line-height: 1.6; }
                  .status { color: #4ade80; font-weight: bold; text-transform: uppercase; font-size: 13px; letter-spacing: 1px; }
                  .meta { margin-top: 25px; border-top: 1px solid #334155; padding-top: 20px; font-size: 14px; text-align: left; }
                  .meta div { display: flex; justify-content: space-between; padding: 6px 0; }
                  .label { color: #64748b; }
                  .val { color: #e2e8f0; font-family: monospace; font-weight: 600; }
                </style>
              </head>
              <body>
                <div class='box'>
                  <p class='status'>&#9679; ShalaConnect Service Live &amp; Healthy</p>
                  <h1>ShalaConnect Application</h1>
                  <p>School Management Portal &amp; Microservices running live on Amazon Web Services (AWS) EC2.</p>
                  <div class='meta'>
                    <div><span class='label'>Cloud Host:</span><span class='val'>AWS EC2 (t3.micro)</span></div>
                    <div><span class='label'>Region:</span><span class='val'>ap-south-1 (Mumbai)</span></div>
                    <div><span class='label'>Orchestrator:</span><span class='val'>Jenkins Declarative Pipeline</span></div>
                    <div><span class='label'>Infrastructure:</span><span class='val'>HashiCorp Terraform</span></div>
                    <div><span class='label'>Author:</span><span class='val'>Yash Sabale (MITAOE)</span></div>
                  </div>
                </div>
              </body>
              </html>
              HTMLEOF"
              EOF

  tags = {
    Name        = "${var.project_name}-${var.environment}-app-server"
    Application = "ShalaConnect"
    Role        = "Web-App-Server"
  }
}
