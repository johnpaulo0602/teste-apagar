variable "app_name" {
  default = "seazone-reservas-api"
}

variable "dns_name" {
  default= "api-staging"
}

variable "zone_id" {
  default = "03880d975c4d65e1cbdddad741e23e33"
}

variable "bucket_name_ranking" {
  default = "seazone-reservas-properties-ranking-stg"
}

variable "bucket_name_seo" {
  default = "seazone-reservas-seo-page-info-stg"
}

variable "bucket_name_hotels" {
  default = "seazone-reservas-google-hotels-properties-feed-stg"
}

variable "bucket_name_acomodations" {
  default = "seazone-reservas-referral-acommodations-stg"
}

variable "project" {
  default = "reservas"
}

variable "environment" {
  default = "staging"
}

variable "domain" {
  default = "seazone.com.br"
}

variable "AWS_REGION" {
  default = "us-west-2"
}

variable "DEFAULT_TAGS" {
  type = map(any)
  default = {
    environment = "staging"
    project     = "rds-reservas-staging"
    terraform   = "true"
  }
}

variable "identifier" {
  description = "The name of the RDS instance"
  default     = "rds-reservas-staging"
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  default     = "db.t3.small"
}

variable "engine" {
  description = "The database engine to use"
  default     = "postgres"
}

variable "engine_version" {
  description = "The database engine to use"
  default     = "15"
}

variable "storage_type" {
  description = "The database engine to use"
  default     = "gp3"
}

variable "subnets_ids" {
  default     = [
                  "subnet-0a200602a78457cb9",
                  "subnet-0b51ab131b3ac7d7e",
                  "subnet-048dd33c5363e2eec"
                ]
  type        = list(string)
  description = "The subnet ids that the cluster will use"
}


variable "port" {
  description = "The port on which the DB accepts connections"
  default     = 5432
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  default     = 20
}

variable "max_allocated_storage" {
  description = "The allocated storage in gigabytes"
  default     = 100
}

variable "db_name" {
  description = "The DB name to create. If omitted, no database is created initially"
  default     = "postgres"
}

variable "username" {
  description = "Username for the master DB user"
  default     = "postgres"
}

variable "iam_database_authentication_enabled" {
  description = "iam_database_authentication_enabled"
  default     = false
  type = bool
}

variable "create_monitoring_role" {
  description = "create_monitoring_role"
  default     = true
  type = bool
}

variable "performance_insights_enabled" {
  description = "performance_insights_enabled"
  default = true
  type = bool
}

variable "publicly_accessible" {
  description = "Bool to control if instance is publicly accessible"
  default     = true
  type = bool
}

variable "deletion_protection" {
  description = "The database can't be deleted when this value is set to true"
  default     = true
  type = bool
}

variable "create_db_subnet_group" {
  description = "Whether to create a database subnet group"
  default     = true
  type = bool
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
  default     = ["sg-05b43469803b574a4"]
  type = list(string)
}

variable "maintenance_window" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'"
  default     = "Mon:00:00-Mon:03:00"
  type = string
}

variable "backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance_window"
  default     = "03:00-06:00"
  type = string
}
variable "monitoring_interval" {
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Must be specified if monitoring_interval is non-zero"
  default     = "30"
  type = string
}
variable "performance_insights_retention_period" {
  description = "The amount of time in days to retain Performance Insights data. Valid values are 7, 731 (2 years) or a multiple of 31"
  default     = 7
  type = number
}
variable "create_db_option_group" {
  description = "Create a database option group"
  default     = false
  type = bool
}
variable "create_db_parameter_group" {
  description = "Whether to create a database parameter group"
  default     = true
  type = bool
}
variable "backup_retention_period" {
  description = "The days to retain backups for"
  default     = 7
  type = number
}

variable "family" {
  description = "The family of the DB parameter group"
  default     = "postgres15"
  type = string
}

variable "lambdas" {
  default ={
  bounce = {
    function_name = "ses-bounce-logging-LambdaFunction",
    description = "description",
    handler = "index.lambda_handler",
    runtime = "python3.8",
    create_package = false,
    local_existing_package = "./scripts/index.zip"
  },
  complaint = {
    function_name = "ses-complaint-logging-LambdaFunction",
    description = "description",
    handler = "index.lambda_handler",
    runtime = "python3.8",
    create_package = false,
    local_existing_package = "./scripts/index.zip"
  },
  delivery = {
    function_name = "ses-delivery-logging-LambdaFunction",
    description = "description",
    handler = "index.lambda_handler",
    runtime = "python3.8",
    create_package = false,
    local_existing_package = "./scripts/index.zip"
  }
  }
  type = map(object({
    function_name = string,
    description = string,
    handler = string,
    runtime = string,
    create_package = bool,
    local_existing_package = string
  }))
}


