function Validate-LogFilePath {
    [CmdletBinding()]
    param (
        [string]$LogFilePath
    )

    try {
        Write-EnhancedLog -Message "Starting Validate-LogFilePath function..." -Level "NOTICE"
        Write-EnhancedLog -Message "Validating LogFilePath: $LogFilePath" -Level "INFO"

        # Check for invalid characters in the file path
        if ($LogFilePath -match "[<>""|?*]") {
            Write-EnhancedLog -Message "Warning: The LogFilePath contains invalid characters." -Level "WARNING"
        }

        # Check for double backslashes which may indicate an error in path generation
        if ($LogFilePath -match "\\\\") {
            Write-EnhancedLog -Message "Warning: The LogFilePath contains double backslashes." -Level "WARNING"
        }

        Write-EnhancedLog -Message "Validation complete for LogFilePath: $LogFilePath" -Level "INFO"
        Write-EnhancedLog -Message "Exiting Validate-LogFilePath function" -Level "NOTICE"
    }
    catch {
        Write-EnhancedLog -Message "An error occurred in Validate-LogFilePath: $_" -Level "ERROR"
        Handle-Error -ErrorRecord $_
        throw $_  # Re-throw the error after logging it
    }
}
