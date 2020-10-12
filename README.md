# Runbook Payload Executor
[![Build Status](https://dev.azure.com/primaveratec/SWE_Test/_apis/build/status/devops-extensibility/extensibility-runbookpayloadexecutor?branchName=main)](https://dev.azure.com/primaveratec/SWE_Test/_build/latest?definitionId=41&branchName=main)

![](https://generalpdsharedsa.blob.core.windows.net/runbookpayloadexecutor/icon_min.png)



Executes JSON file payload into Azure Runbook with Enterprise Application Account.



### Task Input:

- **SubscriptionId**: Enterprise Application Subscription Id with access to Automation Account 
- **PrincipalClientId**: Enterprise Application Client Id
- **PrincipalClientSecret**: Enterprise Application Client Secret
- **AutomationAccountName**: Automation Account's name
- **RunbookName**: Runbook's Name
- **ResourceGroup**: Automation Account Resource Group
- **TenantId**: Azure Tenant Id
- **FilePath**: Path to JSON payload file



#### **Example:**

- JSON file example:

  ![](https://generalpdsharedsa.blob.core.windows.net/runbookpayloadexecutor/1.PNG)

- Execution:

  ![](https://generalpdsharedsa.blob.core.windows.net/runbookpayloadexecutor/2.png)

  ###### ![](https://generalpdsharedsa.blob.core.windows.net/runbookpayloadexecutor/3.png)

![](https://generalpdsharedsa.blob.core.windows.net/runbookpayloadexecutor/4.PNG)

![](https://generalpdsharedsa.blob.core.windows.net/runbookpayloadexecutor/5.PNG)

![](https://generalpdsharedsa.blob.core.windows.net/runbookpayloadexecutor/6.PNG)