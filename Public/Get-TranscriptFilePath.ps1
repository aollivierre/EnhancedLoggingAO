function Get-TranscriptFilePath {
    [CmdletBinding()]
    param (
        [string]$TranscriptsPath = "C:\Logs\Transcript",
        [string]$JobName = "AAD Migration"
    )

    # Ensure the destination directory exists
    if (-not (Test-Path -Path $TranscriptsPath)) {
        New-Item -ItemType Directory -Path $TranscriptsPath -Force
        Write-EnhancedLog -Message "Created Transcripts directory at: $TranscriptsPath" -Level "INFO"
    }

    try {
        # Log the start of the function
        Write-EnhancedLog -Message "Starting Get-TranscriptFilePath function..." -Level "NOTICE"

        # Get the current username
        $username = if ($env:USERNAME) { $env:USERNAME } else { "UnknownUser" }
        Write-EnhancedLog -Message "Current username: $username" -Level "INFO"

        # Get the script name from $MyInvocation
        $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.ScriptName)
        if (-not $scriptName) {
            $scriptName = "UnknownScript"
        }
        Write-EnhancedLog -Message "Script name: $scriptName" -Level "INFO"

        # Check if running as SYSTEM using Test-RunningAsSystem
        $isSystem = Test-RunningAsSystem
        Write-EnhancedLog -Message "Is running as SYSTEM: $isSystem" -Level "INFO"

        # Get the current date for folder creation
        $currentDate = Get-Date -Format "yyyy-MM-dd"

        $hostname = $env:COMPUTERNAME
        $timestamp = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
        $logFolderPath = "$TranscriptsPath\$currentDate\$scriptName"

        # Ensure the log directory exists
        if (-not (Test-Path -Path $logFolderPath)) {
            New-Item -Path $logFolderPath -ItemType Directory -Force
            Write-EnhancedLog -Message "Created directory for log file: $logFolderPath" -Level "INFO"
        }

        # Generate log file path based on context
        if ($isSystem) {
            $logFilePath = "$logFolderPath\$hostname-$JobName-SYSTEM-$scriptName-transcript-$timestamp.log"
            Write-EnhancedLog -Message "Generated log file path for SYSTEM: $logFilePath" -Level "INFO"
        }
        else {
            $logFilePath = "$logFolderPath\$hostname-$JobName-$username-$scriptName-transcript-$timestamp.log"
            Write-EnhancedLog -Message "Generated log file path for non-SYSTEM: $logFilePath" -Level "INFO"
        }

        # Convert the logFilePath to a string explicitly
        $logFilePath = [string]$logFilePath

        Write-EnhancedLog -Message "Exiting Get-TranscriptFilePath function" -Level "NOTICE"
        return $logFilePath
    }
    catch {
        Write-EnhancedLog -Message "An error occurred in Get-TranscriptFilePath: $_" -Level "ERROR"
        Handle-Error -ErrorRecord $_
        throw $_  # Re-throw the error after logging it
    }
}
