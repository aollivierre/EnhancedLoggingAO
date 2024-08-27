function Remove-LogsFolder {
    <#
    .SYNOPSIS
    Removes the logs folder located at C:\Logs and validates the removal.

    .DESCRIPTION
    The Remove-LogsFolder function removes the logs folder located at C:\Logs using the Remove-EnhancedItem function. It validates the existence of the folder before and after removal to ensure successful deletion.

    .PARAMETER LogFolderPath
    The path of the logs folder to be removed. Default is C:\Logs.

    .PARAMETER MaxRetries
    The maximum number of retries to attempt for removal. Default is 5.

    .PARAMETER RetryInterval
    The interval in seconds between retries. Default is 10 seconds.

    .EXAMPLE
    Remove-LogsFolder
    Removes the logs folder at C:\Logs.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$LogFolderPath = "C:\Logs",

        [Parameter(Mandatory = $false)]
        [int]$MaxRetries = 5,

        [Parameter(Mandatory = $false)]
        [int]$RetryInterval = 10
    )

    Begin {
        Write-EnhancedLog -Message "Starting Remove-LogsFolder function" -Level "Notice"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    Process {
        try {
            # Validate before removal
            $validationResultsBefore = Validate-PathExistsWithLogging -Paths $LogFolderPath

            if ($validationResultsBefore.TotalValidatedFiles -gt 0) {
                Write-EnhancedLog -Message "Attempting to remove logs folder: $LogFolderPath" -Level "INFO"
                
                $removeParams = @{
                    Path               = $LogFolderPath
                    ForceKillProcesses = $true
                    MaxRetries         = $MaxRetries
                    RetryInterval      = $RetryInterval
                }
                Remove-EnhancedItem @removeParams

                # Validate after removal
                $validationResultsAfter = Validate-PathExistsWithLogging -Paths $LogFolderPath

                if ($validationResultsAfter.TotalValidatedFiles -gt 0) {
                    Write-EnhancedLog -Message "Logs folder $LogFolderPath still exists after attempting to remove. Manual intervention may be required." -Level "ERROR"
                }
                else {
                    Write-EnhancedLog -Message "Logs folder $LogFolderPath successfully removed." -Level "CRITICAL"
                }
            }
            else {
                Write-EnhancedLog -Message "Logs folder $LogFolderPath does not exist. No action taken." -Level "WARNING"
            }
        }
        catch {
            Write-EnhancedLog -Message "Error during removal of logs folder at path: $LogFolderPath. Error: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Remove-LogsFolder function" -Level "Notice"
    }
}

# Example usage
# Remove-LogsFolder
