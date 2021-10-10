# These values will be created as kubernetes secrets
module "secrets" {
  source                      = "./modules/secrets"
  deployment_name             = var.chart.name
  namespace                   = var.namespace
  kong_license                = var.kong_license
  kong_superuser_password     = var.kong_superuser_password
  kong_admin_gui_session_conf = var.kong_admin_gui_session_conf
  kong_portal_session_conf    = var.kong_portal_session_conf
  kong_admin_gui_auth_conf    = var.kong_admin_gui_auth_conf
  kong_portal_auth_conf       = var.kong_portal_auth_conf
  kong_database_password      = var.kong_database_password
  certs                       = var.certs
}

# user the official kong helm charts
# and a set of values to create kong instances
resource "helm_release" "kong" {
  name       = var.chart.name
  repository = var.chart.repository
  chart      = var.chart.chart
  version    = var.chart.version

  namespace = var.namespace
  values    = [var.values]
  provisioner "local-exec" {
    command = "sleep 40" # TODO: this may not be needed
  }
  depends_on = [module.secrets]
}

# query any services helm created for kong
# so we can use them as module outputs
data "kubernetes_service" "manager" {
  metadata {
    name      = "${var.chart.name}-kong-manager"
    namespace = var.namespace
  }
  depends_on = [helm_release.kong]
}

data "kubernetes_service" "admin" {
  metadata {
    name      = "${var.chart.name}-kong-admin"
    namespace = var.namespace
  }
  depends_on = [helm_release.kong]
}

data "kubernetes_service" "cluster" {
  metadata {
    name      = "${var.chart.name}-kong-cluster"
    namespace = var.namespace
  }
  depends_on = [helm_release.kong]
}

data "kubernetes_service" "clustertelemetry" {
  metadata {
    name      = "${var.chart.name}-kong-clustertelemetry"
    namespace = var.namespace
  }
  depends_on = [helm_release.kong]
}

data "kubernetes_service" "portal" {
  metadata {
    name      = "${var.chart.name}-kong-portal"
    namespace = var.namespace
  }
  depends_on = [helm_release.kong]
}

data "kubernetes_service" "portalapi" {
  metadata {
    name      = "${var.chart.name}-kong-portalapi"
    namespace = var.namespace
  }
  depends_on = [helm_release.kong]
}

data "kubernetes_service" "proxy" {
  metadata {
    name      = "${var.chart.name}-kong-proxy"
    namespace = var.namespace
  }
  depends_on = [helm_release.kong]
}

# query any ingress endpoints helm created for kong
# so we can use them as module outputs
data "kubernetes_ingress" "manager" {
  metadata {
    name      = "${var.chart.name}-kong-manager"
    namespace = var.namespace
  }
  depends_on = [helm_release.kong]
}

data "kubernetes_ingress" "admin" {
  metadata {
    name      = "${var.chart.name}-kong-admin"
    namespace = var.namespace
  }
  depends_on = [helm_release.kong]
}

data "kubernetes_ingress" "cluster" {
  metadata {
    name      = "${var.chart.name}-kong-cluster"
    namespace = var.namespace
  }
  depends_on = [helm_release.kong]
}

data "kubernetes_ingress" "clustertelemetry" {
  metadata {
    name      = "${var.chart.name}-kong-clustertelemetry"
    namespace = var.namespace
  }
  depends_on = [helm_release.kong]
}

data "kubernetes_ingress" "portal" {
  metadata {
    name      = "${var.chart.name}-kong-portal"
    namespace = var.namespace
  }
  depends_on = [helm_release.kong]
}

data "kubernetes_ingress" "portalapi" {
  metadata {
    name      = "${var.chart.name}-kong-portalapi"
    namespace = var.namespace
  }
  depends_on = [helm_release.kong]
}

data "kubernetes_ingress" "proxy" {
  metadata {
    name      = "${var.chart.name}-kong-proxy"
    namespace = var.namespace
  }
  depends_on = [helm_release.kong]
}

