variable "app_name" {
  default = "reservas-stg"
}

variable "dns_name" {
  default= "api-stg-test"
}

variable "zone_id" {
  default = "03880d975c4d65e1cbdddad741e23e33"
}

variable "bucket_name_ranking" {
  default = "seazone-reservas-properties-ranking-dev"
}

variable "bucket_name_seo" {
  default = "seazone-reservas-seo-page-info"
}

variable "bucket_name_hotels" {
  default = "seazone-reservas-google-hotels-properties-feed-dev"
}

variable "project" {
  default = "reservas"
}

variable "environment" {
  default = "staging"
}