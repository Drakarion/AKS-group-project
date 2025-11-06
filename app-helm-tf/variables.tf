variable "kubeconfig_path" { type = string }
variable "charts_root" { type = string default = "../charts" }
variable "namespace" { type = string default = "default" }
# Switch: use internal MySQL (StatefulSet) or external cloud DB
variable "use_internal_mysql" { type = bool default = true }
# Image tags and secrets
variable "web_image_tag" { type = string default = "v1" }
variable "api_image_tag" { type = string default = "v1" }
variable "db_password" { type = string default = "Kaizen123!" sensitive = true }
# External DB settings (used when use_internal_mysql = false)
variable "external_db_host" { type = string default = "" }
variable "external_db_name" { type = string default = "appdb" }
variable "external_db_user" { type = string default = "kaizen" }