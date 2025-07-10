@description('The name of the AI Foundry resource.')
param aiFoundryName string

@description('The location of the resources.')
param location string = resourceGroup().location

@description('The name of the network interface for the private endpoint.')
param nicName string

@description('The name of the private endpoint for the AI Foundry resource.')
param privateEndpointName string

@description('The name of the default Foundry project.')
param projectName string

@description('The name of the SKU for the AI Foundry resource.')
param skuName string

@description('The name of the subnet where the private endpoint will be created.')
param subnetName string

@description('The name of the virtual network where the private endpoint will be created.')
param vNetName string

// Create an AI Foundry resource.
resource aiFoundry 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: aiFoundryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'AIServices'
  properties: {
    allowProjectManagement: true
    associatedProjects: [
      projectName
    ]
    customSubDomainName: aiFoundryName
    defaultProject: projectName
    disableLocalAuth: false
    publicNetworkAccess: 'Disabled'
  }
  sku: {
    name: skuName
  }
}

// Create a project within the AI Foundry resource.
resource aiFoundryProject 'Microsoft.CognitiveServices/accounts/projects@2025-04-01-preview' = {
  name: projectName
  parent: aiFoundry
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    description: 'Default project created with the resource'
    displayName: projectName
  }
}

// Get the Virtual Network and the Subnet.
resource vNet 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
  name: vNetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' existing = {
  name: subnetName
  parent: vNet
}

// Create private DNS zones and VNet links for the private endpoint.
resource cognitiveServicesPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: 'privatelink.cognitiveservices.azure.com'
  location: 'global'
}

resource cognitiveServicesPrivateDnsZoneVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  name: vNetName
  parent: cognitiveServicesPrivateDnsZone
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vNet.id
    }
  }
}

resource openAiPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: 'privatelink.openai.azure.com'
  location: 'global'
}

resource openAiPrivateDnsZoneVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  name: vNetName
  parent: openAiPrivateDnsZone
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vNet.id
    }
  }
}

resource servicesAiPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: 'privatelink.services.ai.azure.com'
  location: 'global'
}

resource servicesAiPrivateDnsZoneVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  name: vNetName
  parent: servicesAiPrivateDnsZone
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vNet.id
    }
  }
}

// Create a private endpoint for the AI Foundry resource.
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-07-01' = {
  name: privateEndpointName
  location: location
  properties: {
    customNetworkInterfaceName: nicName
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          groupIds: [
            'account'
          ]
          privateLinkServiceId: aiFoundry.id
        }
      }
    ]
    subnet: {
      id: subnet.id
    }
  }
}

// Create a private DNS zone group for the private endpoint.
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-07-01' = {
  name: 'default'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-cognitiveservices-azure-com'
        properties: {
          privateDnsZoneId: cognitiveServicesPrivateDnsZone.id
        }
      }
      {
        name: 'privatelink-openai-azure-com'
        properties: {
          privateDnsZoneId: openAiPrivateDnsZone.id
        }
      }
      {
        name: 'privatelink-services-ai-azure-com'
        properties: {
          privateDnsZoneId: servicesAiPrivateDnsZone.id
        }
      }
    ]
  }
}
