function Log-Params {
    <#
    .SYNOPSIS
    Logs the provided parameters and their values.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$Params
    )

    Begin {
        # Write-EnhancedLog -Message "Starting Log-Params function" -Level "INFO"
    }

    Process {
        try {
            foreach ($key in $Params.Keys) {
                Write-EnhancedLog -Message "$key $($Params[$key])" -Level "INFO"
            }
        } catch {
            Write-EnhancedLog -Message "An error occurred while logging parameters: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        # Write-EnhancedLog -Message "Exiting Log-Params function" -Level "INFO"
    }
}
