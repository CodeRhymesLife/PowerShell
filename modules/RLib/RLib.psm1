Function GoTo
{
    $goToShortcuts = Get-Goto

    $Shortcut = $args[0]
	if(!$goToShortcuts.Contains($Shortcut)) {
        Write-Error "$Shortcut does not exist"
        return
    }
    
    $path = $goToShortcuts[$Shortcut]
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
param (
    [Parameter(Mandatory=$true)]
    [string] $Shortcut,
    
    [Parameter(Mandatory=$true)]
    [string] $Path
)
    # Ensure the shortcut and path do not contain invalid characters
    $invalidCharacters = @(";", "=");
    foreach($invalidCharacter in $invalidCharacters){
        if(($Shortcut + $Path).Contains($invalidCharacter)){
            Write-Error "Neither the shortcut or the path can contain ';' or '='"
            return
        }
    }    

    $newRLibGoToPath = Add-Unique $env:RLibGoToPath "$Shortcut=$Path;"
    if($newRLibGoToPath -ne $env:RLibGoToPath)
    {
        Write-Host "Adding GoTo shortcut..."
        # Add this shortcut to the RLibGoToPath paths so we can navigate
        # to the give path with the given shortcut
	    [Environment]::SetEnvironmentVariable("RLibGoToPath", $newRLibGoToPath, [EnvironmentVariableTarget]::User)

        Write-Host "Please restart powershell for path to take effect"
    }
}

Function Get-Goto {
    $gotoShortcuts = @{}

    if($env:RLibGoToPath){
        # Get shortcut paths mapping
        $env:RLibGoToPath.Split(";") | ForEach-Object {
            $shotcutPath = $_.Split("=")

            # If we have a valid shortcut and path
            # add it to the mapping
            if($shotcutPath[0] -and $shotcutPath[1]){
                $gotoShortcuts[$shotcutPath[0]] = $shotcutPath[1]
            }
        }
    }

    return $gotoShortcuts
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