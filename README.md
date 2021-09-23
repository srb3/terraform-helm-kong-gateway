# terraform-helm-kong-gateway

A terraform module for kong gateway via helm

## Usage

### Using module defaults

A more complete example in the examples directory

```HCL
module "kong_cp" {
  source    = "../../"
  namespace = local.cp_namespace
  values    = local.cp_values
  chart = {
    name       = local.cp_deployment_name
    repository = "https://charts.konghq.com"
    chart      = "kong"
    version    = local.kong_helm_chart_version
  }
  kong_superuser_password     = local.kong_superuser_password
  kong_admin_gui_session_conf = local.kong_admin_gui_session_conf
  kong_license                = local.kong_license
  kong_database_password      = local.kong_database_password
  certs                       = local.certs
  depends_on                  = [module.tls]
}
```

## Testing

see make file
