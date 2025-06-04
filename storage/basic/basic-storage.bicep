// *****************************************************************************
//
// File:        basic-storage.bicep
//
// Description: Creates a basic Storage Account.
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

@description('Indicates whether shared key access is allowed.')
param allowSharedKeyAccess bool = true

@description('The type of the Storage Account.')
@allowed([
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
  'Storage'
  'StorageV2'
])
param kind string = 'StorageV2'

@description('The location of the resources.')
param location string = resourceGroup().location

@description('The minimum TLS version permitted for requests.')
@allowed([
  'TLS1_0'
  'TLS1_1'
  'TLS1_2'
])
param minimumTlsVersion string = 'TLS1_2'

@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'PremiumV2_LRS'
  'PremiumV2_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
  'StandardV2_GRS'
  'StandardV2_GZRS'
  'StandardV2_LRS'
  'StandardV2_ZRS'
])
param skuName string = 'Standard_LRS'

@description('The name of the Storage Account.')
@minLength(3)
@maxLength(24)
param storageAccountName string

// Create a Storage Account.
resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: storageAccountName
  location: location
  kind: kind
  properties: {
    allowSharedKeyAccess: allowSharedKeyAccess
    minimumTlsVersion: minimumTlsVersion
  }
  sku: {
    name: skuName
  }
}
