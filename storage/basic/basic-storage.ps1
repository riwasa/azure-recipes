# *****************************************************************************
#
# File:        basic-storage.ps1
#
# Description: Creates a basic Storage Account.
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
$location = "<region>"
$resourceGroupName = "<resource-group-name>"
$storageAccountName = "<storage-account-name>"

# Create a Storage Account.
Write-Host "Creating a Storage Account"

az deployment group create `
  --name "storage-account" `
  --resource-group "$resourceGroupName" `
  --template-file "basic-storage.bicep" `
  --parameters "basic-storage.parameters.json" `
  --parameters location=$location `
               storageAccountName="$storageAccountName"
