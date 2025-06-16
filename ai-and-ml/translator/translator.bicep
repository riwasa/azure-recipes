// *****************************************************************************
//
// File:        translator.bicep
//
// Description: Creates an Azure AI Translator Account.
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

@description('The location of the resources.')
param location string = resourceGroup().location

@description('Indicates whether public network access is allowed.') 
@allowed([
  'Disabled'
  'Enabled'
]
)
param publicNetworkAccess string = 'Enabled'

@description('The name of the SKU.')
@allowed([
  'F0'
  'S1'
]
)
param skuName string

@description('The name of the Translator Account.')
param translatorName string

// Create an Azure AI Translator Account.
resource translator 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: translatorName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'TextTranslation'
  properties: {
    customSubDomainName: translatorName
    publicNetworkAccess: publicNetworkAccess
  }
  sku: {
    name: skuName
  }
}
