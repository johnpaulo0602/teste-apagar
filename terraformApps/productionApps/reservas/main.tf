terraform {
  backend "s3" {}
}

data "aws_lb" "this" {
  tags = {Name = "eks-seazone-prod-cluster"}
}

resource "cloudflare_record" "this" {
  zone_id = "03880d975c4d65e1cbdddad741e23e33"
  name    = "api"
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
  arn = "arn:aws:iam::711387131913:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/88953DFB37911EA9F674AF009D5FC20C"
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
  managed_policy_arns = [aws_iam_policy.s3.arn,"arn:aws:iam::aws:policy/AmazonSSMFullAccess"]
}

resource "aws_ses_domain_identity" "this" {
  domain = var.domain
}

resource "aws_ses_domain_mail_from" "this" {
  domain           = aws_ses_domain_identity.this.domain
  mail_from_domain = "no-reply-web.${aws_ses_domain_identity.this.domain}"
}

resource "aws_ses_domain_dkim" "this" {
  domain = aws_ses_domain_identity.this.domain
}

output "dkim"{
  value = aws_ses_domain_dkim.this.dkim_tokens
}

resource "cloudflare_record" "dkim" {
  count   = 3 
  zone_id = var.zone_id
  name    = "${aws_ses_domain_dkim.this.dkim_tokens[count.index]}"
  content = "${aws_ses_domain_dkim.this.dkim_tokens[count.index]}.dkim.amazonses.com"
  type    = "CNAME"
  ttl     = 600
  allow_overwrite = true
}

resource "cloudflare_record" "mail_from_mx" {
  zone_id = var.zone_id
  name    = aws_ses_domain_mail_from.this.mail_from_domain
  content = "feedback-smtp.us-east-1.amazonses.com"
  type    = "MX"
  priority = 10
  ttl     = 600
  allow_overwrite = true
}

module "master" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.identifier}-master"

  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class

  allocated_storage = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type = var.storage_type

  db_name  = var.db_name
  username = var.username
  port     = var.port

  password = ""
  # Not supported with replicas
  manage_master_user_password = false

  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  vpc_security_group_ids = var.vpc_security_group_ids

  maintenance_window = var.maintenance_window
  backup_window      = var.backup_window

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = var.monitoring_interval
  monitoring_role_name   = var.identifier
  create_monitoring_role = var.create_monitoring_role
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period

  tags = var.DEFAULT_TAGS

  # DB subnet group
  create_db_subnet_group = var.create_db_subnet_group
  subnet_ids             = var.subnets_ids
  publicly_accessible = var.publicly_accessible

  backup_retention_period = var.backup_retention_period
  # Database Deletion Protection
  deletion_protection = var.deletion_protection

  create_db_option_group    = var.create_db_option_group
  family = var.family
  db_subnet_group_name = var.identifier
  create_db_parameter_group = var.create_db_parameter_group
  parameter_group_name = var.identifier

}

module "replica" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.identifier}-replica"

  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class_replica
  family = var.family

  allocated_storage = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type = var.storage_type

  replicate_source_db = module.master.db_instance_identifier
  port     = var.port
  
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  vpc_security_group_ids = var.vpc_security_group_ids

  maintenance_window = var.maintenance_window
  backup_window      = var.backup_window

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = var.monitoring_interval
  monitoring_role_name   = "${var.identifier}-replica"
  create_monitoring_role = var.create_monitoring_role
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period

  tags = var.DEFAULT_TAGS

  # DB subnet group
  # create_db_subnet_group = var.create_db_subnet_group_replica
  # db_subnet_group_name = var.identifier
  subnet_ids             = var.subnets_ids
  

  backup_retention_period = var.backup_retention_period_replica
  # Database Deletion Protection
  deletion_protection = var.deletion_protection
  
  publicly_accessible = var.publicly_accessible
  
  create_db_option_group    = var.create_db_option_group
    
  create_db_parameter_group = var.create_db_parameter_group
  parameter_group_name = "${var.identifier}-replica"
  depends_on = [ module.master ]
}


module "lambda_function_existing_package_from_remote_url" {
  source = "terraform-aws-modules/lambda/aws"
  for_each = var.lambdas
  function_name = each.value.function_name
  description   = each.value.description
  handler       = each.value.handler
  runtime       = each.value.runtime

  create_package         = each.value.create_package
  local_existing_package = each.value.local_existing_package
}

module "sns_topic" {
  source  = "terraform-aws-modules/sns/aws"

  name  = "sns-email-delivery-bounce-complaint"

  subscriptions = {
    delivery = {
      protocol = "lambda"
      endpoint = "arn:aws:lambda:us-west-2:711387131913:function:ses-delivery-logging-LambdaFunction"
    },
    complaint = {
      protocol = "lambda"
      endpoint = "arn:aws:lambda:us-west-2:711387131913:function:ses-complaint-logging-LambdaFunction"
    },
    bounce = {
      protocol = "lambda"
      endpoint = "arn:aws:lambda:us-west-2:711387131913:function:ses-bounce-logging-LambdaFunction"
    }

  }

  tags = {
    Environment = "production"
    Projetc = "reservas"
    Terraform   = "true"
  }
}