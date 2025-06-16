# *****************************************************************************
#
# File:        translator.ps1
#
# Description: Creates an Azure AI Translator Account.
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
# $location = "<region>"
# $resourceGroupName = "<resource-group-name>"
# $translatorName = "<translator-name>"

$location = "eastus2"
$resourceGroupName = "rim-demo"
$translatorName = "rim-demo-trsl-trsl"

# Create an Azure AI Translator Account.
Write-Host "Creating an Azure AI Translator Account"

az deployment group create `
  --name "translator" `
  --resource-group "$resourceGroupName" `
  --template-file "translator.bicep" `
  --parameters "translator.parameters.json" `
  --parameters location="$location" `
               translatorName="$translatorName"