# create some local variables to use for outputs
locals {
  ######### manager ##############################
  manager_lb = try(try(
    data.kubernetes_service.manager.status.0.load_balancer.0.ingress.0.hostname,
    data.kubernetes_service.manager.status.0.load_balancer.0.ingress.0.ip
  ), "")

  manager_ip_tmp = local.manager_lb != "" ? local.manager_lb : try(
  data.kubernetes_service.manager.spec.0.cluster_ip, "")

  manager_ingress = try(
    data.kubernetes_ingress.manager.status.0.load_balancer.0.ingress.0.ip,
    ""
  )
  manager_ip                = local.manager_ingress != "" ? local.manager_ingress : local.manager_ip_tmp
  manager_port              = try(data.kubernetes_service.manager.spec.0.port.0.port, "")
  manager_internal_dns      = try("${data.kubernetes_service.manager.metadata.0.name}.${var.namespace}.svc.cluster.local", "")
  manager_internal_endpoint = "${local.manager_internal_dns}:${local.manager_port}"

  ######### admin ################################
  admin_lb = try(try(
    data.kubernetes_service.admin.status.0.load_balancer.0.ingress.0.hostname,
    data.kubernetes_service.admin.status.0.load_balancer.0.ingress.0.ip
  ), "")

  admin_ip_tmp = local.admin_lb != "" ? local.admin_lb : try(
  data.kubernetes_service.admin.spec.0.cluster_ip, "")

  admin_ingress = try(
    data.kubernetes_ingress.admin.status.0.load_balancer.0.ingress.0.ip,
    ""
  )
  admin_ip   = local.admin_ingress != "" ? local.admin_ingress : local.admin_ip_tmp
  admin_port = try(data.kubernetes_service.admin.spec.0.port.0.port, "")

  admin_interanl_dns      = try("${data.kubernetes_service.admin.metadata.0.name}.${var.namespace}.svc.cluster.local", "")
  admin_internal_endpoint = "${local.admin_interanl_dns}:${local.admin_port}"

  ######### cluster ##############################
  cluster_lb = try(try(
    data.kubernetes_service.cluster.status.0.load_balancer.0.ingress.0.hostname,
    data.kubernetes_service.cluster.status.0.load_balancer.0.ingress.0.ip
  ), "")

  cluster_ip_tmp = local.cluster_lb != "" ? local.cluster_lb : try(
  data.kubernetes_service.cluster.spec.0.cluster_ip, "")

  cluster_ingress = try(
    data.kubernetes_ingress.cluster.status.0.load_balancer.0.ingress.0.ip,
    ""
  )
  cluster_ip                = local.cluster_ingress != "" ? local.cluster_ingress : local.cluster_ip_tmp
  cluster_port              = try(data.kubernetes_service.cluster.spec.0.port.0.port, "")
  cluster_internal_dns      = try("${data.kubernetes_service.cluster.metadata.0.name}.${var.namespace}.svc.cluster.local", "")
  cluster_internal_endpoint = "${local.cluster_internal_dns}:${local.cluster_port}"

  ######### clustertelemetry #####################
  clustertelemetry_lb = try(try(
    data.kubernetes_service.clustertelemetry.status.0.load_balancer.0.ingress.0.hostname,
    data.kubernetes_service.clustertelemetry.status.0.load_balancer.0.ingress.0.ip
  ), "")

  clustertelemetry_ip_tmp = local.clustertelemetry_lb != "" ? local.clustertelemetry_lb : try(
  data.kubernetes_service.clustertelemetry.spec.0.cluster_ip, "")

  clustertelemetry_ingress = try(
    data.kubernetes_ingress.clustertelemetry.status.0.load_balancer.0.ingress.0.ip,
    ""
  )
  clustertelemetry_ip                = local.clustertelemetry_ingress != "" ? local.clustertelemetry_ingress : local.clustertelemetry_ip_tmp
  clustertelemetry_port              = try(data.kubernetes_service.clustertelemetry.spec.0.port.0.port, "")
  clustertelemetry_internal_dns      = try("${data.kubernetes_service.clustertelemetry.metadata.0.name}.${var.namespace}.svc.cluster.local", "")
  clustertelemetry_internal_endpoint = "${local.clustertelemetry_internal_dns}:${local.clustertelemetry_port}"


  ######### portal ###############################
  portal_lb = try(try(
    data.kubernetes_service.portal.status.0.load_balancer.0.ingress.0.hostname,
    data.kubernetes_service.portal.status.0.load_balancer.0.ingress.0.ip
  ), "")

  portal_ip_tmp = local.portal_lb != "" ? local.portal_lb : try(
  data.kubernetes_service.portal.spec.0.cluster_ip, "")

  portal_ingress = try(
    data.kubernetes_ingress.portal.status.0.load_balancer.0.ingress.0.ip,
    ""
  )
  portal_ip   = local.portal_ingress != "" ? local.portal_ingress : local.portal_ip_tmp
  portal_port = try(data.kubernetes_service.portal.spec.0.port.0.port, "")

  portal_interanl_dns      = try("${data.kubernetes_service.portal.metadata.0.name}.${var.namespace}.svc.cluster.local", "")
  portal_internal_endpoint = "${local.portal_interanl_dns}:${local.portal_port}"


  ######### portalapi ############################
  portalapi_lb = try(try(
    data.kubernetes_service.portalapi.status.0.load_balancer.0.ingress.0.hostname,
    data.kubernetes_service.portalapi.status.0.load_balancer.0.ingress.0.ip
  ), "")

  portalapi_ip_tmp = local.portalapi_lb != "" ? local.portalapi_lb : try(
  data.kubernetes_service.portalapi.spec.0.cluster_ip, "")

  portalapi_ingress = try(
    data.kubernetes_ingress.portalapi.status.0.load_balancer.0.ingress.0.ip,
    ""
  )
  portalapi_ip   = local.portalapi_ingress != "" ? local.portalapi_ingress : local.portalapi_ip_tmp
  portalapi_port = try(data.kubernetes_service.portalapi.spec.0.port.0.port, "")

  portalapi_interanl_dns      = try("${data.kubernetes_service.portalapi.metadata.0.name}.${var.namespace}.svc.cluster.local", "")
  portalapi_internal_endpoint = "${local.portalapi_interanl_dns}:${local.portalapi_port}"

  ######### proxy ################################
  proxy_lb = try(try(
    data.kubernetes_service.proxy.status.0.load_balancer.0.ingress.0.hostname,
    data.kubernetes_service.proxy.status.0.load_balancer.0.ingress.0.ip
  ), "")

  proxy_ip_tmp = local.proxy_lb != "" ? local.proxy_lb : try(
  data.kubernetes_service.proxy.spec.0.cluster_ip, "")

  proxy_ingress = try(
    data.kubernetes_ingress.proxy.status.0.load_balancer.0.ingress.0.ip,
    ""
  )
  proxy_ip                = local.proxy_ingress != "" ? local.proxy_ingress : local.proxy_ip_tmp
  proxy_port              = try(data.kubernetes_service.proxy.spec.0.port.0.port, "")
  proxy_internal_dns      = try("${data.kubernetes_service.proxy.metadata.0.name}.${var.namespace}.svc.cluster.local", "")
  proxy_internal_endpoint = "${local.proxy_internal_dns}:${local.proxy_port}"
}
