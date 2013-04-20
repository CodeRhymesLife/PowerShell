Import-Module -Name .\RLib\RLib.psd1

# Insall this module
Add-PSModulePath (Get-Item $MyInvocation.MyCommand.Path).Directory
