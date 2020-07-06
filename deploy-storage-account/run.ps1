using namespace System.Net


param($Request, $TriggerMetadata)

Import-Module Az.Accounts

Connect-AzAccount -Identity


Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.

$ResourceGroupName= $Request.Body.ResourceGroupName
$Location= $Request.Body.Location
$TemplateFile='arms/01-storage.json'
$rg=$Null


$body = "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."

if (  $ResourceGroupName -and $TemplateFile) {
    #let's verify if the resource group exists
    
     try{
        $rg= Get-AzResourceGroup -Name $ResourceGroupName
    }catch [System.SystemException]{
        Write-Host "Exception: The resouce group does not exist"
        $rg=$Null
    }catch{
        Write-Host "Exception: The resouce group does not exist"
        $rg=$Null
    }


    if($rg){
        New-AzResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName -TemplateFile $TemplateFile
        $region=$rg.Location
        $body="Deployment of resource group:  $ResourceGroupName and the Storarage account  done succesfully in region: $region"
    }else{
        New-AzResourceGroup  $ResourceGroupName -Location $Location
        New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile
        $body="Deployment of resource group:  $ResourceGroupName and the Storarage account done succesfully in region: $Location"
    }
}

# Output
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})