$ScriptName = $MyInvocation.MyCommand.Name
$ScriptDir=$PSScriptRoot

function Resolve-Symlink {
	Param($SymPath)
	while ( (Test-Path $SymPath) -and ((Get-Item $SymPath).LinkType -eq "SymbolicLink") ) {
		$SymPath = (Get-Item $SymPath).Target
	}
	return $SymPath
}

$ScriptPath="$ScriptDir/$ScriptName"
$ScriptPath=$(Resolve-Symlink $ScriptPath)
$ScriptDir=$(split-path $ScriptPath)
$ScriptName=$(split-path -Leaf $ScriptPath)


#terminal readline settings
Set-PSReadLineOption -PredictionSource History 
Set-PSReadLineOption -PredictionViewStyle ListView 
# Set-PSReadLineOption -EditMode Windows 
Set-PSReadlineOption -EditMode Emacs
Set-PSReadlineOption -BellStyle None
Set-PSReadLineKeyHandler -Key Ctrl+h -Function BackwardKillWord # Make ctrl+backspace delete a word.

#Fzf (Import the fuzzy finder and set a shortcut key to begin searching)
# check if fzf is installed using get-command
if (Get-Command fzf -ErrorAction SilentlyContinue) {
	# Import the module
	Import-Module PSFzf
	# Set the keybinding to Ctrl+R
	Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# setup for VS dev shell 
# $VsWhere="${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
# $VSInstallConfigObject =  $(&$VsWhere -format json | ConvertFrom-Json | sort installDate -Descending -Top 1)
# ${ENV:VCINSTALLDIR}=$VSInstallConfigObject.installationPath
# Import-Module (Join-Path ${ENV:VCINSTALLDIR} Common7/Tools/Microsoft.VisualStudio.DevShell.dll);
# Enter-VsDevShell $VSInstallConfigObject.instanceId -SkipAutomaticLocation -DevCmdArguments "-arch=x64 -host_arch=x64"


#$colorScheme = @{
#    None      = "Black";
#    Comment   = "DarkMagenta";
#    Keyword   = "DarkGreen";
#    String    = "DarkBlue";
#    Operator  = "DarkRed";
#    Variable  = "DarkGreen";
#    Command   = "DarkRed";
#    Parameter = "DarkGreen";
#    Type      = "DarkGray";
#    Number    = "DarkGray";
#    Member    = "DarkGray";
#}
#$colorScheme.Keys | % { Set-PSReadlineOption -TokenKind $_ -ForegroundColor $colorScheme[$_] }



Set-PSReadlineOption -Colors @{
	Comment   = "DarkMagenta";
	Keyword   = "DarkGreen";
	String    = "DarkBlue";
	Operator  = "DarkRed";
	Variable  = "DarkGreen";
	Command   = "DarkRed";
	Parameter = "DarkGreen";
	Type      = "DarkGray";
	Number    = "DarkGray";
	Member    = "DarkGray"
}

# set a good prompt with host name and current directory
function prompt {
	$host.UI.RawUI.WindowTitle = "PS $pwd"
	$host.UI.RawUI.BackgroundColor = "Black"
	$host.UI.RawUI.ForegroundColor = "White"
	$host.UI.RawUI.WindowTitle = "PS $pwd"
	([net.dns]::GetHostName()) + " $pwd> "
}
Import-Module (Join-Path $ScriptDir "dbgutil.psm1") -Force -DisableNameChecking


# create symlink for the to wsl root
# if (-not (Test-Path "${env:USERPROFILE}\wslroot") -and (Test-Path "Microsoft.PowerShell.Core\FileSystem::\\wsl.localhost\Ubuntu\")) {
# 	echo "Creating symlink for wsl root"
# 	New-Item -ItemType SymbolicLink -Path "${env:USERPROFILE}\wslroot" -Value "Microsoft.PowerShell.Core\FileSystem::\\wsl.localhost\Ubuntu\" -Force
# }

# $IsConsoleHost = $Host.Name -eq 'ConsoleHost'
$hostName = [System.Net.Dns]::GetHostName()
if ($hostName -eq "mgoel-desk22222222") {
	$IsConsoleHost = $false
	if (-not $IsConsoleHost) {
		return
	}
	$devPath = "E:\mgd2off1\src"
	Set-Location $devPath
	$initPath = Join-Path $devPath "init.ps1"
	if (Test-Path $initPath) {
		. $initPath
	}
	$aiHelperPath = Join-Path $devPath "word/tools/automation/aiHelper.psm1"
	if (Test-Path $aiHelperPath) {
		Import-Module $aiHelperPath -Force -DisableNameChecking
		$env:PSModulePath = $env:PSModulePath + ";${devPath}\word\tools\automation"
	}
} elseif (($hostName -eq "mgoel-laptop")) {
	$aiHelperPath = "${env:USERPROFILE}/repos/mgoel/aiHelper.psm1"
	if (Test-Path $aiHelperPath) {
		Import-Module $aiHelperPath -Force -DisableNameChecking
		$env:PSModulePath = $env:PSModulePath + ";$aiHelperPath"
	}
}

$env:wslroot = "Microsoft.PowerShell.Core\FileSystem::\\wsl.localhost\Ubuntu\"

# New-Variable -Name "GenericOfficeBuildShell" -Visibility Public -Scope Global -Force
