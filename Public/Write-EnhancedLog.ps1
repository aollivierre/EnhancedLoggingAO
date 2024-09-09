function Write-EnhancedLog {
    param (
        [string]$Message,
        [string]$Level = 'INFO'
    )

    # Get the PowerShell call stack to determine the actual calling function
    $callStack = Get-PSCallStack
    $callerFunction = if ($callStack.Count -ge 2) { $callStack[1].Command } else { '<Unknown>' }

    # Get the parent script name
    $parentScriptName = Get-ParentScriptName

    # Prepare the formatted message with the actual calling function information
    $formattedMessage = "[$Level] $Message"

    # Map custom levels to PSFramework levels
    $psfLevel = switch ($Level.ToUpper()) {
        'DEBUG'           { 'Debug' }
        'INFO'            { 'Host' }
        'NOTICE'          { 'Important' }
        'WARNING'         { 'Warning' }
        'ERROR'           { 'Error' }
        'CRITICAL'        { 'Critical' }
        'IMPORTANT'       { 'Important' }
        'OUTPUT'          { 'Output' }
        'SIGNIFICANT'     { 'Significant' }
        'VERYVERBOSE'     { 'VeryVerbose' }
        'VERBOSE'         { 'Verbose' }
        'SOMEWHATVERBOSE' { 'SomewhatVerbose' }
        'SYSTEM'          { 'System' }
        'INTERNALCOMMENT' { 'InternalComment' }
        default           { 'Host' }
    }

    # Log the message using PSFramework with the actual calling function name
    Write-PSFMessage -Level $psfLevel -Message $formattedMessage -FunctionName "$parentScriptName.$callerFunction"
}
