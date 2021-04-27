$SubscriptionId = Get-VstsInput -Name SubscriptionId -Require;
$PrincipalClientId = Get-VstsInput -Name PrincipalClientId -Require;
$PrincipalClientSecret = Get-VstsInput -Name PrincipalClientSecret -Require;
$AutomationAccountName = Get-VstsInput -Name AutomationAccountName -Require;
$RunbookName = Get-VstsInput -Name RunbookName -Require;
$ResourceGroup = Get-VstsInput -Name ResourceGroup -Require;
$TenantId = Get-VstsInput -Name TenantId -Require;
$FilePath = Get-VstsInput -Name FilePath -Require;


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
    "[ INFO ] Reading payload file $FilePath"
    $payload = Get-Content $FilePath | ConvertFrom-Json
    "[ INFO ] Payload has been loaded."

    <# Login at Azure #>
    "[ INFO ] Logging in to Azure..."
    [SecureString]$userPassword = ConvertTo-SecureString -String $PrincipalClientSecret -AsPlainText -Force
    $userCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $PrincipalClientId, $userPassword
    Add-AzureRmAccount -TenantId $TenantId -ServicePrincipal -SubscriptionId $SubscriptionId -Credential $userCredential 
    Set-AzureRmContext -SubscriptionID $SubscriptionId
    "[ INFO ] Logged in."
    
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
                Write-Host "[ INFO ] Runbook has been successfully executed!"
                break;    
            }
    
            if ($($status).Status -eq "Failed") {
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
