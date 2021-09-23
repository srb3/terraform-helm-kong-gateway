variable "chart" {
  description = "An object describing the helm release"
  type = object({
    name       = string
    repository = string
    chart      = string
    version    = string
  })
  default = {
    name       = "kong"
    repository = "https://charts.konghq.com"
    chart      = "kong"
    version    = null
  }
}

variable "namespace" {
  type    = string
  default = "default"
}

variable "values" {
  type    = string
  default = ""
}

variable "kong_license" {
  description = "Kong license string passed to the kong instance at run time"
  type        = string
}

variable "kong_superuser_password" {
  description = "The super user password to set"
  type        = string
}

variable "kong_database_password" {
  description = "The super user password to set"
  type        = string
  default     = ""
}

variable "kong_admin_gui_session_conf" {
  description = "A string that represents the kong admin gui session config"
  type        = string
  default     = "{}"
}

variable "kong_portal_session_conf" {
  description = "A string that represents the kong portal gui session config"
  type        = string
  default     = "{}"
}

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
