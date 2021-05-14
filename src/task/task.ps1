$SubscriptionId = Get-VstsInput -Name SubscriptionId -Require;
$PrincipalClientId = Get-VstsInput -Name PrincipalClientId -Require;
$PrincipalClientSecret = Get-VstsInput -Name PrincipalClientSecret -Require;
$AutomationAccountName = Get-VstsInput -Name AutomationAccountName -Require;
$RunbookName = Get-VstsInput -Name RunbookName -Require;
$ResourceGroup = Get-VstsInput -Name ResourceGroup -Require;
$TenantId = Get-VstsInput -Name TenantId -Require;
$FilePath = Get-VstsInput -Name FilePath -Require;
$changeContext = Get-VstsInput -Name changeContext;


Write-Host "------------------------------------------"
Write-Host "Subscription Id: $SubscriptionId"
Write-Host "Principal Client ID: $PrincipalClientId"
Write-Host "Runbook Name: $RunbookName"
Write-Host "Automation Account Name: $AutomationAccountName"
Write-Host "Resource Group: $ResourceGroup"
Write-Host "Tenant Id: $TenantId"
Write-Host "File Path: $FilePath"
Write-Host "------------------------------------------"

try {
    <# read Payload File #>
    "[ INFO ] Reading payload file $filePath"
    $payload = Get-Content $filePath | ConvertFrom-Json
    "[ INFO ] Payload has been loaded."

    <# Login at Azure #>
    "[ INFO ] Logging in to Azure..."
    [SecureString]$userPassword = ConvertTo-SecureString -String $PrincipalClientSecret -AsPlainText -Force
    $userCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $PrincipalClientID, $userPassword
    Add-AzureRmAccount -TenantId $Tenantid -ServicePrincipal -SubscriptionId $SubscriptionId -Credential $userCredential 
    "[ INFO ] Logged in."
    
    <# Change context to CMSOperations.pd #>
    if($changeContext -eq $null -or $changeContext -eq "") {
        Set-AzureRmContext -SubscriptionId $SubscriptionId
    }
    else {
        Set-AzureRmContext $changeContext
    }
    
    "[ INFO ] Context updated"

    foreach ($pld in $payload) {
        <# Execute Runbook #>
        $params = @{}
        $pld.psobject.properties | ForEach-Object { $params[$_.Name] = $_.Value }
        
        "[ INFO ] Executing runbook with payload $pld"
        $job = Start-AzureRmAutomationRunbook –AutomationAccountName $AutomationAccountName -Name $RunbookName -ResourceGroupName $ResourceGroup –Parameters $params

        while ($true) {
            <# Waiting until runbook execution is complete #>
            Start-Sleep -s 10
        
            <# Get Job Status #>
            $status = Get-AzureRmAutomationJob -Id $(($job).JobId) -ResourceGroupName $ResourceGroup –AutomationAccountName $AutomationAccountName

            <# Check Job Status #>
            if ($($status).Status -eq "Completed") {
                Write-Host "[ INFO ] Runbook has been has executed!"
                break;    
            }
    
            if ($($status).Status -eq "Failed") {
                Write-Host "[ FAILED ] $($status.Exception)"
                Throw "[ FAILED ] Runbook has been failed!"
            }
        }
    }

}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Error "[ ERROR ] $ErrorMessage"
    exit 1
}
