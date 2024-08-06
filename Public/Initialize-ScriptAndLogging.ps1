$LoggingDeploymentName = $config.LoggingDeploymentName


function Initialize-ScriptAndLogging {
    $isWindowsOS = $false
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        $isWindowsOS = $isWindowsOS -or ($PSVersionTable.Platform -eq 'Win32NT')
    } else {
        $isWindowsOS = $isWindowsOS -or ($env:OS -eq 'Windows_NT')
    }

    $deploymentName = "$LoggingDeploymentName" # Replace this with your actual deployment name
    $baseScriptPath = if ($isWindowsOS) { "C:\code" } else { "/home/code" }
    $scriptPath_1001 = Join-Path -Path $baseScriptPath -ChildPath $deploymentName
    $computerName = if ($isWindowsOS) { $env:COMPUTERNAME } else { (hostname) }

    try {
        if (-not (Test-Path -Path $scriptPath_1001)) {
            New-Item -ItemType Directory -Path $scriptPath_1001 -Force | Out-Null
            Write-Host "Created directory: $scriptPath_1001" -ForegroundColor Green
        }

        $Filename = "$LoggingDeploymentName"
        $logDir = Join-Path -Path $scriptPath_1001 -ChildPath "exports/Logs/$computerName"
        $logPath = Join-Path -Path $logDir -ChildPath "$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss')"

        if (-not (Test-Path $logPath)) {
            Write-Host "Did not find log directory at $logPath" -ForegroundColor Yellow
            Write-Host "Creating log directory at $logPath" -ForegroundColor Yellow
            New-Item -ItemType Directory -Path $logPath -Force -ErrorAction Stop | Out-Null
            Write-Host "Created log directory at $logPath" -ForegroundColor Green
        }

        $logFile = Join-Path -Path $logPath -ChildPath "$Filename-Transcript.log"
        Start-Transcript -Path $logFile -ErrorAction Stop | Out-Null

        return @{
            ScriptPath  = $scriptPath_1001
            Filename    = $Filename
            LogPath     = $logPath
            LogFile     = $logFile
        }
    } catch {
        Write-Host "An error occurred while initializing script and logging: $_" -ForegroundColor Red
    }
}

# Example usage of Initialize-ScriptAndLogging
# try {
#     $initResult = Initialize-ScriptAndLogging
#     Write-Host "Initialization successful. Log file path: $($initResult.LogFile)" -ForegroundColor Green
# } catch {
#     Write-Host "Initialization failed: $_" -ForegroundColor Red
# }
