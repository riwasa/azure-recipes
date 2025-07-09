# *****************************************************************************
#
# File:        foundry-translator.ps1
#
# Description: Creates an AI Foundry resource to use with the Azure AI
# Translator service.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# 
# *****************************************************************************

# Get script variables.
# $aiFoundryName = "<ai-foundry-name>"
# $location = "<region>"
# $nicName = "<nic-name>"
# $privateEndpointName = "<private-endpoint-name>"
# $projectName = "<project-name>"
# $resourceGroupName = "<resource-group-name>"
# $subnetName = "<subnet-name>"
# $vNetName = "<vnet-name>"

$aiFoundryName = "rie-demo-trsl-arm-aif"
$location = "canadacentral"
$nicName = "rie-demo-trsl-arm-aif-nic"
$privateEndpointName = "rie-demo-trsl-arm-aif-pe"
$projectName = "rie-demo-trsl-arm-aif-aifp"
$resourceGroupName = "rie-demo-trsl-arm-rg"
$subnetName = "pe"
$vNetName = "rie-demo-trsl-arm-vnet"

# Create an AI Foundry resource.
Write-Host "Creating an AI Foundry resource"

az deployment group create `
  --debug `
  --name "foundry" `
  --resource-group "$resourceGroupName" `
  --template-file "foundry-translator.bicep" `
  --parameters "foundry-translator.parameters.json" `
  --parameters aiFoundryName="$aiFoundryName" `
               location="$location" `
               nicName="$nicName" `
               privateEndpointName="$privateEndpointName" `
               projectName="$projectName" `
               subnetName="$subnetName" `
               vNetName="$vNetName" `
