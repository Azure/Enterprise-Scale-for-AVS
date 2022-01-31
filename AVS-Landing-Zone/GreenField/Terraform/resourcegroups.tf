# Create the AVS Private Cloud Resource Group
resource "azurerm_resource_group" "privatecloud" {
  name     = "${var.prefix}-PrivateCloud"
  location = var.region
}

# Create the Jumpbox Resource Group
resource "azurerm_resource_group" "jumpbox" {
  name     = "${var.prefix}-Jumpbox"
  location = var.region
}

# Create Network Resource Group
resource "azurerm_resource_group" "network" {
  name     = "${var.prefix}-Network"
  location = var.region
}
