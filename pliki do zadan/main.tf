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
  # KLUCZOWE USTAWIENIE: Zmusza Terraforma do użycia sesji z azure/login@v2
  use_cli = true
}

resource "azurerm_resource_group" "rg" {
  name     = "RG-DevOps-Lab"
  location = "polandcentral"
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