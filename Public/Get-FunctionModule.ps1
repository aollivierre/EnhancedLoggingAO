function Get-FunctionModule {
    param (
        [string]$FunctionName
    )

    # Get all imported modules
    $importedModules = Get-Module

    # Iterate through the modules to find which one exports the function
    foreach ($module in $importedModules) {
        if ($module.ExportedFunctions[$FunctionName]) {
            return $module.Name
        }
    }

    # If the function is not found in any module, return null
    return $null
}