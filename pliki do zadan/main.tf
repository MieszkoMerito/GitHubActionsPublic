terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "RG-DevOps-Lab"
  location = "westeurope"
  #location = "polandcentral"
}


# Klaster Kubernetes (AKS) do wdrożenia z kolejnego zadania
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-devops-lab"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-devops"

  default_node_pool {
    name       = "default"
    node_count = 1
    #vm_size    = "Standard_B2s_v2"
    vm_size = "Standard_D2s_v3"
  }

  identity {
    type = "SystemAssigned"
  }
}