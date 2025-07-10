# Foundry Custom Translation

The scripts in this folder create an Azure AI Foundry resource for the purpose of text and
document translation using a custom model. The resource is locked down to only allow access 
via a private endpoint, whether building custom models in the AI Foundry portal, or 
performing translations via the API.

The training and deployment of custom translation models can be done from the Azure AI Foundry 
portal. Open the AI Foundry Project in the AI Foundry portal and go to Fine-tuning / AI Service 
fine-tuning.

This document outlines two options for creating resources:
  1. Manually creating resources in the Azure portal.
  2. Using Bicep scripts to create resources from the command line.

## Requirements

To perform custom translation behind a private endpoint, the following are required:
  - An Azure AI Foundry resource. 
    - If you use a Translator resource, then you have to allow public access to create a
      Custom Translator workspace. After that, you can place a the Translator resource 
      behind a private endpoint.
    - With an Azure AI Foundry resource, that resource can be behind a private endpoint
      at all times.
    - Note that the Azure AI Foundry resource was previously known as a Cognitive Services
      Multi-Service Account or an AI Services resource.
  - Resource key authentication.
    - The APIs used to manage custom translation only work with the resource key and not
      Entra ID authentication. This is true regardless of whether you use an Azure AI 
      Foundry resource or a Translator resource.
    - Note that you can use Entra ID authentication when performing translations, but to
      manage, train, and deploy custom models, you must allow resource key access.
  - Private DNS zones for privatelink.cognitiveservices.azure.com, 
    privatelink.openai.azure.com, and privatelink.services.ai.azure.com.
    - If you create a private endpoint in the Azure portal as part of the Azure AI Foundry resource
      creation wizard, the Cognitive Services private DNS entry will not be created 
      automatically and you must manually create it.
    - If you create a private endpoint in the Azure portal after that AI Foundry resource has
      been created, then you will have the option to create all of the necessary private
      DNS entries.

## Architecture

The diagram below illustrates the resources involved in this scenario.

![Foundry Translator Architecture](docs/foundry-translator-architecture.png)

An Azure AI Foundry resource provides access to the translator APIs and functionality, including custom translation.
This resource is secured behind a private endpoint.

