terraform {
  backend "s3" {}
}

data "aws_lb" "this" {
  tags = {Name = "eks-seazone-stage-cluster"}
}

resource "cloudflare_record" "this" {
  zone_id = var.zone_id
  name    = var.dns_name
  content = data.aws_lb.this.dns_name
  type    = "CNAME"
  ttl     = 3600
  allow_overwrite = true
}

resource "aws_ecr_repository" "this" {
  name                 = var.app_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 30 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_s3_bucket" "seo" {
  bucket = var.bucket_name_seo

  tags = {
    Name        = var.bucket_name_seo
    Environment = var.environment
    Projeto = var.project
  }
}

resource "aws_s3_bucket" "ranking" {
  bucket = var.bucket_name_ranking

  tags = {
    Name        = var.bucket_name_ranking
    Environment = var.environment
    Projeto = var.project
  }
}

resource "aws_s3_bucket" "hotels" {
  bucket = var.bucket_name_hotels

  tags = {
    Name        = var.bucket_name_hotels
    Environment = var.environment
    Projeto = var.project
  }
}