terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.38.0"
    }
  }
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "default"
}

resource "aws_instance" "pokemon1" {
  ami           = "ami-07d9b9ddc6cd8dd30"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.primary.id
  tags = {
    Name = "pokemon1"
  }
}

resource "aws_instance" "pokemon2" {
  ami           = "ami-07d9b9ddc6cd8dd30"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.secondary.id
  tags = {
    Name = "pokemon2"
  }
}
resource "aws_subnet" "primary" {
  availability_zone = "us-east-1a"
  vpc_id = aws_vpc.main.id
  cidr = "10.0.2.0/16"
}

resource "aws_subnet" "primary" {
  availability_zone = "us-east-1b"                                  
  vpc_id = aws_vpc.main.id
  cidr = "10.0.3.0/16"
}

resource "aws_security_group" "database" {
  name = "database"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22  
    to_port     = 22  
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "pokemondb"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_id = aws_db_subnet_group.dbsubnet.id
}

resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["aws_subnet.primary.id", "aws_subnet.secondary.id"]

  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

resource "aws_db_subnet_group" "dbsubnet" {
  name       = "dbsubnet"
  subnet_ids = [aws_subnet.primary.id, aws_subnet.secondary.id]

  tags = {
    Name = "My DB subnet group"
  }
}
