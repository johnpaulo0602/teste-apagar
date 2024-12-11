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

resource "aws_s3_bucket" "acommodations" {
  bucket = var.bucket_name_acomodations

  tags = {
    Name        = var.bucket_name_acomodations
    Environment = var.environment
    Projeto = var.project
  }
}

data "aws_iam_openid_connect_provider" "this" {
  arn = "arn:aws:iam::017820684017:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/44B2CCB1FAD61DA3B02BA0D09FE5D1E4"
}


data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.this.arn]
    }
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = format( "%s:sub" ,data.aws_iam_openid_connect_provider.this.url)
      values   = ["system:serviceaccount:apps:reservas"]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
  }
  depends_on = [ data.aws_iam_openid_connect_provider.this ]
}

resource "aws_iam_policy" "s3" {
  name = "seazoneReservas"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
			    "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:DeleteObject",
                "s3:GetObjectTagging",
                "s3:PutObjectTagging"
				]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "this" {

  name        = "reservas"
  assume_role_policy   = join("", data.aws_iam_policy_document.this.*.json)
  managed_policy_arns = [aws_iam_policy.s3.arn]
}
