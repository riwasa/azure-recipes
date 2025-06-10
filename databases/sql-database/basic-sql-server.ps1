# *****************************************************************************
#
# File:        basic-sql-server.ps1
#
# Description: Creates a basic SQL Database Server.
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
$sqlServerName = "<sql-server-name>"

# Get the user principal name for the administrator.
$administratorUPN = Read-Host -Prompt "Enter the user principal name for the SQL administrator"

Write-Host "You entered: $administratorUPN"
$confirmation = Read-Host -Prompt "Is this correct? (Y/n)"

if (($confirmation -ne 'y') -and ($confirmation -ne 'Y') -and ($confirmation -ne '')) {
    Write-Host "Operation cancelled by user."
    exit
}

$entraAdminObjectId = az ad user show --id $administratorUPN --query id --output tsv
Write-Host "Entra administrator ID: $entraAdminObjectId"

if (-not $entraAdminObjectId) {
    Write-Host "Error: Could not find user with UPN '$administratorUPN'. Please check the UPN and try again."
    exit 1
}

$entraAdminPrincipalType = "User"

# Get the public IP address of the machine running this script.
$clientIPAddress = Invoke-RestMethod -Uri "https://api.ipify.org"

$addClientIPToFirewall = $false

# Ask the user if they want to add the current IP address to the SQL server firewall rules.
$confirmation = Read-Host -Prompt "Do you want to add the current IP address ($clientIPAddress) to the SQL server firewall rules? (Y/n)"
if ($confirmation -eq 'y' -or $confirmation -eq 'Y' -or $confirmation -eq '') {
    $addClientIPToFirewall = $true
}

# Create a SQL Database.
Write-Host "Creating a SQL Database"

az deployment group create `
  --name "sql-database" `
  --resource-group "$resourceGroupName" `
  --template-file "basic-sql-database.bicep" `
  --parameters "basic-sql-database.parameters.json" `
  --parameters addClientIPToFirewall=$addClientIPToFirewall `
               clientIPAddress=$clientIPAddress `
               entraAdminDisplayName=$administratorUPN `
               entraAdminObjectId=$entraAdminObjectId `
               entraAdminPrincipalType=$entraAdminPrincipalType `
               location=$location `
               sqlServerName="$sqlServerName"
