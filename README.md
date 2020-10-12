# Runbook Payload Executor
[![Build Status](https://dev.azure.com/primaveratec/SWE_Test/_apis/build/status/devops-extensibility/extensibility-runbookpayloadexecutor?branchName=main)](https://dev.azure.com/primaveratec/SWE_Test/_build/latest?definitionId=41&branchName=main)

![](https://generalpdsharedsa.blob.core.windows.net/runbookpayloadexecutor/icon_min.png)



Executes JSON file payload into Azure Runbook with an Enterprise Application Account.

This taks maps payload keys with powershell runbook parameters input, i.e., define a json with a key "productId", runbook with input parameter "productId" and send it (json) in payload of this task.

#### **Example:**

- Map example:

  ![](https://generalpdsharedsa.blob.core.windows.net/runbookpayloadexecutor/taskrunbook.png)

### Task Input:

- **SubscriptionId**: Enterprise Application Subscription Id with access to Automation Account 
- **PrincipalClientId**: Enterprise Application Client Id
- **PrincipalClientSecret**: Enterprise Application Client Secret
- **AutomationAccountName**: Automation Account's name
- **RunbookName**: Runbook's Name
- **ResourceGroup**: Automation Account Resource Group
- **TenantId**: Azure Tenant Id
- **FilePath**: Path to JSON payload file


