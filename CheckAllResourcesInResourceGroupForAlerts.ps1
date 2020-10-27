<#
.SYNOPSIS
    Checks all resources in a given resource group for configured alerts. 
.DESCRIPTION
    Checks all Azure Resources in a given Azure Resource Group for the presence of a configured Alert Rule and 
    reports the status for each Resource. Must be logged into AzureRMAccount and pass in target Resource Group Name.
.PARAMETER ResourceGroupName
Resource Group of resources to check.
.PARAMETER OutputPath
Optional parameter to use if you would like to output the results to a log file. This is the full
path and filename with extnsion to log it to. If there is a existing file, it will append to the file.
There is no logic for container checking or force container creation.
.EXAMPLE
    Outputs whether a resource has rules configured or not.
    CheckAllResourcesInResourceGroupForAlerts -ResourceGroupName "MyGroup"

    ---Output Example---
    2018:02:19:21:15:53:313: Outputting resources found in resourceGroupName group and status of alert rules.
    No rule configured: /subscriptions/d3adb33f-f76d-473c-fefe-1l0v35coff33/resourceGroups/TestDev/providers/Microsoft.Compute/virtualMachines/DevBox
.EXAMPLE
    Outputs whether a resource has rules configured or not to a log.
    CheckAllResourcesInResourceGroupForAlerts -ResourceGroupName "MyGroup" -OutputPath "C:\temp\RulesCheck.txt"

    ---Output Example---
    2018:02:19:21:15:53:313: Outputting resources found in resourceGroupName group and status of alert rules.
    No rule configured: /subscriptions/d3adb33f-f76d-473c-fefe-1l0v35coff33/resourceGroups/TestDev/providers/Microsoft.Compute/virtualMachines/DevBox
.OUTPUTS
    [string]
.Notes
Author: Theo Browning
Blog: http://aka.ms/Theo
Version: 1.2
#>
[CmdletBinding()]
param(
    [parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [string]$OutputPath
)

# function variables
$rulesResult = [System.Collections.ArrayList]@();
$Resources = @(Find-AzureRmResource -ResourceGroupNameEquals $ResourceGroupName);

foreach ($resource in $Resources) {
    if ((Get-AzureRmAlertRule -ResourceGroup $ResourceGroupName -TargetResourceId $resource.ResourceId -WarningAction SilentlyContinue) -eq $null `
            -and $resource.ResourceType -notLike "*alertrule*") {
                
                $tempstr = "No rule configured: {0}" -f $resource.ResourceId;
                $rulesResult.Add($tempstr)  | Out-Null;     
    }
    else {
        if ($resource.ResourceType -notLike "*alertrule*") {
            $tempstr = "Rule is configured: {0}" -f $resource.ResourceId;
            $rulesResult.Add($tempstr) | Out-Null;
        }
        else {
            # Determine what you want to do with rules (rules do not have rules!)
        }
    }
}

if ($OutputPath -eq $null -or $OutputPath -eq "") {
    "`r`n{0}: Outputting resources found in {1} group and status of alert rules." -f (get-date -Format "yyyy:MM:dd:HH:mm:ss:fff"), $ResourceGroupName
    foreach($item in $rulesResult){
    $item;    
    }
}
else{
    "`r`n{0}: Outputting resources found in {1} group and status of alert rules." -f (get-date -Format "yyyy:MM:dd:HH:mm:ss:fff"), $ResourceGroupName | Out-File $OutputPath -Append;    
    foreach($item in $rulesResult){
        $item | Out-File -FilePath $OutputPath -Append -ErrorAction Stop;
    }
}