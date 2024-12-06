terraform {
  backend "s3" {}
}

data "aws_lb" "this" {
  tags = {Name = "eks-seazone-prod-cluster"}
}

resource "cloudflare_record" "this" {
  zone_id = "03880d975c4d65e1cbdddad741e23e33"
  name    = "wallet-bff"
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