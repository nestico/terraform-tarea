resource "azurerm_resource_group" "diplomado" {
  name     = var.name
  location = var.location

}

variable "client_id" {

}
# variable "server_app_id" {

# }
# variable "server_app_secret" {

# }
variable "client_secret" {

}

variable "tenant_id" {

}

variable "name" {
}

variable "location" {
}

resource "azurerm_virtual_network" "vnet" {
  name                = "sample-network"
  address_space       = ["10.0.0.0/16"] //verificar no este ocupada en la subscripcion
  location            = azurerm_resource_group.diplomado.location
  resource_group_name = azurerm_resource_group.diplomado.name
  //despues del arg.diplomado debe llevar el mismo nombre que fue asignado arriba al RS
  //location esta en central canada
}

resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.diplomado.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"] //verificar no este ocupada en la subscripcion
}
resource "azurerm_container_registry" "acr" {
  name                = "ContainerRegistryErnesto"
  resource_group_name = azurerm_resource_group.diplomado.name
  location            = azurerm_resource_group.diplomado.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "kubernetescluster" {
  name                = "aksdiplomado"
  resource_group_name = azurerm_resource_group.diplomado.name
  location            = azurerm_resource_group.diplomado.location
  dns_prefix          = "aks1"
  kubernetes_version  = "1.18.14"

  default_node_pool {
    name                = "default"
    node_count          = 1
    vm_size             = "Standard_D2_v2"
    vnet_subnet_id      = azurerm_subnet.subnet.id
    enable_auto_scaling = true
    max_count           = 2
    min_count           = 1
  }
  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }
  //role_based_access_control_enable = true

  azure_active_directory_role_based_access_control {
    client_app_id     = var.client_id
    server_app_id     = var.client_id
    server_app_secret = var.client_secret
    tenant_id         = var.tenant_id
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }
}






# resource "azurerm_public_ip" "publicip" {
#  name                = "public-ip"
#  resource_group_name = azurerm_resource_group.diplomado.name
#  location            = azurerm_resource_group.diplomado.location
#  allocation_method   = "Static"
# }

# resource "azurerm_mssql_server" "sqlserver" {
#  name                         = "sqlserver-dbdiploma"
#  resource_group_name          = azurerm_resource_group.diplomado.name
#  location                     = azurerm_resource_group.diplomado.location
#  version                      = "12.0"
#  administrator_login          = "theadminator"
#  administrator_login_password = "SuperSecret11secret"
# }
