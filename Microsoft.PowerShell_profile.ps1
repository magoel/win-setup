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
