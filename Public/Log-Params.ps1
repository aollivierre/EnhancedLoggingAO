function Log-Params {
    <#
    .SYNOPSIS
    Logs the provided parameters and their values with the parent function name appended.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$Params
    )

    Begin {
        # Get the name of the parent function
        $parentFunctionName = (Get-PSCallStack)[1].Command

        # Write-EnhancedLog -Message "Starting Log-Params function in $parentFunctionName" -Level "INFO"
    }

    Process {
        try {
            foreach ($key in $Params.Keys) {
                # Append the parent function name to the key
                $enhancedKey = "$parentFunctionName.$key"
                Write-EnhancedLog -Message "$enhancedKey $($Params[$key])" -Level "INFO"
            }
        } catch {
            Write-EnhancedLog -Message "An error occurred while logging parameters in $parentFunctionName $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        # Write-EnhancedLog -Message "Exiting Log-Params function in $parentFunctionName" -Level "INFO"
    }
}
