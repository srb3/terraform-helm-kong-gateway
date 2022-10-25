# This module will create the kubernetes secrets needed for a kong deployment

########### Kong License #########################

resource "kubernetes_secret" "license" {
  metadata {
    name      = var.kong_license_secret_name
    namespace = var.namespace
  }

  type = "Opaque"
  data = {
    (var.kong_license_secret_key) = var.kong_license
  }
}

########### Kong Superuser #######################

resource "kubernetes_secret" "kong-enterprise-superuser-password" {
  metadata {
    name      = var.kong_superuser_secret_name
    namespace = var.namespace
  }

  type = "Opaque"
  data = {
    (var.kong_superuser_secret_key) = var.kong_superuser_password
  }
}

########### Kong Session Conf ####################

resource "kubernetes_secret" "kong-session-conf" {
  metadata {
    name      = var.kong_session_conf_secret_name
    namespace = var.namespace
  }

  type = "Opaque"
  data = {
    (var.kong_admin_gui_session_conf_secret_key) = var.kong_admin_gui_session_conf
    (var.kong_portal_session_conf_secret_key)    = var.kong_portal_session_conf
  }
}

########### Kong Auth Conf #######################

resource "kubernetes_secret" "kong-auth-config" {
  metadata {
    name      = var.kong_auth_conf_secret_name
    namespace = var.namespace
  }

  type = "Opaque"
  data = {
    (var.kong_admin_gui_auth_conf_secret_key) = var.kong_admin_gui_auth_conf
    (var.kong_portal_auth_conf_secret_key)    = var.kong_portal_auth_conf
  }
}

########### Kong Database ########################

resource "kubernetes_secret" "kong-database-password" {
  count = var.kong_database_password != "" ? 1 : 0
  metadata {
    name      = "${var.deployment_name}-${var.kong_database_secret_name}"
    namespace = var.namespace
  }

  type = "Opaque"
  data = {
    (var.kong_database_admin_secret_key) = var.kong_database_password
    (var.kong_database_user_secret_key)  = var.kong_database_password
  }
}

########### TLS Secret ######################

resource "kubernetes_secret" "this-tls-mtls-secret" {

  for_each = var.certs

  metadata {
    name      = each.key
    namespace = var.namespace
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = each.value.crt
    "tls.key" = each.value.key
  }
}
