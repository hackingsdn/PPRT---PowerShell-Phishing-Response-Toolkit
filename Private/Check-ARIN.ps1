﻿#requires -Version 3
function Check-ARIN ()
{
	[CmdletBinding()]
    param (
        [parameter(Mandatory = $true,Position = 1,HelpMessage = 'Please provide a IP address')]
        $ipaddress
    ) 
    <#
            .SYNOPSIS 
            Takes IP address as input and queries ARIN's WHOIS implementation for the IP addresses abuse contact email - RESTFul API 

            .DESCRIPTION
            Takes a IP Address and searches for ARIN's WHOIS abuse contact email for that IP based on registration data
            Returns this contact email address

            .PARAMETER ipaddress
            Specifices the specific IP address belonging to ARIN
   

            .EXAMPLE
            C:\PS> Check-ARIN -ipaddress '146.42.65.82'   

    #>


    #Write-Debug -Message 'ipaddress: ' $ipaddress
    $regx = "[a-z0-9!#\$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#\$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?"

    $rawdata = Invoke-RestMethod -Uri "http://rdap.arin.net/bootstrap/ip/$ipaddress"

   <# $Handle = $rawdata.entities.handle

    $HandleData = Invoke-RestMethod -Uri "https://rdap.arin.net/registry/entity/$Handle"

    $VcardData = $(($HandleData.entities.vcardarray) | select -ExpandProperty SyncRoot)

    $VcardEmailAddress = $VcardData | Select-String -Pattern $regx

    $VcardMatches = $VcardEmailAddress.Matches.Value

    return $VcardMatches#>
 
    for($i = 0;$i -lt ($rawdata.entities.vcardArray).count; $i++)
    {
        foreach ($item in $rawdata.entities.vcardArray.SyncRoot[$i])
        {
            [array]$result += $item
        }
    }

    $parsedresult = $result | Select-String -Pattern $regx

    if ($parsedresult.count -gt 0)
    {
        return $parsedresult
    }
    return 'NO POC FOR ARIN'
}
