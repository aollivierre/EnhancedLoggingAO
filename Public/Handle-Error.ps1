function Handle-Error {
    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord
    )

    try {
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            $fullErrorDetails = Get-Error -InputObject $ErrorRecord | Out-String
        } else {
            $fullErrorDetails = $ErrorRecord.Exception | Format-List * -Force | Out-String
        }

        Write-EnhancedLog -Message "Exception Message: $($ErrorRecord.Exception.Message)" -Level "ERROR"
        Write-EnhancedLog -Message "Full Exception: $fullErrorDetails" -Level "ERROR"
    } catch {
        # Fallback error handling in case of an unexpected error in the try block
        Write-EnhancedLog -Message "An error occurred while handling another error. Original Exception: $($ErrorRecord.Exception.Message)" -Level "CRITICAL"
        Write-EnhancedLog -Message "Handler Exception: $($_.Exception.Message)" -Level "CRITICAL"
        Write-EnhancedLog -Message "Handler Full Exception: $($_ | Out-String)" -Level "CRITICAL"
    }
}

# # Example usage of Handle-Error
# try {
#     # Intentionally cause an error for demonstration purposes
#     throw "This is a test error"
# } catch {
#     Handle-Error -ErrorRecord $_
# }



