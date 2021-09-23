variable "certs" {
  type = map(object({
    crt      = string
    key      = string
    yaml_crt = string
    yaml_key = string
  }))
  default = {}
}

variable "cp_namespace" {
  type    = string
  default = "kong-cp"
}

variable "dp_namespace" {
  type    = string
  default = "kong-dp"
}

variable "kube_config" {
  type    = string
  default = "~/.kube/config"
}

variable "kong_license" {
  type    = string
  default = "~/.kong_license"
}

provider "helm" {
  kubernetes {
    config_path = var.kube_config
  }
}

provider "kubernetes" {
  config_path = var.kube_config
}

resource "kubernetes_namespace" "control-plane" {
  metadata {
    name   = var.cp_namespace
    labels = local.cp_labels
  }
}

resource "kubernetes_namespace" "data-plane" {
  metadata {
    name   = var.dp_namespace
    labels = local.dp_labels
  }
}

module "tls" {
  source = "srb3/cluster-tls/kong"
}

locals {
  cp_labels = {
    app  = "kong"
    type = "control-plane"
  }
  dp_labels = {
    app  = "kong"
    type = "data-plane"
  }
  certs = {
    "kong-cluster-cert" = {
      crt      = module.tls.cert.kong-cluster.cert_pem
      key      = module.tls.key.kong-cluster.private_key_pem
      yaml_crt = "cluster_cert"
      yaml_key = "cluster_cert_key"
    }
  }
  cp_deployment_name            = "kong-control-plane"
  dp_deployment_name            = "kong-data-plane"
  cp_namespace                  = kubernetes_namespace.control-plane.metadata[0].name
  dp_namespace                  = kubernetes_namespace.data-plane.metadata[0].name
  kong_helm_chart_version       = "2.3.0"
  kong_image_repo               = "kong/kong-gateway"
  kong_image_version            = "2.5.1.0"
  kong_database_name            = "kong"
  kong_database_user            = "kong"
  kong_database_secret_key      = "postgresql-password"
  kong_database_password        = "kong"
  kong_superuser_secret_name    = "kong-enterprise-superuser-password"
  kong_superuser_password       = "password"
  kong_license_secret_name      = "kong-enterprise-license"
  kong_license                  = file(var.kong_license)
  kong_session_conf_secret_name = "kong-session-config"
  kong_admin_gui_session_conf   = "{\"cookie_name\":\"admin_session\",\"storage\":\"kong\",\"cookie_samesite\":\"off\",\"cookie_secure\":false,\"secret\":\"cookiesecret\"}"
  kong_auth_conf_secret_name    = "kong-auth-config"
  manager_hostname              = "manager.kong.helm"
  admin_hostname                = "admin.kong.helm"
  proxy_hostname                = "proxy.kong.helm"
  scheme                        = "http"

  cp_values = templatefile("${path.module}/templates/control_plane_values.yaml", {
    manager_hostname              = local.manager_hostname
    admin_hostname                = local.admin_hostname
    scheme                        = local.scheme
    image_repo                    = local.kong_image_repo
    image_version                 = local.kong_image_version
    deployment_name               = local.cp_deployment_name
    kong_database_secret_key      = local.kong_database_secret_key
    kong_superuser_secret_name    = local.kong_superuser_secret_name
    kong_license_secret_name      = local.kong_license_secret_name
    kong_session_conf_secret_name = local.kong_session_conf_secret_name
    kong_auth_conf_secret_name    = local.kong_auth_conf_secret_name
    kong_database_name            = local.kong_database_name
    kong_database_user            = local.kong_database_user
    certs                         = local.certs
    labels                        = local.cp_labels
  })

  dp_values = templatefile("${path.module}/templates/data_plane_values.yaml", {
    proxy_hostname             = local.proxy_hostname
    scheme                     = local.scheme
    image_repo                 = local.kong_image_repo
    image_version              = local.kong_image_version
    deployment_name            = local.dp_deployment_name
    kong_license_secret_name   = local.kong_license_secret_name
    cluster_control_plane      = module.kong_cp.cluster_internal_endpoint
    cluster_telemetry_endpoint = module.kong_cp.clustertelemetry_internal_endpoint
    certs                      = local.certs
    labels                     = local.dp_labels
  })
}

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

module "kong_dp" {
  source    = "../../"
  namespace = local.dp_namespace
  values    = local.dp_values
  chart = {
    name       = local.dp_deployment_name
    repository = "https://charts.konghq.com"
    chart      = "kong"
    version    = local.kong_helm_chart_version
  }
  kong_superuser_password = local.kong_superuser_password
  kong_license            = local.kong_license
  certs                   = local.certs
  depends_on              = [module.tls]
}

locals {
  # The attrs variable is a yaml data structure holding
  # the config for the cinc-auditor and python selenium tests
  attrs = templatefile("${path.module}/templates/attrs", {
    kong_admin_url = "${local.scheme}://${module.kong_cp.admin_ip}:${module.kong_cp.admin_port}"
    kong_proxy_url = "${local.scheme}://${module.kong_dp.proxy_ip}:${module.kong_dp.proxy_port}"
    kong_token     = local.kong_superuser_password
  })
}

# This file is only used by the testing scripts
# It acts as config and is not executable
resource "local_file" "attrs_create" {
  content         = local.attrs
  filename        = "${path.module}/../../test/attributes.yaml"
  file_permission = "0644"
}
