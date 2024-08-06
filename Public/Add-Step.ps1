function Add-Step {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Description,

        [Parameter(Mandatory = $true)]
        [ScriptBlock]$Action
    )

    Begin {
        Write-EnhancedLog -Message "Starting Add-Step function" -Level "INFO"
        Log-Params -Params @{
            Description = $Description
            Action = $Action.ToString()
        }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Adding step: $Description" -Level "INFO"
            $global:steps.Add([PSCustomObject]@{ Description = $Description; Action = $Action })
        } catch {
            Write-EnhancedLog -Message "An error occurred while adding step: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Add-Step function" -Level "INFO"
    }
}

# Example usage
# Add-Step -Description "Sample step description" -Action { Write-Output "Sample action" }
