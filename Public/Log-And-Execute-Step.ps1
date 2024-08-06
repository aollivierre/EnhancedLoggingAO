function Log-And-Execute-Step {
    [CmdletBinding()]
    param ()

    Begin {
        Write-EnhancedLog -Message "Starting Log-And-Execute-Step function" -Level "INFO"
    }

    Process {
        try {
            $global:currentStep++
            $totalSteps = $global:steps.Count
            $step = $global:steps[$global:currentStep - 1]
            Write-EnhancedLog -Message "Step [$global:currentStep/$totalSteps]: $($step.Description)" -Level "INFO"
            
            & $step.Action
        } catch {
            Write-EnhancedLog -Message "Error in step: $($step.Description) - $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Log-And-Execute-Step function" -Level "INFO"
    }
}

# Example usage
# Log-And-Execute-Step
