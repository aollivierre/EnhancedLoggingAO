function Initialize-CSVDirectory {
    param (
        [string]$deploymentName,
        [string]$computerName
    )

    $isWindowsOS = $false
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        $isWindowsOS = $isWindowsOS -or ($PSVersionTable.Platform -eq 'Win32NT')
    } else {
        $isWindowsOS = $isWindowsOS -or ($env:OS -eq 'Windows_NT')
    }

    $baseScriptPath = if ($isWindowsOS) { "C:\code" } else { "/home/code" }
    $scriptPath_1001 = Join-Path -Path $baseScriptPath -ChildPath $deploymentName
    $CSVDir_1001 = Join-Path -Path $scriptPath_1001 -ChildPath "exports/CSV"
    $CSVFilePath_1001 = Join-Path -Path $CSVDir_1001 -ChildPath "$computerName"

    try {
        if (-not (Test-Path $CSVFilePath_1001)) {
            Write-Host "Did not find CSV directory at $CSVFilePath_1001" -ForegroundColor Yellow
            Write-Host "Creating CSV directory at $CSVFilePath_1001" -ForegroundColor Yellow
            New-Item -ItemType Directory -Path $CSVFilePath_1001 -Force -ErrorAction Stop | Out-Null
            Write-Host "Created CSV directory at $CSVFilePath_1001" -ForegroundColor Green
        }

        return @{
            CSVFilePath = $CSVFilePath_1001
        }
    } catch {
        Write-Host "An error occurred while initializing CSV directory: $_" -ForegroundColor Red
    }
}

# # Example usage of Initialize-CSVDirectory
# try {
#     $csvInitResult = Initialize-CSVDirectory -deploymentName "$LoggingDeploymentName" -computerName $env:COMPUTERNAME
#     Write-Host "CSV initialization successful. CSV directory path: $($csvInitResult.CSVFilePath)" -ForegroundColor Green
# } catch {
#     Write-Host "CSV initialization failed: $_" -ForegroundColor Red
# }
