########### Kong Namespaces ######################

variable "namespace" {
  type = string
}

########### Kong License #########################

variable "kong_license" {
  description = "Kong license string passed to the kong instance at run time"
  type        = string
}

variable "kong_license_secret_name" {
  description = "A string used as the name of the kong license kubernetes secret"
  type        = string
  default     = "kong-enterprise-license"
}

variable "kong_license_secret_key" {
  description = "A string used as the key for the kong license kubernetes secret"
  type        = string
  default     = "license"
}

########### Kong Superuser #######################

variable "kong_superuser_password" {
  description = "The super user password to set"
  type        = string
}

variable "kong_superuser_secret_name" {
  description = "A string used as the name for the kong superuser password"
  type        = string
  default     = "kong-enterprise-superuser-password"
}

variable "kong_superuser_secret_key" {
  description = "A string used as the key for the kong superuser password"
  type        = string
  default     = "password"
}

########### Kong Session Conf ####################

variable "kong_admin_gui_session_conf" {
  description = "A string that represents the kong admin gui session config"
  type        = string
  default     = "{\"cookie_secure\":true,\"storage\":\"kong\",\"cookie_name\":\"admin_session\",\"cookie_lifetime\":31557600,\"cookie_samesite\":\"off\",\"secret\":\"admin\"}"
}

variable "kong_portal_session_conf" {
  description = "A string that represents the kong portal gui session config"
  type        = string
  default     = "{\"storage\":\"kong\",\"cookie_name\":\"portal_session\",\"secret\":\"change-me\",\"cookie_secure\":true}"
}

variable "kong_session_conf_secret_name" {
  description = "A string used as the name of the session conf kubernetes secret"
  type        = string
  default     = "kong-session-config"
}

variable "kong_admin_gui_session_conf_secret_key" {
  description = "A string used as the key of the admin gui session conf kubernetes secret"
  type        = string
  default     = "admin_gui_session_conf"
}

variable "kong_portal_session_conf_secret_key" {
  description = "A string used as the key of the portal session conf kubernetes secret"
  type        = string
  default     = "portal_session_conf"
}

########### Kong Auth Conf #######################

variable "kong_admin_gui_auth_conf" {
  description = "A string that represents the kong admin gui auth config"
  type        = string
  default     = "{}"
}

variable "kong_portal_auth_conf" {
  description = "A string that represents the kong portal gui auth config"
  type        = string
  default     = "{}"
}

variable "kong_auth_conf_secret_name" {
  description = "A string used as the name of the auth conf kubernetes secret"
  type        = string
  default     = "kong-auth-config"
}

variable "kong_admin_gui_auth_conf_secret_key" {
  description = "A string used as the key of the admin gui conf kubernetes secret"
  type        = string
  default     = "admin_gui_auth_conf"
}

variable "kong_portal_auth_conf_secret_key" {
  description = "A string used as the key of the portal auth conf kubernetes secret"
  type        = string
  default     = "portal_auth_conf"
}

########### Kong Database ########################

variable "kong_database_password" {
  description = "The kong database password. Accessed via a kubernetes secret for the kong congfig"
  type        = string
  default     = ""
}

variable "kong_database_secret_name" {
  description = "A string used as the name of the database password kubernetes secret"
  type        = string
  default     = "postgresql"
}

variable "kong_database_secret_key" {
  description = "A string used as the key of the database password kubernetes secret"
  type        = string
  default     = "postgresql-password"
}

########### Control ##############################

variable "deployment_name" {
  description = "The deployment name to prepend to some secrets"
  type        = string
}

########### TLS ##################################

variable "certs" {
  description = "A map of certificate objects"
  type = map(object({
    crt      = string
    key      = string
    yaml_crt = string
    yaml_key = string
  }))
  default = {}
}
