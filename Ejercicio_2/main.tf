# Create a resource group (if needed) for AKS and ACR
resource "azurerm_resource_group" "aks" {
  name     = "my-aks-resource-group"
  location = "East US"
}

# Create the AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "my-aks-cluster"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  ...
}

# Create the instance ACR (if needed)
resource "azurerm_container_registry" "instance_acr" {
  name                = "instance-acr"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  sku                 = "Basic"
}

# Create the Helm provider (assuming you've configured it)
provider "helm" {
  kubernetes {
    config_path = data.azurerm_kubernetes_cluster.kube_config[0].config_file_path
  }
}

# Loop through the charts and import/install them
locals {
  helm_chart_commands = [
    for chart in var.charts :
    {
      chart_name  = chart.chart_name
      namespace   = chart.chart_namespace
      repository  = chart.chart_repository
      version     = chart.chart_version
    }
  ]
}

resource "null_resource" "import_and_install_charts" {
  count = length(local.helm_chart_commands)

  triggers = {
    command = local.helm_chart_commands[count.index]
  }

  provisioner "local-exec" {
    command = <<EOT
      # Authenticate to the source ACR
      az acr login --name ${var.source_acr_server} --username ${var.source_acr_client_id} --password ${var.source_acr_client_secret}

      # Pull the Helm chart from the source ACR
      helm chart pull ${var.source_acr_server}/${local.helm_chart_commands[count.index].repository}/${local.helm_chart_commands[count.index].chart_name}:${local.helm_chart_commands[count.index].version} --username ${var.source_acr_client_id} --password ${var.source_acr_client_secret}

      # Push the Helm chart to the instance ACR
      helm chart push ${var.acr_server}/${local.helm_chart_commands[count.index].repository}/${local.helm_chart_commands[count.index].chart_name}:${local.helm_chart_commands[count.index].version}

      # Install the Helm chart on the AKS cluster
      helm install ${local.helm_chart_commands[count.index].chart_name} ${var.acr_server}/${local.helm_chart_commands[count.index].repository}/${local.helm_chart_commands[count.index].chart_name}:${local.helm_chart_commands[count.index].version} -n ${local.helm_chart_commands[count.index].namespace} --values <(cat <<EOF
      ${join("\n", formatlist("name=\"%s\",value=\"%s\"", var.charts[count.index].values[*].name, var.charts[count.index].values[*].value))}
      ${join("\n", formatlist("name=\"%s\",value=\"%s\"", var.charts[count.index].sensitive_values[*].name, var.charts[count.index].sensitive_values[*].value))}
      EOF
      )
    EOT
  }
}
