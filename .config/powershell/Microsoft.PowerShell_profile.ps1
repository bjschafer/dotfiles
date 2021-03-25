If (Get-Module -ListAvailable -Name 'PSReadline')
{
	#find better colors, i dare you.
	Set-PSReadLineOption -EditMode vi -Colors @{
		'Operator'  = [ConsoleColor]::DarkGreen
		'Parameter' = [ConsoleColor]::DarkYellow
	}
}

If (Get-Command starship)
{
        Invoke-Expression $(starship init powershell)
}
