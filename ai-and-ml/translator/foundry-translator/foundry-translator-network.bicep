@description('The name of the AI Foundry resource.')
param aiFoundryName string

@description('The location of the resources.')
param location string = resourceGroup().location

@description('The name of the SKU for the AI Foundry resource.')
param skuName string

// Create an AI Foundry resource.
resource aiFoundry 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: aiFoundryName
  location: location
  kind: 'AIServices'
  properties: {
    customSubDomainName: aiFoundryName
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    publicNetworkAccess: 'Disabled'
  }
  sku: {
    name: skuName
  }  
}
