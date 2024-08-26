function Sanitize-LogFilePath {
    [CmdletBinding()]
    param (
        [string]$LogFilePath
    )

    try {
        Write-EnhancedLog -Message "Starting Sanitize-LogFilePath function..." -Level "NOTICE"
        Write-EnhancedLog -Message "Original LogFilePath: $LogFilePath" -Level "INFO"

        # Trim leading and trailing whitespace
        $LogFilePath = $LogFilePath.Trim()
        Write-EnhancedLog -Message "LogFilePath after trim: $LogFilePath" -Level "INFO"

        # Replace multiple spaces with a single space
        $LogFilePath = $LogFilePath -replace '\s+', ' '
        Write-EnhancedLog -Message "LogFilePath after removing multiple spaces: $LogFilePath" -Level "INFO"

        # Replace illegal characters (preserve drive letter and colon)
        if ($LogFilePath -match '^([a-zA-Z]):\\') {
            $drive = $matches[1]
            $LogFilePath = $LogFilePath -replace '[<>:"|?*]', '_'
            $LogFilePath = "$drive`:$($LogFilePath.Substring(2))"
        }
        else {
            # Handle cases where the path doesn't start with a drive letter
            $LogFilePath = $LogFilePath -replace '[<>:"|?*]', '_'
        }
        Write-EnhancedLog -Message "LogFilePath after replacing invalid characters: $LogFilePath" -Level "INFO"

        # Replace multiple backslashes with a single backslash
        $LogFilePath = [System.Text.RegularExpressions.Regex]::Replace($LogFilePath, '\\+', '\')
        Write-EnhancedLog -Message "LogFilePath after replacing multiple slashes: $LogFilePath" -Level "INFO"

        # Ensure the path is still rooted
        if (-not [System.IO.Path]::IsPathRooted($LogFilePath)) {
            throw "The LogFilePath is not rooted: $LogFilePath"
        }

        Write-EnhancedLog -Message "Sanitized LogFilePath: $LogFilePath" -Level "INFO"
        Write-EnhancedLog -Message "Exiting Sanitize-LogFilePath function" -Level "NOTICE"
        return $LogFilePath
    }
    catch {
        Write-EnhancedLog -Message "An error occurred in Sanitize-LogFilePath: $_" -Level "ERROR"
        Handle-Error -ErrorRecord $_
        throw $_  # Re-throw the error after logging it
    }
}
