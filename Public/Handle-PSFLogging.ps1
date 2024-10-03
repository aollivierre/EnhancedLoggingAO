function Copy-PSFLogs {
    [CmdletBinding()]
    param (
        [string]$SourcePath,
        [string]$DestinationPath
    )

    Begin {
        Write-EnhancedLog -Message "Starting Copy-PSFLogs function..." -Level "NOTICE"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    Process {
        if (Test-Path -Path $SourcePath) {
            try {
                Copy-Item -Path "$SourcePath*" -Destination $DestinationPath -Recurse -Force -ErrorAction Stop
                Write-EnhancedLog -Message "Log files successfully copied from $SourcePath to $DestinationPath" -Level "INFO"
            }
            catch {
                Write-EnhancedLog -Message "Failed to copy logs from $SourcePath. Error: $_" -Level "ERROR"
            }
        }
        else {
            Write-EnhancedLog -Message "Log path not found: $SourcePath" -Level "WARNING"
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Copy-PSFLogs function" -Level "NOTICE"
    }
}
function Remove-PSFLogs {
    [CmdletBinding()]
    param (
        [string]$SourcePath
    )

    Begin {
        Write-EnhancedLog -Message "Starting Remove-PSFLogs function..." -Level "NOTICE"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    Process {
        if (Test-Path -Path $SourcePath) {
            try {
                Remove-Item -Path "$SourcePath*" -Recurse -Force -ErrorAction Stop
                Write-EnhancedLog -Message "Logs successfully removed from $SourcePath" -Level "INFO"
            }
            catch {
                Write-EnhancedLog -Message "Failed to remove logs from $SourcePath. Error: $_" -Level "ERROR"
            }
        }
        else {
            Write-EnhancedLog -Message "Log path not found: $SourcePath" -Level "WARNING"
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Remove-PSFLogs function" -Level "NOTICE"
    }
}
function Handle-PSFLogging {
    [CmdletBinding()]
    param (
        [string]$SystemSourcePathWindowsPS = "C:\Windows\System32\config\systemprofile\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\",
        [string]$SystemSourcePathPS = "C:\Windows\System32\config\systemprofile\AppData\Roaming\PowerShell\PSFramework\Logs\",
        # [string]$UserSourcePathWindowsPS = "$env:USERPROFILE\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\",
        # [string]$UserSourcePathPS = "$env:USERPROFILE\AppData\Roaming\PowerShell\PSFramework\Logs\",
        [string]$PSFPath = "C:\Logs\PSF",
        [string]$ParentScriptName,
        [string]$JobName,
        [bool]$SkipSYSTEMLogCopy = $false,
        [bool]$SkipSYSTEMLogRemoval = $false
    )

    Begin {
        Write-EnhancedLog -Message "Starting Handle-PSFLogging function..." -Level "NOTICE"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters

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
    }

    # Process {
    #     # Copy logs from both SYSTEM profile paths
        
    #     if (-not $SkipSYSTEMLogCopy) {
    #         Copy-PSFLogs -SourcePath $SystemSourcePathWindowsPS -DestinationPath $logFolderPath
    #         Write-EnhancedLog -Message "Copied SYSTEM logs from $SystemSourcePathWindowsPS to $logFolderPath." -Level "INFO"
        
    #         Copy-PSFLogs -SourcePath $SystemSourcePathPS -DestinationPath $logFolderPath
    #         Write-EnhancedLog -Message "Copied SYSTEM logs from $SystemSourcePathPS to $logFolderPath." -Level "INFO"
    #     }
    #     else {
    #         Write-EnhancedLog -Message "Skipping SYSTEM log copy as per the provided parameter." -Level "INFO"
    #     }

    #     # Copy logs from the user's profile paths for both PowerShell versions
    #     Copy-PSFLogs -SourcePath $UserSourcePathWindowsPS -DestinationPath $logFolderPath
    #     Copy-PSFLogs -SourcePath $UserSourcePathPS -DestinationPath $logFolderPath

    #     # Verify that the files have been copied
    #     if (Test-Path -Path $logFolderPath) {
    #         Write-EnhancedLog -Message "Logs successfully processed to $logFolderPath" -Level "INFO"
    #     }
    #     else {
    #         Write-EnhancedLog -Message "Failed to process log files." -Level "ERROR"
    #     }

    #     # Remove logs from the SYSTEM profile paths   
    #     if (-not $SkipSYSTEMLogRemoval) {
    #         # Remove logs from the SYSTEM profile paths
    #         Remove-PSFLogs -SourcePath $SystemSourcePathWindowsPS
    #         Write-EnhancedLog -Message "Removed SYSTEM logs from $SystemSourcePathWindowsPS." -Level "INFO"
            
    #         Remove-PSFLogs -SourcePath $SystemSourcePathPS
    #         Write-EnhancedLog -Message "Removed SYSTEM logs from $SystemSourcePathPS." -Level "INFO"
    #     }
    #     else {
    #         Write-EnhancedLog -Message "Skipping SYSTEM log removal as per the provided parameter." -Level "INFO"
    #     }

    #     # Remove logs from the User profile paths
    #     Remove-PSFLogs -SourcePath $UserSourcePathWindowsPS
    #     Remove-PSFLogs -SourcePath $UserSourcePathPS

    #     # Rename SYSTEM logs in PSF to append SYSTEM to easily identify these files
    #     $RenamePSFLogFilesParams = @{
    #         LogDirectoryPath = $logFolderPath 
    #         ParentScriptName = $ParentScriptName
    #         JobName          = $jobName
    #     }
    #     Rename-PSFLogFilesWithUsername @RenamePSFLogFilesParams
    # }




    Process {
        # Copy logs from both SYSTEM profile paths
        if (-not $SkipSYSTEMLogCopy) {
            Copy-PSFLogs -SourcePath $SystemSourcePathWindowsPS -DestinationPath $logFolderPath
            Write-EnhancedLog -Message "Copied SYSTEM logs from $SystemSourcePathWindowsPS to $logFolderPath." -Level "INFO"
        
            Copy-PSFLogs -SourcePath $SystemSourcePathPS -DestinationPath $logFolderPath
            Write-EnhancedLog -Message "Copied SYSTEM logs from $SystemSourcePathPS to $logFolderPath." -Level "INFO"
        }
        else {
            Write-EnhancedLog -Message "Skipping SYSTEM log copy as per the provided parameter." -Level "INFO"
        }
    
        # Iterate through all user profiles in C:\Users and copy logs
        $userProfiles = Get-ChildItem -Path 'C:\Users' | Where-Object { $_.PSIsContainer -and $_.Name -notmatch '^(Default|Public|systemprofile)$' }
        foreach ($profile in $userProfiles) {
            $userWindowsPSPath = "$($profile.FullName)\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\"
            $userPSPath = "$($profile.FullName)\AppData\Roaming\PowerShell\PSFramework\Logs\"
    
            if (Test-Path $userWindowsPSPath) {
                Copy-PSFLogs -SourcePath $userWindowsPSPath -DestinationPath $logFolderPath
                Write-EnhancedLog -Message "Copied logs from $userWindowsPSPath to $logFolderPath." -Level "INFO"
            }
    
            if (Test-Path $userPSPath) {
                Copy-PSFLogs -SourcePath $userPSPath -DestinationPath $logFolderPath
                Write-EnhancedLog -Message "Copied logs from $userPSPath to $logFolderPath." -Level "INFO"
            }
        }
    
        # Verify that the files have been copied
        if (Test-Path -Path $logFolderPath) {
            Write-EnhancedLog -Message "Logs successfully processed to $logFolderPath" -Level "INFO"
        }
        else {
            Write-EnhancedLog -Message "Failed to process log files." -Level "ERROR"
        }
    
        # Remove logs from the SYSTEM profile paths
        if (-not $SkipSYSTEMLogRemoval) {
            # Remove logs from the SYSTEM profile paths
            Remove-PSFLogs -SourcePath $SystemSourcePathWindowsPS
            Write-EnhancedLog -Message "Removed SYSTEM logs from $SystemSourcePathWindowsPS." -Level "INFO"
            
            Remove-PSFLogs -SourcePath $SystemSourcePathPS
            Write-EnhancedLog -Message "Removed SYSTEM logs from $SystemSourcePathPS." -Level "INFO"
        }
        else {
            Write-EnhancedLog -Message "Skipping SYSTEM log removal as per the provided parameter." -Level "INFO"
        }
    
        # Remove logs from each user profile path
        foreach ($profile in $userProfiles) {
            $userWindowsPSPath = "$($profile.FullName)\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\"
            $userPSPath = "$($profile.FullName)\AppData\Roaming\PowerShell\PSFramework\Logs\"
    
            if (Test-Path $userWindowsPSPath) {
                Remove-PSFLogs -SourcePath $userWindowsPSPath
                Write-EnhancedLog -Message "Removed logs from $userWindowsPSPath." -Level "INFO"
            }
    
            if (Test-Path $userPSPath) {
                Remove-PSFLogs -SourcePath $userPSPath
                Write-EnhancedLog -Message "Removed logs from $userPSPath." -Level "INFO"
            }
        }
    
        # Rename SYSTEM logs in PSF to append SYSTEM to easily identify these files
        $RenamePSFLogFilesParams = @{
            LogDirectoryPath = $logFolderPath 
            ParentScriptName = $ParentScriptName
            JobName          = $jobName
        }
        Rename-PSFLogFilesWithUsername @RenamePSFLogFilesParams
    }
    



    End {
        Write-EnhancedLog -Message "Exiting Handle-PSFLogging function" -Level "NOTICE"
    }
}
# $HandlePSFLoggingParams = @{
#     SystemSourcePathWindowsPS = "C:\Windows\System32\config\systemprofile\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\"
#     SystemSourcePathPS        = "C:\Windows\System32\config\systemprofile\AppData\Roaming\PowerShell\PSFramework\Logs\"
#     UserSourcePathWindowsPS   = "$env:USERPROFILE\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\"
#     UserSourcePathPS          = "$env:USERPROFILE\AppData\Roaming\PowerShell\PSFramework\Logs\"
#     PSFPath                   = "C:\Logs\PSF"
# }

# Handle-PSFLogging @HandlePSFLoggingParams
