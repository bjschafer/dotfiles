If (!(Get-Module -Name 'posh-git'))
{
	Install-Module posh-git -Force
}
If (!(Get-Module -Name 'oh-my-posh'))
{
	Install-Module oh-my-posh -Force
}

Import-Module posh-git
Import-Module oh-my-posh
Set-PoshPrompt -Theme Paradox

If (Get-Module -Name 'PSReadline')
{
	#find better colors, i dare you.
	Set-PSReadLineOption -EditMode vi -Colors @{
		'Operator'  = [ConsoleColor]::DarkGreen
		'Parameter' = [ConsoleColor]::DarkYellow
	}
}
