#local vars
locals {
  environment       = "test"
  location          = "centralindia"
  resource_group    = "AKS-test"
  address_space     = ["10.3.0.0/16"]
  name_prefix       = "private-aks"
  aks_node_prefix   = ["10.3.1.0/24"]
  firewall_prefix   = ["10.3.2.0/24"]
}

resource "azurerm_virtual_network" "vnet" {
  name                = "test-vnet"
  address_space       = local.address_space
  location            = local.location
  resource_group_name = local.resource_group
}

#subnets
resource "azurerm_subnet" "aks" {
  name                 = "snet-${local.name_prefix}-${local.environment}"
  resource_group_name  = local.resource_group
  address_prefixes     = local.aks_node_prefix
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = local.resource_group
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = local.firewall_prefix
}

# #user assigned identity
# resource "azurerm_user_assigned_identity" "base" {
#   resource_group_name = local.resource_group
#   location            = local.location
#   name                = "mi-${local.name_prefix}-${local.environment}"
# }

# #role assignment
# resource "azurerm_role_assignment" "base" {
#   scope                = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/AKS-test"
#   role_definition_name = "Network Contributor"
#   principal_id         = azurerm_user_assigned_identity.base.principal_id
# }

#route table
resource "azurerm_route_table" "base" {
  name                = "rt-${local.name_prefix}-${local.environment}"
  location            = azurerm_virtual_network.vnet.location
  resource_group_name = local.resource_group
}

#route
resource "azurerm_route" "base" {
  name                   = "dg-${local.environment}"
  resource_group_name    = local.resource_group
  route_table_name       = azurerm_route_table.base.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.base.ip_configuration.0.private_ip_address
}

#route table association
resource "azurerm_subnet_route_table_association" "base" {
  subnet_id      = azurerm_subnet.aks.id
  route_table_id = azurerm_route_table.base.id
}

#firewall
resource "azurerm_public_ip" "base" {
  name                = "pip-firewall"
  location            = azurerm_virtual_network.vnet.location
  resource_group_name = local.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "base" {
  name                = "fw-${local.name_prefix}-${local.environment}"
  location            = azurerm_virtual_network.vnet.location
  resource_group_name = local.resource_group
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "ip-${local.name_prefix}-${local.environment}"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.base.id
  }
}

#kubernetes_cluster
resource "azurerm_kubernetes_cluster" "base" {
  name                    = "${local.name_prefix}-${local.environment}"
  location                = local.location
  resource_group_name     = local.resource_group
  dns_prefix              = "dns-${local.name_prefix}-${local.environment}"
  private_cluster_enabled = true

  network_profile {
    network_plugin = "azure"
    outbound_type  = "userDefinedRouting"
  }

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  service_principal {
    client_id     = "xxx"
    client_secret = "xxx"
  }

  # identity {
  #   type                      = "UserAssigned"
  #   # user_assigned_identity_id = azurerm_user_assigned_identity.base.id
  # }

  depends_on = [
      azurerm_route.base,
      # azurerm_role_assignment.base
    ]
}