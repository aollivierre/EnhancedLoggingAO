function Get-TranscriptFilePath {
    <#
    .SYNOPSIS
    Generates a file path for storing PowerShell transcripts.

    .DESCRIPTION
    The Get-TranscriptFilePath function constructs a unique transcript file path based on the provided transcript directory, job name, and parent script name. It ensures the transcript directory exists, handles context (e.g., SYSTEM account), and logs each step of the process.

    .PARAMETER TranscriptsPath
    The base directory where transcript files will be stored.

    .PARAMETER JobName
    The name of the job or task, used to distinguish different log files.

    .PARAMETER ParentScriptName
    The name of the parent script that is generating the transcript.

    .EXAMPLE
    $params = @{
        TranscriptsPath  = 'C:\Transcripts'
        JobName          = 'BackupJob'
        ParentScriptName = 'BackupScript.ps1'
    }
    Get-TranscriptFilePath @params
    Generates a transcript file path for a script called BackupScript.ps1.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Provide the base path for transcripts.")]
        [ValidateNotNullOrEmpty()]
        [string]$TranscriptsPath,

        [Parameter(Mandatory = $true, HelpMessage = "Provide the job name.")]
        [ValidateNotNullOrEmpty()]
        [string]$JobName,

        [Parameter(Mandatory = $true, HelpMessage = "Provide the parent script name.")]
        [ValidateNotNullOrEmpty()]
        [string]$ParentScriptName
    )

    Begin {
        # Log the start of the function
        Write-EnhancedLog -Message "Starting Get-TranscriptFilePath function..." -Level "NOTICE"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters

        # Ensure the destination directory exists
        if (-not (Test-Path -Path $TranscriptsPath)) {
            New-Item -ItemType Directory -Path $TranscriptsPath -Force | Out-Null
            Write-EnhancedLog -Message "Created Transcripts directory at: $TranscriptsPath" -Level "INFO"
        }
    }

    Process {
        try {
            # Get the current username or fallback to "UnknownUser"
            $username = if ($env:USERNAME) { $env:USERNAME } else { "UnknownUser" }
            Write-EnhancedLog -Message "Current username: $username" -Level "INFO"

            # Log the provided parent script name
            Write-EnhancedLog -Message "Parent script name: $ParentScriptName" -Level "INFO"

            # Check if running as SYSTEM
            $isSystem = Test-RunningAsSystem
            Write-EnhancedLog -Message "Is running as SYSTEM: $isSystem" -Level "INFO"

            # Get the current date for folder structure
            $currentDate = Get-Date -Format "yyyy-MM-dd"
            Write-EnhancedLog -Message "Current date for transcript folder: $currentDate" -Level "INFO"

            # Construct the hostname and timestamp for the log file name
            $hostname = $env:COMPUTERNAME
            $timestamp = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
            $logFolderPath = Join-Path -Path $TranscriptsPath -ChildPath "$currentDate\$ParentScriptName"

            # Ensure the log directory exists
            if (-not (Test-Path -Path $logFolderPath)) {
                New-Item -Path $logFolderPath -ItemType Directory -Force | Out-Null
                Write-EnhancedLog -Message "Created directory for transcript logs: $logFolderPath" -Level "INFO"
            }

            # Generate log file path based on context (SYSTEM or user)
            $logFilePath = if ($isSystem) {
                "$logFolderPath\$hostname-$JobName-SYSTEM-$ParentScriptName-transcript-$timestamp.log"
            }
            else {
                "$logFolderPath\$hostname-$JobName-$username-$ParentScriptName-transcript-$timestamp.log"
            }

            Write-EnhancedLog -Message "Constructed log file path: $logFilePath" -Level "INFO"

            # Sanitize and validate the log file path
            $logFilePath = Sanitize-LogFilePath -LogFilePath $logFilePath
            Validate-LogFilePath -LogFilePath $logFilePath
            Write-EnhancedLog -Message "Log file path sanitized and validated: $logFilePath" -Level "INFO"

            # Return the constructed file path
            return $logFilePath
        }
        catch {
            Write-EnhancedLog -Message "An error occurred in Get-TranscriptFilePath: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Get-TranscriptFilePath function" -Level "NOTICE"
    }
}
