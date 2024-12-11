variable "app_name" {
  default = "seazone-reservas-api"
}

variable "dns_name" {
  default= "api-stg-test"
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