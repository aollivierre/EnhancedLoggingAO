function Get-PSFCSVLogFilePath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Specify the base path where the logs will be stored.")]
        [string]$LogsPath,

        [Parameter(Mandatory = $true, Position = 1, HelpMessage = "Specify the job name to be used in the log file name.")]
        [string]$JobName,

        [Parameter(Mandatory = $true, Position = 2, HelpMessage = "Specify the name of the parent script.")]
        [string]$parentScriptName
    )

    Begin {
        Write-EnhancedLog -Message "Starting Get-PSFCSVLogFilePath function..." -Level "NOTICE"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters

        # Ensure the destination directory exists
        if (-not (Test-Path -Path $LogsPath)) {
            New-Item -ItemType Directory -Path $LogsPath -Force | Out-Null
            Write-EnhancedLog -Message "Created Logs directory at: $LogsPath" -Level "INFO"
        }
    }

    Process {
        try {
            # Get the current username
            $username = if ($env:USERNAME) { $env:USERNAME } else { "UnknownUser" }
            Write-EnhancedLog -Message "Current username: $username" -Level "INFO"

            # Log the parent script name
            Write-EnhancedLog -Message "Script name: $parentScriptName" -Level "INFO"

            # Check if running as SYSTEM
            $isSystem = Test-RunningAsSystem
            Write-EnhancedLog -Message "Is running as SYSTEM: $isSystem" -Level "INFO"

            # Get the current date for folder creation
            $currentDate = Get-Date -Format "yyyy-MM-dd"

            # Construct the hostname and timestamp for the log filename
            $hostname = $env:COMPUTERNAME
            $timestamp = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
            $logFolderPath = "$LogsPath\$currentDate\$parentScriptName"

            # Ensure the log directory exists
            if (-not (Test-Path -Path $logFolderPath)) {
                New-Item -Path $logFolderPath -ItemType Directory -Force | Out-Null
                Write-EnhancedLog -Message "Created directory for log file: $logFolderPath" -Level "INFO"
            }

            # Generate log file path based on context
            $logFilePath = if ($isSystem) {
                "$logFolderPath\$hostname-$JobName-SYSTEM-$parentScriptName-log-$timestamp.csv"
            }
            else {
                "$logFolderPath\$hostname-$JobName-$username-$parentScriptName-log-$timestamp.csv"
            }

            $logFilePath = Sanitize-LogFilePath -LogFilePath $logFilePath

            # Validate the log file path before using it
            Validate-LogFilePath -LogFilePath $logFilePath

            Write-EnhancedLog -Message "Generated PSFramework CSV log file path: $logFilePath" -Level "INFO"
            return $logFilePath
        }
        catch {
            Write-EnhancedLog -Message "An error occurred in Get-PSFCSVLogFilePath: $_" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw $_  # Re-throw the error after logging it
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Get-PSFCSVLogFilePath function" -Level "NOTICE"
    }
}