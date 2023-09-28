variable "acr_server" {
  description = "The target Azure Container Registry server to copy charts to"
}

variable "acr_server_subscription" {
  description = "The Azure subscription ID where the instance ACR resides"
}

variable "source_acr_client_id" {
  description = "Client ID for accessing the source ACR"
}

variable "source_acr_client_secret" {
  description = "Client secret for accessing the source ACR"
}

variable "source_acr_server" {
  description = "The source Azure Container Registry server to copy charts from"
}

variable "charts" {
  description = "A list of charts to import and install"
  type        = list(object({
    chart_name       = string
    chart_namespace  = string
    chart_repository = string
    chart_version    = string
    values           = list(object({
      name  = string
      value = string
    }))
    sensitive_values = list(object({
      name  = string
      value = string
    }))
  }))
}