An Azure AI Foundry Project is used in the Azure AI Foundry portal (https://ai.azure.com) to perform translator
fine-tuning, i.e. building a custom translation model.

There are two private DNS zones used to resolve calls to the Azure AI Foundry resource.

Users creating custom translation models do so through the Azure AI Foundry portal. The user must have a network path
to the private endpoint for the Azure AI Foundry resource. For example, the user can open the Azure AI Foundry portal
via a browser in a jump box VM in the same VNet as the private endpoint for the Azure AI Foundry resource.

The same is true for applications using the Azure AI Foundry resource for translations. The application must have a
network path to the private endpoint for the Azure AI Foundry resource.

## Prerequisites

To run either the Manual Setup or use the Bicep script, you must have the following:

- Sufficient permissions to create resources.
- A Resource Group.
- A Virtual Network with a subnet to contain Private Endpoints.

## Manual Setup

To manually setup resources, you will need access to the Azure portal (https://portal.azure.com).

1. In the Azure portal, in the search bar at the top of the page, enter "ai foundry". In the 
   search results that are returned, under "Services", select "Azure AI Foundry".

   ![Search for AI Foundry](docs/01-ai-foundry.png)

2. In the "AI Foundry" blade, in the left menu, expand the "Use with AI Foundry" section and
   select "AI Foundry".

   ![Select AI Foundry](docs/02-ai-foundry.png)

3. Select the "Create" button to start creating a new Azure AI Foundry resource.

   ![Create AI Foundry](docs/03-ai-foundry.png)

4. Complete the "Basics" tab by:
     - Selecting the appropriate Subscription in the "Subscription" field.
     - Selecting the appropriate Resource Group in the "Resource group" field.
     - Entering a name for the Azure AI Foundry resource in the "Name" field.
     - Selecting the appropriate region in the "Region" field.
     - Entering a name for the default Azure AI Foundry Project that will be 
       associated with the Azure AI Foundry resource.

   Select the "Next" button to proceed.

   ![Create AI Foundry Basics](docs/04-ai-foundry.png)

5. Complete the "Network" tab by:
     - Selecting "All networks". The resource will be secured in a subsequent step.

   Select the "Next" button to proceed.

   ![Create AI Foundry Network](docs/05-ai-foundry.png)

6. Complete the "Identity" tab by:
     - Selecting the appropriate Managed Identity option. For this example, leave the default
       value of "System assigned" selected.

   Select the "Next" button to proceed.

   Note that your user will be automatically granted the "Azure AI User" role. Any other users
   that will be using the Azure AI Foundry resource should be granted the same role.

   ![Create AI Foundry Identity](docs/06-ai-foundry.png)

7. Complete the "Encryption" tab by:
     - Selecting the "Encrypt data using a customer-managed key" field if desired. For this
       example, leave the field as unselected.

   Select the "Next" button to proceed. 

   ![Create AI Foundry Encryption](docs/07-ai-foundry.png)

8. Complete the "Tags" tab by:
     - Adding any desired resource tags.

   Select the "Next" button to proceed.

   ![Create AI Foundry Tags](docs/08-ai-foundry.png)

9. Complete the process on the "Review + submit" tab by:
     - Selecting the "Create" button to create the resource.

   ![Create AI Foundry Finish](docs/09-ai-foundry.png)

10. Once the deployment is complete, select the "Go to resource" button to open the resource blade.
    
    ![Create AI Foundry Finish](docs/10-ai-foundry.png)

11. In the Azure AI Foundry resource blade, in the left menu, under "Resource Management", select
    "Networking". Then select the "Private endpoint connections" tab, then select the "+ Private
    Endpoint" button.

    ![Create Private Endpoint](docs/11-private-endpoint.png)

12. Complete the "Basics" tab by:
     - Selecting the appropriate Subscription in the "Subscription" field.
     - Selecting the appropriate Resource Group in the "Resource group" field.
     - Entering a name for the Private Endpoint in the "Name" field.
     - Entering a name for the Private Endpoint Network Inteface in the "Network Inteface Name" field.
     - Selecting the appropriate region in the "Region" field.

    Select the "Next" button to proceed.

    ![Create Private Endpoint Basics](docs/12-private-endpoint.png)


13. Complete the "Resource" tab by:
      - Accepting the default values. For "Target sub-resource", "account" should be pre-selected.

    Select the "Next" button to proceed.

    ![Create Private Endpoint Resource](docs/13-private-endpoint.png)

14. Complete the "Virtual Network" tab by:
      - Select the appropriate VNet in the "Virtual network" field.
      - Select the appropriate Subnet to contain the Private Endpoint in the "Subnet" field.
      - Leave the remaining fields with their default values.
    
    Select the "Next" button to proceed.

    ![Create Private Endpoint Network](docs/14-private-endpoint.png)

15. Complete the "DNS" tab by:
      - Select "Yes" for the "Integrate with private DNS zone" field.
      - Ensure there are three configurations listed, for
        - privatelink-cognitiveservices-azure-com
        - privatelink-openai-azure-com
        - privatelink-services-ai-azure-com
    
    Select the "Next" button to proceed.

    ![Create Private Endpoint Network](docs/15-private-endpoint.png)

16. Complete the "Tags" tab by:
      - Adding any desired resource tags.

    Select the "Next" button to proceed.

    ![Create Private Endpoint Tags](docs/16-private-endpoint.png)

17. Complete the process on the "Review + submit" tab by:
     - Selecting the "Create" button to create the resource.

    ![Create Private Endpoint Finish](docs/17-private-endpoint.png)

18. Once the deployment is complete, don't select the "Go to resource" button. Instead, open the Azure
    AI Foundry resource.
    
    ![Create AI Foundry Finish](docs/18-private-endpoint.png)

19. In the Azure AI Foundry blade, in the left menu, under "Resource Management", select "Networking". 
    Select the "Firewalls and virtual networks" tab. In the "Allow access from" field, select "Disabled".
    Under "Exceptions", you can choose to select or not select the "Allow Azure services on the trusted
    services list to access this cognitive services account". For this scenario, this field does not need
    to be selected. Select the "Save" button to save your changes.

    Note that it make take a few minutes for the changes to take effect and the resource to block any 
    public access.

    ![Create AI Foundry Network Lockdown](docs/19-private-endpoint.png)

At this point, the Azure AI Foundry resource has been set up. Skip to the "Azure AI Foundry Portal" section of this
document.

## Bicep Setup

The Bicep script and associated parameters file are run from a PowerShell script, foundry-translator.ps1. This
requires PowerShell and the Azure CLI to be installed. Alternatively, you can write your own script to execute
the Bicep script.

Edit the foundry-translator.ps1 file and change the following values:

| Variable Name | Description |
| ------------- | ----------- |
| $aiFoundryName | The name of the Azure AI Foundry resource |
| $location | The region to deploy the resources to (e.g. canadacentral) |
| $nicName | The name of the Network Inteface for the Private Endpoint |
| $privateEndpointName | The name of the Private Endpoint |
| $projectName | The name of the Azure AI Foundry Project |
| $resourceGroupName | The name of the pre-existing Resource Group |
| $subnetName | The name of the Subnet for Private Endpoints in the pre-existing VNet |
| $vNetName | The name of the pre-existing Virtual Network |

Run the PowerShell file.

```
.\foundry-translator.ps1
```

Once the file has finished running, all the resources should be created in the Resource Group.

Note that network ACLs for the Azure AI Foundry resource are updated in a separate Bicep script, to avoid 
the error "403. Traffic is not from an approved endpoint." when trying to perform fine-tuning. This error
appears if you set the network ACLs at the same time you create the Azure AI Foundry resource.

## Azure AI Foundry Portal

To create a custom translator model, use the Azure AI Foundry portal. 

1. Open the Azure AI Foundry portal (https://ai.azure.com) in a browser. Sign in if prompted. Your
   user must have the "Azure AI User" role for the Azure AI Foundry resource. Your computer must be
   able to access the Private Endpoint for Azure AI Foundry resource.

2. Select the "Azure AI Foundry" icon at the top left of the portal to go to the homepage. Select
   the "View all resources" link.

   ![AI Foundry Portal Homepage](docs/20-foundry-portal.png)

3. Search for the Azure AI Foundry Project you previously created and select the name of the project
   to open it.

   ![AI Foundry Portal Resources](docs/21-foundry-portal.png)

4. In the left menu of the project, under "Build and customize", select "Fine-tuning". Select the
   "AI Service fine-tuning" tab. Select the "+ Fine-tune" button.

   ![AI Foundry Portal Fine Tuning](docs/22-foundry-portal.png)

5. In the "Create service fine-tuning" window, select "Translation" and select the "Next" button.

   ![AI Foundry Portal Fine Tuning Task](docs/23-foundry-portal.png)

6. Complete the following:
     - Enter a name for the task in the "Language pair name" field.
     - Select a value in the "Source language" field.
     - Select a value in the "Target language" field.
     - Select a domain in the "Domain" field. 
     - If desired, click the "Advanced settings" link to show additional settings. This includes setting a 
       a label to distinguish between different tasks with the same language pairing.
  
   Select the "Create" button to create the task.

   ![AI Foundry Portal Fine Tuning Task](docs/24-foundry-portal.png)

7. Once the task has been created, you should be in the "Manage Data" blade. Select the "+ Add Data" button.

   ![AI Foundry Portal Docs](docs/25-foundry-portal.png)

8. Much as you would in the Custom Translator portal, you can select the type of files you are uploading,
   and the format they are in. You can then upload the specific training files from your computer, provide
   a name for the document set, and then select the "Add" button.

   ![AI Foundry Portal Docs Upload](docs/26-foundry-portal.png)

9. If successfully uploaded, the document set should appear in the Document List.

   ![AI Foundry Portal Docs List](docs/27-foundry-portal.png)

   Repeat steps 8 and 9 for any additional training documents that are required.

10. Select the "Train model" menu option, then select the "+ Create Model" button.

    ![AI Foundry Portal Docs List](docs/28-foundry-portal.png)

11. Enter a name in the "Model name" field. Select the type of training to be performed (e.g. full or  
    dictionary-only) in the "Training type" field. Select the "Next" button to continue.

    ![AI Foundry Portal Train](docs/29-foundry-portal.png)

12. Select the document set(s) to use for training and select the "Next" button to continue.

    ![AI Foundry Portal Train Docs](docs/30-foundry-portal.png)

13. Select the "Train model" button to start the training.

    ![AI Foundry Portal Train Start](docs/31-foundry-portal.png)

14. You can refresh the "Train Model" blade to monitor the status of the training. The status should change to
    "Training succeeded" once training is complete.

    ![AI Foundry Portal Train Status](docs/32-foundry-portal.png)

15. Select the "Deploy model" menu option, select the trained model that should be deployed, then select
    the "Deploy Model" button.

    ![AI Foundry Portal Deploy](docs/33-foundry-portal.png)

16. Select one or more regions to deploy the model to. Select the "Deploy model" button.

    ![AI Foundry Portal Deploy Regions](docs/34-foundry-portal.png)

17. You can refresh the "Deploy Model" blade to monitor the status of the deployment. The status should
    change to "Deployed" with the region names once deployment is completed.

    ![AI Foundry Portal Deploy Regions](docs/35-foundry-portal.png)

The deployed custom model is now available for use in performing text or document translation. Note that
you must use the endpoint in the format

```
https://<resource-name>.cognitiveservices.azure.com/
```

When performing translations, you can use either the account key or Entra ID authentication.