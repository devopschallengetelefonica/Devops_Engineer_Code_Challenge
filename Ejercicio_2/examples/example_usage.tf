module "chart" {
  source                = "./modules/chart"
  acr_server            = "instance.azurecr.io"
  acr_server_subscription = "c9e7611c-d508-4fbf-aede-0bedfabc1560"
  source_acr_client_id = "1b2f651e-b99c-4720-9ff1-ede324b8ae30"
  source_acr_client_secret = "Zrrr8~5~F2Xiaaaa7eS.S85SXXAAfTYizZEF1cRp"
  source_acr_server     = "reference.azurecr.io"
  charts = [
    {
      chart_name       = "my-chart"
      chart_namespace  = "default"
      chart_repository = "my-repo"
      chart_version    = "1.0.0"
      values = [
        {
          name  = "key1"
          value = "value1"
        },
        {
          name  = "key2"
          value = "value2"
        }
      ]
      sensitive_values = [
        {
          name  = "sensitive_key1"
          value = "sensitive_value1"
        },
        {
          name  = "sensitive_key2"
          value = "sensitive_value2"
        }
      ]
    }
    # Add more charts as needed
  ]
}
