provider "aws" {
  region = "us-east-1"
}

variable "username" {
  description = "The username for the DB master user"
  type        = string
  sensitive   = true
}

variable "password" {
  description = "The password for the DB master user"
  type        = string
  sensitive   = true
}

resource "aws_security_group" "mysql_access_anywhere" {
  name        = "MySQLAccessAnywhere"
  description = "MySQLAccessAnywhere"

  ingress {
    description = "MySQL from anywhere"
    from_port   = 3306
    to_port     = 3306
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
    Name = "mysql_access_anywhere"
  }
}

resource "aws_db_instance" "public_rds_instance" {
    allocated_storage                     = 10
    backup_retention_period               = 1
    db_name                               = "mydb"
    engine                                = "mysql"
    engine_version                        = "5.7.42"
    instance_class                        = "db.t3.micro"
    username                              = var.username
    password                              = var.password
    skip_final_snapshot                   = true
    publicly_accessible = true
    vpc_security_group_ids = [aws_security_group.mysql_access_anywhere.id]
}

output "rds_endpoint" {
  value = "${aws_db_instance.public_rds_instance.endpoint}"
}
