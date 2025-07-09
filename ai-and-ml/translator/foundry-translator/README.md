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
  - Private DNS zones for privatelink.cognitiveservices.azure.com and privatelink.services.ai.azure.com.
    - If you create a private endpoint in the Azure portal as part of the Azure AI Foundry resource
      creation wizard, the Cognitive Services private DNS entry will not be created 
      automatically and you must manually create it.
    - If you create a private endpoint in the Azure portal after that AI Foundry resource has
      been created, then you will have the option to create all of the necessary private
      DNS entries.

## Architecture

The diagram below illustrates the resources involved in this scenario.

<img src="docs/foundry-translator-architecture.png" width="50%" height="50%" alt="Foundry Translator Architecture">

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

   <img src="docs/01-ai-foundry.png" width="50%" height="50%" alt="Search for AI Foundry">

2. In the "AI Foundry" blade, in the left menu, expand the "Use with AI Foundry" section and
   select "AI Foundry".

   <img src="docs/02-ai-foundry.png" width="50%" height="50%" alt="Select AI Foundry">

3. Select the "Create" button to start creating a new Azure AI Foundry resource.

   <img src="docs/03-ai-foundry.png" width="50%" height="50%" alt="Create AI Foundry">

4. Complete the "Basics" tab by:
     - Selecting the appropriate Subscription in the "Subscription" field.
     - Selecting the appropriate Resource Group in the "Resource group" field.
     - Entering a name for the Azure AI Foundry resource in the "Name" field.
     - Selecting the appropriate region in the "Region" field.
     - Entering a name for the default Azure AI Foundry Project that will be 
       associated with the Azure AI Foundry resource.

   Select the "Next" button to proceed.

   <img src="docs/04-ai-foundry.png" width="50%" height="50%" alt="Create AI Foundry Basics">

5. Complete the "Network" tab by:
     - Selecting "All networks". The resource will be secured in a subsequent step.

   Select the "Next" button to proceed.

   <img src="docs/05-ai-foundry.png" width="50%" height="50%" alt="Create AI Foundry Network">

6. Complete the "Identity" tab by:
     - Selecting the appropriate Managed Identity option. For this example, leave the default
       value of "System assigned" selected.

   Select the "Next" button to proceed.

   Note that your user will be automatically granted the "Azure AI User" role. Any other users
   that will be using the Azure AI Foundry resource should be granted the same role.

   <img src="docs/06-ai-foundry.png" width="50%" height="50%" alt="Create AI Foundry Identity">

7. Complete the "Encryption" tab by:
     - Selecting the "Encrypt data using a customer-managed key" field if desired. For this
       example, leave the field as unselected.

   Select the "Next" button to proceed. 

   <img src="docs/07-ai-foundry.png" width="50%" height="50%" alt="Create AI Foundry Encryption">

8. Complete the "Tags" tab by:
     - Adding any desired resource tags.

   Select the "Next" button to proceed.

   <img src="docs/08-ai-foundry.png" width="50%" height="50%" alt="Create AI Foundry Tags">

9. Complete the process on the "Review + submit" tab by:
     - Selecting the "Create" button to create the resource.

   <img src="docs/09-ai-foundry.png" width="50%" height="50%" alt="Create AI Foundry Finish">

10. Once the deployment is complete, select the "Go to resource" button to open the resource blade.
    
    <img src="docs/10-ai-foundry.png" width="50%" height="50%" alt="Create AI Foundry Finish">

11. In the Azure AI Foundry resource blade, in the left menu, under "Resource Management", select
    "Networking". Then select the "Private endpoint connections" tab, then select the "+ Private
    Endpoint" button.

    <img src="docs/11-private-endpoint.png" width="50%" height="50%" alt="Create Private Endpoint">

12. Complete the "Basics" tab by:
     - Selecting the appropriate Subscription in the "Subscription" field.
     - Selecting the appropriate Resource Group in the "Resource group" field.
     - Entering a name for the Private Endpoint in the "Name" field.
     - Entering a name for the Private Endpoint Network Inteface in the "Network Inteface Name" field.
     - Selecting the appropriate region in the "Region" field.

    Select the "Next" button to proceed.

    <img src="docs/12-private-endpoint.png" width="50%" height="50%" alt="Create Private Endpoint Basics">


13. Complete the "Resource" tab by:
      - Accepting the default values. For "Target sub-resource", "account" should be pre-selected.

    Select the "Next" button to proceed.

    <img src="docs/13-private-endpoint.png" width="50%" height="50%" alt="Create Private Endpoint Resource">

14. Complete the "Virtual Network" tab by:
      - Select the appropriate VNet in the "Virtual network" field.
      - Select the appropriate Subnet to contain the Private Endpoint in the "Subnet" field.
      - Leave the remaining fields with their default values.
    
    Select the "Next" button to proceed.

    <img src="docs/14-private-endpoint.png" width="50%" height="50%" alt="Create Private Endpoint Network">

15. Complete the "DNS" tab by:
      - Select "Yes" for the "Integrate with private DNS zone" field.
      - Ensure there are three configurations listed, for
        - privatelink-cognitiveservices-azure-com
        - privatelink-openai-azure-com
        - privatelink-services-ai-azure-com
    
    Note that for the translator use case, only the Cognitive Services and Services AI DNS entries are 
    actually required.

    Select the "Next" button to proceed.

    <img src="docs/15-private-endpoint.png" width="50%" height="50%" alt="Create Private Endpoint Network">

16. Complete the "Tags" tab by:
      - Adding any desired resource tags.

    Select the "Next" button to proceed.

    <img src="docs/16-private-endpoint.png" width="50%" height="50%" alt="Create Private Endpoint Tags">

