function Get-TranscriptFilePath {
    [CmdletBinding()]
    param (
        [string]$TranscriptsPath,
        [string]$JobName,
        [string]$ParentScriptName

    )

    # Ensure the destination directory exists
    if (-not (Test-Path -Path $TranscriptsPath)) {
        New-Item -ItemType Directory -Path $TranscriptsPath -Force | Out-Null
        Write-EnhancedLog -Message "Created Transcripts directory at: $TranscriptsPath" -Level "INFO"
    }

    try {
        # Log the start of the function
        Write-EnhancedLog -Message "Starting Get-TranscriptFilePath function..." -Level "NOTICE"

        # Get the current username
        $username = if ($env:USERNAME) { $env:USERNAME } else { "UnknownUser" }
        Write-EnhancedLog -Message "Current username: $username" -Level "INFO"

        # Get the parent script name using Get-ParentScriptName function
        # $scriptName = Get-ParentScriptName
        Write-EnhancedLog -Message "Script name: $ParentScriptName" -Level "INFO"

        # Check if running as SYSTEM using Test-RunningAsSystem
        $isSystem = Test-RunningAsSystem
        Write-EnhancedLog -Message "Is running as SYSTEM: $isSystem" -Level "INFO"

        # Get the current date for folder creation
        $currentDate = Get-Date -Format "yyyy-MM-dd"

        # Construct the hostname and timestamp for the log filename
        $hostname = $env:COMPUTERNAME
        $timestamp = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
        $logFolderPath = "$TranscriptsPath\$currentDate\$ParentScriptName"

        # Ensure the log directory exists
        if (-not (Test-Path -Path $logFolderPath)) {
            New-Item -Path $logFolderPath -ItemType Directory -Force | Out-Null
            Write-EnhancedLog -Message "Created directory for log file: $logFolderPath" -Level "INFO"
        }

        # Generate log file path based on context
        $logFilePath = if ($isSystem) {
            "$logFolderPath\$hostname-$JobName-SYSTEM-$ParentScriptName-transcript-$timestamp.log"
        }
        else {
            "$logFolderPath\$hostname-$JobName-$username-$ParentScriptName-transcript-$timestamp.log"
        }

        $logFilePath = Sanitize-LogFilePath -LogFilePath $logFilePath

        # Validate the log file path before using it
        Validate-LogFilePath -LogFilePath $logFilePath

        Write-EnhancedLog -Message "Generated log file path: $logFilePath" -Level "INFO"

        Write-EnhancedLog -Message "Exiting Get-TranscriptFilePath function" -Level "NOTICE"
        return $logFilePath
    }
    catch {
        Write-EnhancedLog -Message "An error occurred in Get-TranscriptFilePath: $_" -Level "ERROR"
        Handle-Error -ErrorRecord $_
        throw $_  # Re-throw the error after logging it
    }
}