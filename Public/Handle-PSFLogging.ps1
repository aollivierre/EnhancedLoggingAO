function Handle-PSFLogging {
    [CmdletBinding()]
    param (
        [string]$systemSourcePath = "C:\Windows\System32\config\systemprofile\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\",
        [string]$PSFPath = "C:\Logs\PSF"
    )

    try {
        # Get the current username and script name
        $username = if ($env:USERNAME) { $env:USERNAME } else { "UnknownUser" }
        $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.ScriptName)
        if (-not $scriptName) {
            $scriptName = "UnknownScript"
        }

        # Get the current date for folder creation
        $currentDate = Get-Date -Format "yyyy-MM-dd"
        $logFolderPath = "$PSFPath\$currentDate\$scriptName"

        # Ensure the destination directory exists
        if (-not (Test-Path -Path $logFolderPath)) {
            New-Item -ItemType Directory -Path $logFolderPath -Force
            Write-EnhancedLog -Message "Created destination directory at $logFolderPath" -Level "INFO"
        }

        # Copy logs from the SYSTEM profile path
        if (Test-Path -Path $systemSourcePath) {
            try {
                Copy-Item -Path "$systemSourcePath*" -Destination $logFolderPath -Recurse -Force -ErrorAction Stop
                Write-EnhancedLog -Message "SYSTEM profile log files successfully copied to $logFolderPath" -Level "INFO"
            }
            catch {
                Write-EnhancedLog -Message "Failed to copy SYSTEM profile logs. Error: $_" -Level "ERROR"
            }
        }
        else {
            Write-EnhancedLog -Message "SYSTEM profile log path not found: $systemSourcePath" -Level "WARNING"
        }

        # Copy logs from the user's profile path
        $userSourcePath = "$env:USERPROFILE\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\"
        if (Test-Path -Path $userSourcePath) {
            try {
                Copy-Item -Path "$userSourcePath*" -Destination $logFolderPath -Recurse -Force -ErrorAction Stop
                Write-EnhancedLog -Message "User profile log files successfully copied to $logFolderPath" -Level "INFO"
            }
            catch {
                Write-EnhancedLog -Message "Failed to copy user profile logs. Error: $_" -Level "ERROR"
            }
        }
        else {
            Write-EnhancedLog -Message "User profile log path not found: $userSourcePath" -Level "WARNING"
        }

        # Verify that the files have been copied
        if (Test-Path -Path $logFolderPath) {
            Write-EnhancedLog -Message "Logs successfully processed to $logFolderPath" -Level "INFO"
        }
        else {
            Write-EnhancedLog -Message "Failed to process log files." -Level "ERROR"
        }

        # Remove logs from the SYSTEM profile path
        if (Test-Path -Path $systemSourcePath) {
            try {
                Remove-Item -Path "$systemSourcePath*" -Recurse -Force -ErrorAction Stop
                Write-EnhancedLog -Message "Logs successfully removed from $systemSourcePath" -Level "INFO"
            }
            catch {
                Write-EnhancedLog -Message "Failed to remove logs. Error: $_" -Level "ERROR"
            }
        }
        else {
            Write-EnhancedLog -Message "Log path not found: $systemSourcePath" -Level "WARNING"
        }

        #Rename SYSTEM logs in PSF to append SYSTEM to easily identify these files as they were generated in the SYSTEM context and their levels are setup to Output instead of Info
        Rename-LogFilesWithUsername -LogDirectoryPath $logFolderPath

        # Remove logs from the user profile path
        # if (Test-Path -Path $userSourcePath) {
        #     try {
        #         Remove-Item -Path "$userSourcePath*" -Recurse -Force -ErrorAction Stop
        #         Write-EnhancedLog -Message "Logs successfully removed from $userSourcePath" -Level "INFO"
        #     }
        #     catch {
        #         Write-EnhancedLog -Message "Failed to remove logs. Error: $_" -Level "ERROR"
        #     }
        # }
        # else {
        #     Write-EnhancedLog -Message "Log path not found: $userSourcePath" -Level "WARNING"
        # }
    }
    catch {
        Write-EnhancedLog -Message "An error occurred in Handle-PSFLogging: $_" -Level "ERROR"
        Handle-Error -ErrorRecord $_
        throw $_  # Re-throw the error after logging it
    }
}


#usage

# $HandlePSFLoggingParams = @{
#     systemSourcePath = "C:\Windows\System32\config\systemprofile\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\"
#     PSFPath          = "C:\Logs\PSF"
# }

# Handle-PSFLogging @HandlePSFLoggingParams