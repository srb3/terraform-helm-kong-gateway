# terraform-helm-kong-gateway

A terraform module for deploying Kong gateway via helm.
This module is defaulted to use the official [Kong helm](https://charts.konghq.com/)
charts. The documentation for those charts can be found [here](https://github.com/Kong/charts/blob/master/charts/kong/README.md).


## Usage

### Using module defaults

#### Hybrid Mode Deployments

##### Prerequisites

- Helm provider
- Create Kong namespace/s
- Certificates for Kong hybrid mode clustering
- Create Helm values file for control Plane
- Create Helm values file for data Plane

###### Helm Provider

You will need to configure the helm provider to use this module

```HCL
provider "helm" {
  kubernetes {
    config_path = var.kube_config
  }
}
```

###### Kong Namespaces

The officail Kong helm charts expect you to provide them a namespace
into which it will deploy the Kong gateway resources.
The charts do not create or manager this namespace for you, so it needs
to be taken care of outside this terraform module.
One option is to manage the namespaces in the terraform code that calls this module.
Note to do this you will need to configure the terraform Kubernetes provider.

```HCL
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
```

###### Kong Hybrid Mode Clustering

Deploying Kong in hybrid mode means running separate control plane and
data plane instances. These instances communicate via two mTLS connections,
by default over ports 8005 (configuration) and 8006 (telemetry).
In order to establish this communication a set of certificates needs to be created,
using one of two methods. The two methods are shared mode clustering and PKI
mode clustering. You can read more about the two approaches [here](https://docs.konghq.com/gateway-oss/2.5.x/hybrid-mode/#configuration-properties)

If you want a simple way to generate and use shared mode clustering certificates
in terraform, you can use the [terraform-kong-cluster-tls](https://registry.terraform.io/modules/srb3/cluster-tls/kong/latest)
module. There is an example of using cluster tls module below

```HCL
# This module call will automatically generate the
# required shared mode certificates
module "tls" {
  source = "srb3/cluster-tls/kong"
}

# You will then need to create a local variable
# containing the certificate and key values as will
# as their yaml keys for the official Kong helm chart values file
locals {
  certs = {
    # the key of this map item will be the name of the kubernetes secret, and
    # the location on the file system where this secret is mounted
    # e.g. /etc/secrets/kong-cluster-cert/ 
    "kong-cluster-cert" = {
      # The certificate string generated by the cluster-tls module
      crt      = module.tls.cert.kong-cluster.cert_pem
      # The certificate private key string generated by the cluster-tls module
      key      = module.tls.key.kong-cluster.private_key_pem
      # The name for the clustering certificate in the Kong helm values file
      # see https://github.com/Kong/charts/tree/master/charts/kong#hybrid-mode
      yaml_crt = "cluster_cert"
      # The name for the clustering certificate private key in the Kong helm
      # values file see https://github.com/Kong/charts/tree/master/charts/kong#hybrid-mode
      yaml_key = "cluster_cert_key"
    }
  }
}
```

###### Kong Control / Data plane values

The helm-kong-gateway module expects the user to pass through a yaml string
of values to use as inputs to the official Kong helm charts. You could either
pass these through as a static file:

```bash
cat kong_values.yaml
env:
  # Database settings
  database: "postgres"
  pg_host: kong-traditional-postgresql
  pg_user: kong
  pg_database: kong
  pg_password:
    valueFrom:
      secretKeyRef:
        name: kong-traditional-postgresql
        key: postgresql-password
...
...
...
```

Then in terraform read in that file and pass it to the gateway module.

```HCL
module "kong" {
  source                      = "srb3/kong-gateway/helm"
  namespace                   = kubernetes_namespace.control-plane.metadata[0].name
  values                      = file("files/kong_values.yaml")
```

Or you could use the terraform [templatefile](https://www.terraform.io/docs/language/functions/templatefile.html)
function to create dynamic Kong values files. Example of calling the templatefile
function is outlined below:

```HCL
  cp_values = templatefile("${path.module}/templates/cp_values.yaml", {
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
```

Template file example is [here](./examples/default/templates/control_plane_values.yaml)

###### Calling the module

Once you have created the local variable for clustering certs and helm values
you can pass them through to the helm-kong-gateway module

```HCL
module "kong_cp" {
  source                      = "srb3/kong-gateway/helm"
  namespace                   = kubernetes_namespace.control-plane.metadata[0].name
  values                      = local.cp_values
  kong_superuser_password     = "mysuperuserpass"
  kong_admin_gui_session_conf = local.kong_admin_gui_session_conf
  kong_license                = file("~/.my_kong_license")
  kong_database_password      = "mysecretdbpass"
  certs                       = local.certs
}

module "kong_dp" {
  source       = "srb3/kong-gateway/helm"
  namespace    = kubernetes_namespace.data-plane.metadata[0].name
  values       = local.dp_values
  kong_license = file("~/.my_kong_license")
  certs        = local.certs
}
```

Complete examples are kept in the [examples](./examples) directory

###### Miscellaneous

Example of kong_admin_gui_session_conf:

```HCL
locals {
  kong_admin_gui_session_conf   = "{\"cookie_name\":\"admin_session\",\"storage\":\"kong\",\"cookie_samesite\":\"off\",\"cookie_secure\":false,\"secret\":\"cookiesecret\"}"
}
```

## Testing

Test for this module are written in Inspec. All
tests are located in the [test](./test/) directory. Tests are automated
via the [Makefile](./Makefile) with `make test`.
To deploy the Kong Gateway so that you can run the tests against it you will
need to run `make build`. To clean up after deployment and testing run `make clean`.
Running `make` will execute the following:

- make build (which calls terraform apply on the [default example code](./examples/default)
- make test (which builds an Inspec based container with the k8s plugin, then
             executes the inspec tests)
- make clean (calls terraform destroy)
