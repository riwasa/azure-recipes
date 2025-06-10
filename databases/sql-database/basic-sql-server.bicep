// *****************************************************************************
//
// File:        basic-sql-server.bicep
//
// Description: Creates a basic SQL Database Server.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// *****************************************************************************

@description('The IP address to add to the SQL Server firewall.')
param addClientIPToFirewall bool = false

@description('The IP address to add to the SQL Server firewall. This is only used if addClientIPToFirewall is true.')
param clientIPAddress string = ''
              
@description('The display name of the Microsoft Entra admin.')
param entraAdminDisplayName string

@description('The object ID of the Microsoft Entra admin.')
param entraAdminObjectId string

@description('The principal type of the Microsoft Entra admin (User or Group).')
@allowed([
  'User'
  'Group'
])
param entraAdminPrincipalType string

@description('The location of the resources.')
param location string = resourceGroup().location

@description('Indicates whether public network access is allowed for the SQL Server.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Indicates whether outbound network access is restricted for the SQL Server.')
@allowed([
  'Disabled'
  'Enabled'
])
param restrictOutboundNetworkAccess string = 'Disabled'

@description('The name of the SQL Server.')
param sqlServerName string

// Create a SQL Server.
resource sqlServer 'Microsoft.Sql/servers@2024-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: entraAdminDisplayName
      principalType: entraAdminPrincipalType
      sid: entraAdminObjectId
      tenantId: subscription().tenantId     
    }
    publicNetworkAccess: publicNetworkAccess
    restrictOutboundNetworkAccess: restrictOutboundNetworkAccess
    version: '12.0'
  }
}

// Allow Azure services to access the SQL Server.
resource allowAllAzureIps 'Microsoft.Sql/servers/firewallRules@2023-08-01' = {
  name: 'AllowAllAzureIps'
  parent: sqlServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Add the client IP to the SQL Server firewall if specified.
resource allowClientIp 'Microsoft.Sql/servers/firewallRules@2023-08-01' = if (addClientIPToFirewall) {
  name: 'AllowClientIp'
  parent: sqlServer
  properties: {
    startIpAddress: clientIPAddress
    endIpAddress: clientIPAddress
  }
}