17. Complete the process on the "Review + submit" tab by:
     - Selecting the "Create" button to create the resource.

    <img src="docs/17-private-endpoint.png" width="50%" height="50%" alt="Create Private Endpoint Finish">

18. Once the deployment is complete, don't select the "Go to resource" button. Instead, open the Azure
    AI Foundry resource.
    
    <img src="docs/18-private-endpoint.png" width="50%" height="50%" alt="Create AI Foundry Finish">

19. In the Azure AI Foundry blade, in the left menu, under "Resource Management", select "Networking". 
    Select the "Firewalls and virtual networks" tab. In the "Allow access from" field, select "Disabled".
    Under "Exceptions", you can choose to select or not select the "Allow Azure services on the trusted
    services list to access this cognitive services account". For this scenario, this field does not need
    to be selected. Select the "Save" button to save your changes.

    Note that it make take a few minutes for the changes to take effect and the resource to block any 
    public access.

    <img src="docs/19-private-endpoint.png" width="50%" height="50%" alt="Create AI Foundry Network Lockdown">

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

## Azure AI Foundry Portal

To create a custom translator model, use the Azure AI Foundry portal. 

1. Open the Azure AI Foundry portal (https://ai.azure.com) in a browser. Sign in if prompted. Your
   user must have the "Azure AI User" role for the Azure AI Foundry resource. Your computer must be
   able to access the Private Endpoint for Azure AI Foundry resource.

2. Select the "Azure AI Foundry" icon at the top left of the portal to go to the homepage. Select
   the "View all resources" link.

   <img src="docs/20-foundry-portal.png" width="50%" height="50%" alt="AI Foundry Portal Homepage">

3. Search for the Azure AI Foundry Project you previously created and select the name of the project
   to open it.

   <img src="docs/21-foundry-portal.png" width="50%" height="50%" alt="AI Foundry Portal Resources">

4. In the left menu of the project, under "Build and customize", select "Fine-tuning". Select the
   "AI Service fine-tuning" tab. Select the "+ Fine-tune" button.

   <img src="docs/22-foundry-portal.png" width="50%" height="50%" alt="AI Foundry Portal Fine Tuning">

5. In the "Create service fine-tuning" window, select "Translation" and select the "Next" button.

   <img src="docs/23-foundry-portal.png" width="50%" height="50%" alt="AI Foundry Portal Fine Tuning Task">

6. Complete the following:
     - Enter a name for the task in the "Language pair name" field.
     - Select a value in the "Source language" field.
     - Select a value in the "Target language" field.
     - Select a domain in the "Domain" field. 
     - If desired, click the "Advanced settings" link to show additional settings. This includes setting a 
       a label to distinguish between different tasks with the same language pairing.
  
   Select the "Create" button to create the task.

   <img src="docs/24-foundry-portal.png" width="50%" height="50%" alt="AI Foundry Portal Fine Tuning Task">

7. Once the task has been created, you should be in the "Manage Data" blade. Select the "+ Add Data" button.

   <img src="docs/25-foundry-portal.png" width="50%" height="50%" alt="AI Foundry Portal Docs">

8. Much as you would in the Custom Translator portal, you can select the type of files you are uploading,
   and the format they are in. You can then upload the specific training files from your computer, provide
   a name for the document set, and then select the "Add" button.

   <img src="docs/26-foundry-portal.png" width="50%" height="50%" alt="AI Foundry Portal Docs Upload">

9. If successfully uploaded, the document set should appear in the Document List.

   <img src="docs/27-foundry-portal.png" width="50%" height="50%" alt="AI Foundry Portal Docs List">

   Repeat steps 8 and 9 for any additional training documents that are required.

10. Select the "Train model" menu option, then select the "+ Create Model" button.

    <img src="docs/28-foundry-portal.png" width="50%" height="50%" alt="AI Foundry Portal Docs List">

11. Enter a name in the "Model name" field. Select the type of training to be performed (e.g. full or  
    dictionary-only) in the "Training type" field. Select the "Next" button to continue.

    <img src="docs/29-foundry-portal.png" width="50%" height="50%" alt="AI Foundry Portal Train">

12. Select the document set(s) to use for training and select the "Next" button to continue.

    <img src="docs/30-foundry-portal.png" width="50%" height="50%" alt="AI Foundry Portal Train Docs">

13. Select the "Train model" button to start the training.

    <img src="docs/31-foundry-portal.png" width="50%" height="50%" alt="AI Foundry Portal Train Start">

14. You can refresh the "Train Model" blade to monitor the status of the training. The status should change to
    "Training succeeded" once training is complete.

    <img src="docs/32-foundry-portal.png" width="50%" height="50%" alt="AI Foundry Portal Train Status">

15. Select the "Deploy model" menu option, select the trained model that should be deployed, then select
    the "Deploy Model" button.

    <img src="docs/33-foundry-portal.png" width="50%" height="50%" alt="AI Foundry Portal Deploy">

16. Select one or more regions to deploy the model to. Select the "Deploy model" button.

    <img src="docs/34-foundry-portal.png" width="50%" height="50%" alt="AI Foundry Portal Deploy Regions">

17. You can refresh the "Deploy Model" blade to monitor the status of the deployment. The status should
    change to "Deployed" with the region names once deployment is completed.

    <img src="docs/35-foundry-portal.png" width="50%" height="50%" alt="AI Foundry Portal Deploy Regions">

The deployed custom model is now available for use in performing text or document translation. Note that
you must use the endpoint in the format

```
https://<resource-name>.cognitiveservices.azure.com/
```

When performing translations, you can use either the account key or Entra ID authentication.