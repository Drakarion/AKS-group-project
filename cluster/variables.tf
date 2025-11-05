variable "subscription_id" {
  description = "Azure Subscription ID (можно опустить, если используешь az login и активную подписку)"
  type        = string
  default     = "3515993e-5088-4a84-b085-3eda96ed42c6"
}

variable "tenant_id" {
  description = "Azure Tenant ID (можно опустить при az login)"
  type        = string
  default     = "956149e1-42b4-4eaf-a34a-e49fc1a20155"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westus"
}

variable "resource_group_name" {
  description = "Имя Resource Group"
  type        = string
  default     = "aks-resources"
}

variable "cluster_name" {
  description = "Имя AKS кластера"
  type        = string
  default     = "my-aks-cluster"
}

variable "dns_prefix" {
  description = "DNS префикс для AKS"
  type        = string
  default     = "aksdemo"
}

variable "kubernetes_version" {
  description = "Версия Kubernetes (укажи поддерживаемую минорную, например 1.30)"
  type        = string
  default     = "1.30"
}

variable "node_count" {
  description = "Количество узлов по умолчанию"
  type        = number
  default     = 2
}

variable "node_size" {
  description = "Тип VM для узлов"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "vnet_cidr"   { default = "10.0.0.0/16" }
variable "subnet_cidr" { default = "10.0.1.0/24" }








# test