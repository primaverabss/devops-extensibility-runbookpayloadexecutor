$SubscriptionId = Get-VstsInput -Name SubscriptionId -Require
$PrincipalClientId = Get-VstsInput -Name PrincipalClientId -Require
$PrincipalClientSecret = Get-VstsInput -Name PrincipalClientSecret -Require
$AutomationAccountName = Get-VstsInput -Name AutomationAccountName -Require
$RunbookName = Get-VstsInput -Name RunbookName -Require
$ResourceGroup = Get-VstsInput -Name ResourceGroup -Require
$TenantId = Get-VstsInput -Name TenantId -Require
$FilePath = Get-VstsInput -Name FilePath -Require
$changeContext = Get-VstsInput -Name changeContext

Write-Host "------------------------------------------"
Write-Host "Subscription Id: $SubscriptionId"
Write-Host "Principal Client ID: $PrincipalClientId"
Write-Host "Runbook Name: $RunbookName"
Write-Host "Automation Account Name: $AutomationAccountName"
Write-Host "Resource Group: $ResourceGroup"
Write-Host "Tenant Id: $TenantId"
Write-Host "File Path: $FilePath"
Write-Host "------------------------------------------"

# Ler Payload
if (!(Test-Path $FilePath)) {
    Write-Error "[ ERROR ] Payload file not found: $FilePath"
    exit 1
}

Write-Host "[ INFO ] Reading payload file $FilePath"
$payload = Get-Content $FilePath | ConvertFrom-Json
Write-Host "[ INFO ] Payload has been loaded."

# Login no Azure
Write-Host "[ INFO ] Logging in to Azure..."
az login --service-principal -u $PrincipalClientId -p $PrincipalClientSecret --tenant $TenantId
if ($LASTEXITCODE -ne 0) {
    Write-Error "[ ERROR ] Azure login failed"
    exit 1
}
Write-Host "[ INFO ] Logged in."

# Definir contexto
if ([string]::IsNullOrEmpty($changeContext)) {
    az account set --subscription $SubscriptionId
} else {
    az account set --subscription $changeContext
}
Write-Host "[ INFO ] Context updated"

az config set core.only_show_errors=yes
az config set core.allow_experimental=true
az config set core.allow_bundled_experimental=true
az config set extension.use_dynamic_install=yes_without_prompt
az config set extension.dynamic_install_allow_preview=true

Write-Host "[ INFO ] Installing Azure CLI extension"
az extension add --name "automation"

$originalWarningPreference = $WarningPreference
$WarningPreference = "SilentlyContinue"

# Iterar sobre payloads e executar o runbook
foreach ($pld in $payload) {
    Write-Host "[ INFO ] Executing runbook with payload: $pld"
    
    $parameterValue = ($pld.psobject.properties | ForEach-Object { "$($_.Name)=\""$($_.Value)\""" }).Trim()
    Write-Host "[ INFO ] Parameters: $parameterValue"

    $jobId = az automation runbook start `
        --resource-group $ResourceGroup `
        --automation-account-name $AutomationAccountName `
        --name $RunbookName `
        --parameters $parameterValue `
        --query id -o tsv

    if ([string]::IsNullOrEmpty($jobId)) {
        Write-Error "[ ERROR ] Failed to start runbook"
        exit 1
    }
    
    while ($true) {
        Start-Sleep -Seconds 10
        
        $status = az automation job show --ids $jobId --query status -o tsv 2>$null
        
        if ($status -eq "Completed") {
            Write-Host "[ INFO ] Runbook has been executed!"
            break
        }
        
        if ($status -eq "Failed") {
            Write-Error "[ ERROR ] Runbook execution failed"
            exit 1
        }
    }
}

$WarningPreference = $originalWarningPreference