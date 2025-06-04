// *****************************************************************************
//
// File:        resource-group.bicep
//
// Description: Creates a Resource Group.
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

targetScope = 'subscription'

@description('The name of the Resource Group.')
param name string

@description('The location of the Resource Group.')
param location string

// Create a Resource Group.
resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: name
  location: location
}
