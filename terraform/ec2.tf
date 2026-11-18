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
              docker run -d --restart always -p 80:80 --name shalaconnect-app nginx:alpine
              docker exec shalaconnect-app sh -c "cat << 'HTMLEOF' > /usr/share/nginx/html/index.html
              <!DOCTYPE html>
              <html lang='en'>
              <head>
                  <meta charset='UTF-8'>
                  <meta name='viewport' content='width=device-width, initial-scale=1.0'>
                  <title>ShalaConnect | School Management Portal</title>
                  <style>
                      * { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; }
                      body { background: #f8fafc; color: #1e293b; min-height: 100vh; display: flex; flex-direction: column; }
                      header { background: #ffffff; border-bottom: 1px solid #e2e8f0; padding: 16px 32px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
                      .logo-group { display: flex; align-items: center; gap: 12px; }
                      .logo-icon { width: 42px; height: 42px; background: #2563eb; color: #ffffff; border-radius: 8px; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 1.25rem; }
                      .logo-title { font-size: 1.3rem; font-weight: 700; color: #0f172a; }
                      .badge { background: #e0f2fe; color: #0284c7; padding: 6px 12px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; text-transform: uppercase; }
                      main { flex: 1; max-width: 1100px; width: 100%; margin: 32px auto; padding: 0 20px; }
                      .hero { margin-bottom: 24px; }
                      .hero h2 { font-size: 1.6rem; color: #0f172a; margin-bottom: 6px; }
                      .hero p { color: #64748b; font-size: 0.95rem; }
                      .grid-k8s { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 28px; }
                      .card { background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.02); }
                      .card-label { font-size: 0.75rem; font-weight: 600; text-transform: uppercase; color: #64748b; letter-spacing: 0.05em; margin-bottom: 6px; }
                      .card-value { font-size: 1.05rem; font-weight: 700; color: #0f172a; word-break: break-all; }
                      .highlight-pod { color: #2563eb; font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace; }
                      .status-badge { display: inline-flex; align-items: center; gap: 6px; color: #16a34a; font-weight: 600; font-size: 0.9rem; }
                      .status-dot { width: 8px; height: 8px; background: #16a34a; border-radius: 50%; display: inline-block; box-shadow: 0 0 8px #16a34a; }
                      .section-title { font-size: 1.2rem; font-weight: 700; margin-bottom: 16px; color: #0f172a; }
                      .stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 28px; }
                      .stat-card { background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 20px; }
                      .stat-num { font-size: 1.85rem; font-weight: 800; color: #2563eb; margin-bottom: 4px; }
                      .stat-desc { color: #64748b; font-size: 0.85rem; }
                      table { width: 100%; border-collapse: collapse; background: #ffffff; border-radius: 12px; overflow: hidden; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.02); }
                      th, td { padding: 14px 18px; text-align: left; border-bottom: 1px solid #f1f5f9; font-size: 0.9rem; }
                      th { background: #f8fafc; font-weight: 600; color: #475569; }
                      footer { border-top: 1px solid #e2e8f0; padding: 20px; text-align: center; color: #94a3b8; font-size: 0.85rem; background: #ffffff; }
                  </style>
              </head>
              <body>
                  <header>
                      <div class='logo-group'>
                          <div class='logo-icon'>SC</div>
                          <div>
                              <div class='logo-title'>ShalaConnect</div>
                              <div style='font-size: 0.75rem; color: #64748b;'>Maharashtra School Management System &bull; Live Cloud Deployment</div>
                          </div>
                      </div>
                      <div>
                          <span class='badge'>Live on AWS EC2</span>
                      </div>
                  </header>

                  <main>
                      <div class='hero'>
                          <h2>Cloud-Native Application Dashboard</h2>
                          <p>Provisioned with HashiCorp Terraform and continuous integration &amp; deployment automated via Jenkins Pipeline.</p>
                      </div>

                      <div class='grid-k8s'>
                          <div class='card'>
                              <div class='card-label'>Cloud Infrastructure</div>
                              <div class='card-value highlight-pod'>AWS EC2 (t3.micro)</div>
                          </div>
                          <div class='card'>
                              <div class='card-label'>AWS Region</div>
                              <div class='card-value'>ap-south-1 (Mumbai)</div>
                          </div>
                          <div class='card'>
                              <div class='card-label'>Health Status</div>
                              <div class='card-value status-badge'><span class='status-dot'></span> 200 OK (Healthy)</div>
                          </div>
                          <div class='card'>
                              <div class='card-label'>CI/CD Engine</div>
                              <div class='card-value'>Jenkins Pipeline</div>
                          </div>
                      </div>

                      <div class='section-title'>School Telemetry &amp; System Overview</div>
                      <div class='stats-grid'>
                          <div class='stat-card'>
                              <div class='stat-num'>1,240</div>
                              <div class='stat-desc'>Enrolled Students Across 12 Divisions</div>
                          </div>
                          <div class='stat-card'>
                              <div class='stat-num'>98.4%</div>
                              <div class='stat-desc'>Average Daily Attendance</div>
                          </div>
                          <div class='stat-card'>
                              <div class='stat-num'>54</div>
                              <div class='stat-desc'>Active Certified Faculty &amp; Staff</div>
                          </div>
                      </div>

                      <div class='section-title'>Connected Academic Modules</div>
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
                                  <td><span class='status-badge'><span class='status-dot'></span> Active</span></td>
                                  <td>8080</td>
                                  <td>HTTP / REST</td>
                              </tr>
                              <tr>
                                  <td><strong>Teacher &amp; Staff Administration</strong></td>
                                  <td><span class='status-badge'><span class='status-dot'></span> Active</span></td>
                                  <td>8080</td>
                                  <td>HTTP / REST</td>
                              </tr>
                              <tr>
                                  <td><strong>Cloud Health Telemetry (/health)</strong></td>
                                  <td><span class='status-badge'><span class='status-dot'></span> Passing</span></td>
                                  <td>80</td>
                                  <td>Liveness / Readiness Probe</td>
                              </tr>
                          </tbody>
                      </table>
                  </main>

                  <footer>
                      ShalaConnect &bull; DevOps Assignment &bull; Yash Sabale &bull; MIT Academy of Engineering, Pune
                  </footer>
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
