Import-Module posh-git
Import-Module oh-my-posh
Set-Theme Paradox

#find better colors, i dare you.
Set-PSReadLineOption -EditMode vi -Colors @{
	'Operator'  = [ConsoleColor]::DarkGreen
	'Parameter' = [ConsoleColor]::DarkYellow
}
