# Provider configuration
provider "aws" {
  region = "us-east-1" # Change to your desired region
}

# VPC configuration
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16" # Change CIDR block as per your requirements

  tags = {
    Name = "my_vpc"
  }
}

# Subnet configuration
resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a" # Change to your desired AZ
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b" # Change to your desired AZ
}

# Internet Gateway configuration
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
  }
}

# Attach Internet Gateway to VPC
resource "aws_vpc_attachment" "my_vpc_attachment" {
  vpc_id       = aws_vpc.my_vpc.id
  internet_gateway_id = aws_internet_gateway.my_igw.id
}

# Security Group configuration
resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.my_vpc.id

  # Allow traffic for your application (e.g., HTTP, HTTPS, SSH, RDS)
  # Adjust rules as per your requirements
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my_sg"
  }
}

# Launch Configuration
resource "aws_launch_configuration" "my_lc" {
  name_prefix   = "my_lc_"
  image_id      = "ami-12345678" # Provide the appropriate AMI ID
  instance_type = "t2.micro"     # Change to your desired instance type

  # Security group for EC2 instances
  security_groups = [aws_security_group.my_sg.id]

  # Use the user data script to configure your EC2 instances
  user_data = <<-EOF
              #!/bin/bash
              # Configure your instance here
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group configuration
resource "aws_autoscaling_group" "my_asg" {
  name                      = "my_asg"
  launch_configuration      = aws_launch_configuration.my_lc.id
  min_size                  = 2
  max_size                  = 2
  desired_capacity          = 2
  vpc_zone_identifier       = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
  health_check_type         = "EC2"
  termination_policies      = ["OldestInstance"]

  tag {
    key                 = "Name"
    value               = "my_ec2_instance"
    propagate_at_launch = true
  }
}

# Elastic Load Balancer configuration
resource "aws_elb" "my_elb" {
  name               = "my_elb"
  availability_zones = ["us-east-1a", "us-east-1b"]
  security_groups    = [aws_security_group.my_sg.id]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

