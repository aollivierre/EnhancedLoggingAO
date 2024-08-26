function Rename-PSFLogFilesWithUsername {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$LogDirectoryPath,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$ParentScriptName,

        [Parameter(Mandatory = $true, Position = 2)]
        [string]$JobName
    )

    Begin {
        Write-EnhancedLog -Message "Starting Rename-PSFLogFilesWithUsername function..." -Level "NOTICE"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    Process {
        Write-EnhancedLog -Message "Starting the renaming process for log files in directory: $LogDirectoryPath" -Level "INFO"

        # Get all log files in the specified directory
        $logFiles = Get-ChildItem -Path $LogDirectoryPath -Filter "*.log"

        if ($logFiles.Count -eq 0) {
            Write-EnhancedLog -Message "No log files found in the directory." -Level "WARNING"
            return
        }

        Write-EnhancedLog -Message "Found $($logFiles.Count) log files to process." -Level "INFO"

        foreach ($logFile in $logFiles) {
            try {
                Write-EnhancedLog -Message "Processing file: $($logFile.FullName)" -Level "INFO"

                # Import the log file as CSV
                $logEntries = Import-Csv -Path $logFile.FullName

                # Extract the username, timestamp, and computer name from the first entry in the CSV
                $firstEntry = $logEntries | Select-Object -First 1
                $username = $firstEntry.Username
                $timestamp = $firstEntry.Timestamp
                $computerName = $firstEntry.ComputerName

                if (-not $username) {
                    Write-EnhancedLog -Message "No username found in $($logFile.Name). Skipping file." -Level "WARNING"
                    continue
                }

                if (-not $timestamp) {
                    $timestamp = "NoTimestamp"
                    Write-EnhancedLog -Message "No timestamp found in $($logFile.Name). Defaulting to 'NoTimestamp'." -Level "WARNING"
                }

                if (-not $computerName) {
                    $computerName = "UnknownComputer"
                    Write-EnhancedLog -Message "No computer name found in $($logFile.Name). Defaulting to 'UnknownComputer'." -Level "WARNING"
                }

                Write-EnhancedLog -Message "Username found in file: $username" -Level "INFO"
                Write-EnhancedLog -Message "Timestamp found in file: $timestamp" -Level "INFO"
                Write-EnhancedLog -Message "Computer name found in file: $computerName" -Level "INFO"

                # Remove the domain part if present in the username
                if ($username -match '^[^\\]+\\(.+)$') {
                    $username = $matches[1]
                }

                Write-EnhancedLog -Message "Processed username: $username" -Level "INFO"

                # Sanitize the username, timestamp, and computer name
                $safeUsername = $username -replace '[\\/:*?"<>|]', '_'
                $safeTimestamp = $timestamp -replace '[\\/:*?"<>|]', '_'
                $safeComputerName = $computerName -replace '[\\/:*?"<>|]', '_'

                Write-EnhancedLog -Message "Sanitized username: $safeUsername" -Level "INFO"
                Write-EnhancedLog -Message "Sanitized timestamp: $safeTimestamp" -Level "INFO"
                Write-EnhancedLog -Message "Sanitized computer name: $safeComputerName" -Level "INFO"

                # Generate a unique identifier
                $uniqueId = [guid]::NewGuid().ToString()

                # Construct the new file name with the GUID
                $fileExtension = [System.IO.Path]::GetExtension($logFile.FullName)
                $newFileName = "$JobName-$safeUsername-$safeComputerName-$ParentScriptName-$safeTimestamp-$uniqueId$fileExtension"
                $newFilePath = [System.IO.Path]::Combine($logFile.DirectoryName, $newFileName)
                Write-EnhancedLog -Message "Attempting to rename to: $newFilePath" -Level "INFO"

                # Rename the file
                Rename-Item -Path $logFile.FullName -NewName $newFileName -Force
                Write-EnhancedLog -Message "Successfully renamed $($logFile.FullName) to $newFileName" -Level "INFO"
            }
            catch {
                Write-EnhancedLog -Message "Failed to process $($logFile.FullName): $_" -Level "ERROR"
                Write-EnhancedLog -Message "Possible cause: The file name or path may contain invalid characters or the file might be in use." -Level "ERROR"
            }
        }

        Write-EnhancedLog -Message "Finished processing all log files." -Level "INFO"
    }

    End {
        Write-EnhancedLog -Message "Exiting Rename-PSFLogFilesWithUsername function" -Level "NOTICE"
    }
}
