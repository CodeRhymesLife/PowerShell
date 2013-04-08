$GoToShortcuts = @{}

Function GoTo
{
    $Shortcut = $args[0]
	if(!$GoToShortcuts.Contains($Shortcut)) {
        Write-Error "$Shortcut does not exist"
        return
    }
    
    $path = $GoToShortcuts[$Shortcut]
    Write-Debug "Found $Shortcut in list of shortcuts. "
    Write-Debug "path is now '$path'."
    for($i=1; $i -lt $args.Count; $i++){
        $folder = $args[$i]
        $newPath = "$path\$folder"
        if(!(Test-Path $newPath)){
            Write-Error "could not find $folder in $path"
            break
        }

        $path = $newPath
    }

    Write-Debug "Navigating to $path"
    & cd $path
}

Function Add-Goto {
param ([string] $Shortcut, [string] $Path)
    if(!$Shortcut -or !$Path){
        Write-Error "Invalid shortcut or path"
        return
    }
    
    $GoToShortcuts[$Shortcut] = $Path
}

Function Add-Unique {
param ([string] $originalString, [string] $uniqueString, [switch] $Front)
    if(!$originalString.Contains($uniqueString)){
        # Add string to the front
        if($Front){
            return $uniqueString + $originalString
        }

        # Add string end
        return $originalString + $uniqueString
    }

    return $originalString
}

Function Add-PSModulePath{
param ([string] $ModulePath)
    # Create a new PSModulePath path with the passed in modeule path
    $newPSModulePath = Add-Unique $env:PSModulePath ";$ModulePath"
    if($newPSModulePath -ne $env:PSModulePath)
    {
        Write-Debug "Updating PSModulePath"
        # Add this path to the psmodule paths so modules in that folder are picked up
	    [Environment]::SetEnvironmentVariable("PSModulePath", $newPSModulePath, [EnvironmentVariableTarget]::User)
    }
}

Function Set-DebugPref {
param ([switch] $On, [switch] $Off, [switch] $Stop, [switch] $Inquire)
    if($On)
    {
        $DebugPreference = "Continue"
    }
    elseif($Off) {
        $DebugPreference = "SilentlyContinue"
    }
    elseif($Stop) {
        $DebugPreference = "Stop"
    }
    elseif($Inquire){
        $DebugPreference = "Inquire"
    }
}

$directory = (Get-Item $MyInvocation.MyCommand.Path).Directory

# Import Aliases
Import-Alias "$directory\Aliases.txt"

# Export all functions and aliases
Export-ModuleMember -Function "*" -Alias "*"

# Add goto shortcut
Add-Goto -Shortcut "rlib" -Path $directory