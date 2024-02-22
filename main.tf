terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.zone
}

data "template_file" "indexer_userdata" {
  template = file("${path.module}/config/indexer_userdata.sh")
  vars = {
    bucket_name           = aws_s3_bucket.source_bucket.bucket
    zip_file              = var.zip_files["indexer_file"]
    data_file             = var.zip_files["data_file"]
    zincsearch_ip         = aws_instance.zincsearch_server.private_ip
    zincsearch_port       = var.zincsearch_port
    zincsearch_user       = var.zincsearch_user
    zincsearch_pass       = var.zincsearch_pass
    zincsearch_index_name = var.zincsearch_index_name
    zincsearch_files_dir  = var.zincsearch_files_dir
  }
}

data "template_file" "api_userdata" {
  template = file("${path.module}/config/api_userdata.sh")
  vars = {
    bucket_name           = aws_s3_bucket.source_bucket.bucket
    zip_file              = var.zip_files["api_file"]
    apirest_enabled       = var.apirest_enabled
    apirest_port          = var.apirest_port
    zincsearch_ip         = aws_instance.zincsearch_server.private_ip
    zincsearch_port       = var.zincsearch_port
    zincsearch_user       = var.zincsearch_user
    zincsearch_pass       = var.zincsearch_pass
    zincsearch_index_name = var.zincsearch_index_name
    basic_auth_user       = var.basic_auth_user
    basic_auth_pass       = var.basic_auth_pass
    external_auth_user    = var.external_auth_user
    external_auth_pass    = var.external_auth_pass
    jwt_secret            = var.jwt_secret
  }
}

data "template_file" "zincsearch_userdata" {
  template = file("${path.module}/config/zincsearch_userdata.sh")
  vars = {
    bucket_name     = aws_s3_bucket.source_bucket.bucket
    zip_file        = var.zip_files["zincsearch_file"]
    zincsearch_port = var.zincsearch_port
    zincsearch_user = var.zincsearch_user
    zincsearch_pass = var.zincsearch_pass
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.source_bucket.bucket
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.ec2_s3_access_role.arn
        },
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "${aws_s3_bucket.source_bucket.arn}",
          "${aws_s3_bucket.source_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket" "source_bucket" {
  bucket        = "source-bucket-camperez"
  force_destroy = true
  tags = {
    Name = "source-bucket-camperez"
  }
}

resource "aws_s3_object" "source_process_zip" {
  for_each     = { for idx, file in values(var.zip_files) : idx => file }
  bucket       = aws_s3_bucket.source_bucket.bucket
  source       = "${path.module}/src/${each.value}"
  key          = each.value
  content_type = "application/zip"
}

resource "aws_security_group_rule" "api_rule" {
  security_group_id = var.security_group
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "ssh_rule" {
  security_group_id = var.security_group
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "zincsearch_rule" {
  security_group_id = var.security_group
  type              = "ingress"
  from_port         = var.zincsearch_port
  to_port           = var.zincsearch_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "prof_rule" {
  security_group_id = var.security_group
  type              = "ingress"
  from_port         = 6060
  to_port           = 6060
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_key_pair" "deployer" {
  key_name   = "app-key"
  public_key = file("${path.module}/key-pair/public.pub")
  tags = {
    Name = "app-server-keypair"
  }
}

resource "aws_iam_policy" "s3_read_policy" {
  name        = "s3_read_policy"
  description = "Permite lectura en un bucket de S3 específico"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "s3:GetObject",
      Resource = "${aws_s3_bucket.source_bucket.arn}/*",
    }]
  })
}

resource "aws_iam_policy_attachment" "ec2_s3_access_attachment" {
  name       = "ec2_s3_access_attachment"
  roles      = [aws_iam_role.ec2_s3_access_role.name]
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

resource "aws_iam_role" "ec2_s3_access_role" {
  name = "ec2_s3_access_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_s3_access_profile"
  role = aws_iam_role.ec2_s3_access_role.name
}

resource "aws_instance" "indexer_server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  user_data_base64       = base64encode(data.template_file.indexer_userdata.rendered)
  vpc_security_group_ids = [var.security_group]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  depends_on             = [aws_instance.zincsearch_server]
  tags = {
    Name = "indexer-server"
  }
}

resource "aws_instance" "api_server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  user_data_base64       = base64encode(data.template_file.api_userdata.rendered)
  vpc_security_group_ids = [var.security_group]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  depends_on             = [aws_instance.zincsearch_server]
  tags = {
    Name = "api-server"
  }
}

resource "aws_instance" "zincsearch_server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  user_data_base64       = base64encode(data.template_file.zincsearch_userdata.rendered)
  vpc_security_group_ids = [var.security_group]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  tags = {
    Name = "zincsearch-server"
  }
}
