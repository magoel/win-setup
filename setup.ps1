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

# write a function to install chocolatey
function script:Install-Chocolatey
{
	<#
		.SYNOPSIS
		Install Chocolatey
		.DESCRIPTION
		Install Chocolatey
		.EXAMPLE
		Install-Chocolatey
#>
		if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
			Write-Host "Installing Chocolatey"
			[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials;
			invoke-expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
		}
		else {
			Write-Host "Chocolatey is already installed"
		}
		#refresh environment variables
		refreshenv
}


# write a function to install sysinternals
function script:Install-Sysinternals
{
	<#
		.SYNOPSIS
		Install Sysinternals
		.DESCRIPTION
		Install Sysinternals
		.EXAMPLE
		Install-Sysinternals
#>
	# check if sysinternals is installed
	if (-not (Get-Command pslist -ErrorAction SilentlyContinue)) {
		Write-Host "Installing Sysinternals"
		choco install sysinternals -y
		refreshenv
	}
	else {
		Write-Host "Sysinternals is already installed"
	}
}


# write a function to install vim
function script:Install-Vim
{
	<#
		.SYNOPSIS
		Install Vim
		.DESCRIPTION
		Install Vim
		.EXAMPLE
		Install-Vim
#>
	# check if vim is installed
	if (-not (Get-Command vim -ErrorAction SilentlyContinue)) {
		Write-Host "Installing Vim"
		choco install vim -y
		refreshenv
	}
	else {
		Write-Host "Vim is already installed"
	}
}


# write a function to install pwsh
function script:Install-Pwsh
{
	<#
		.SYNOPSIS
		Install PowerShell
		.DESCRIPTION
		Install PowerShell
		.EXAMPLE
		Install-Pwsh
#>
	# check if pwsh is installed
	if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) {
		Write-Host "Installing PowerShell"
		winget install Microsoft.PowerShell
		refreshenv
	}
	else {
		Write-Host "PowerShell is already installed"
	}
}


# write a function to install github cli
function script:Install-GitHubCli
{
	<#
		.SYNOPSIS
		Install GitHub CLI
		.DESCRIPTION
		Install GitHub CLI
		.EXAMPLE
		Install-GitHubCli
#>
	# check if gh is installed
	if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
		Write-Host "Installing GitHub CLI"
		winget install GitHub.cli
		refreshenv
		gh auth login
	}
	else {
		Write-Host "GitHub CLI is already installed"
	}
}


# write a function to install vim setup
function script:Install-VimSetup
{
	<#
		.SYNOPSIS
		Install Vim Setup
		.DESCRIPTION
		Install Vim Setup
		.EXAMPLE
		Install-VimSetup
#>
		Write-Host "Installing Vim Setup"
		pushd ${Env:UserProfile}
		rm -Force ${Env:UserProfile}/_vimrc -ErrorAction SilentlyContinue
		rm -Force -Recurse ${Env:UserProfile}/_vim -ErrorAction SilentlyContinue
		rm -Force -Recurse ${Env:UserProfile}/.vim -ErrorAction SilentlyContinue
		if (Test-Path ${Env:UserProfile}/vimsetup) {
			pushd ${Env:UserProfile}/vimsetup
			git pull
			popd
		} else {
			gh repo clone magoel/vimsetup
		}
		mkdir -Force ${Env:UserProfile}/vim-swap -ErrorAction SilentlyContinue
		# create a symbolic link to the vim setup
		New-Item -ItemType SymbolicLink -Path ${Env:UserProfile}/_vim -Target ${Env:UserProfile}/vimsetup/vimfiles
		# check if vundle already exists, pull the latest else clone it
		if (Test-Path ${Env:UserProfile}/_vim/bundle/Vundle.vim) {
			rm -Force -Recurse ${Env:UserProfile}/_vim/bundle/Vundle.vim
		}
		gh repo clone VundleVim/Vundle.vim ${Env:UserProfile}/_vim/bundle/Vundle.vim
		vim -c ":PluginInstall" -c ":qa!"
		popd
}


# write a function to install jq
function script:Install-Jq
{
	<#
		.SYNOPSIS
		Install jq
		.DESCRIPTION
		Install jq
		.EXAMPLE
		Install-Jq
#>
	# check if jq is installed
	if (-not (Get-Command jq -ErrorAction SilentlyContinue)) {
		Write-Host "Installing jq"
		choco install jq -y
		refreshenv
	}
	else {
		Write-Host "jq is already installed"
	}
}


# write a function to install make
function script:Install-Make
{
	<#
		.SYNOPSIS
		Install make
		.DESCRIPTION
		Install make
		.EXAMPLE
		Install-Make
#>
	# check if make is installed
	if (-not (Get-Command make -ErrorAction SilentlyContinue)) {
		Write-Host "Installing make"
		choco install make -y
		refreshenv
	}
	else {
		Write-Host "make is already installed"
	}
}


# write a function to safely add a new alias
function script:Set-AliasSafely
{
	<#
		.SYNOPSIS
		Safely add a new alias
		.DESCRIPTION
		Safely add a new alias
		.EXAMPLE
		Set-AliasSafely
#>
	param(
		[Parameter(Mandatory=$true)]
		[string]$Name,
		[Parameter(Mandatory=$true)]
		$Value
	)
	# check if alias is already defined, if yes return
	if (Get-Alias -Name $Name -ErrorAction SilentlyContinue) {
		Write-Host "Alias $Name is already defined"
		return
	}
	$script:PSModuleAutoLoadingPreferencePrev = $PSModuleAutoLoadingPreference
	$PSModuleAutoLoadingPreference = 'None'
	try {
	# check if command with the same name is already defined, if yes return
		if (Get-Command -Name $Name -ErrorAction Ignore) {
			Write-Host "Command $Name is already defined"
		}
		else {
			New-Alias -Name $Name -Value $Value -Scope Global -ErrorAction Ignore
		}
	}
	catch {
		Write-Host "Failed to set alias $Name to $Value"
	}
	finally {
		$PSModuleAutoLoadingPreference = $script:PSModuleAutoLoadingPreferencePrev
	}
}


#write a function to install fzf
function script:Install-Fzf
{
	<#
		.SYNOPSIS
		Install fzf
		.DESCRIPTION
		Install fzf
		.EXAMPLE
		Install-Fzf
#>
	# check if fzf is installed
	if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
		Write-Host "Installing fzf"
		winget install fzf
		Install-Module -Name PSFzf -Scope CurrentUser -Force
		# Enable-PsFzfAliases
		refreshenv
	}
	else {
		Write-Host "fzf is already installed"
	}
	# script:Set-AliasSafely -Name fh -Value Invoke-FzfHistory
}


#install openssh server
function script:Install-OpenSSH
{
	<#
		.SYNOPSIS
		Install OpenSSH
		.DESCRIPTION
		Install OpenSSH
		.EXAMPLE
		Install-OpenSSH
#>
	# check if openssh is installed
	if (-not (Get-Command sshd -ErrorAction SilentlyContinue)) {
		Write-Host "Installing OpenSSH"
		Add-WindowsCapability -Online -Name OpenSSH.Server -ErrorAction SilentlyContinue
		# Get-WindowsCapability -Online | ? Name -like 'OpenSSH*'
		Get-NetFirewallRule -Name *OpenSSH-Server* -ErrorAction SilentlyContinue | Enable-NetFirewallRuleA
		start-Service sshd
		Set-Service -Name sshd -StartupType 'Automatic'
		Get-Service ssh-agent | Set-Service -StartupType 'DelayedAuto'
		Start-Service ssh-agent
		mkdir -p $env:UserProfile/.ssh -ErrorAction SilentlyContinue
		# Append to sshd_config
		@"
Port 22
PubkeyAuthentication yes
AuthorizedKeysFile	__USERPROFILE__/.ssh/authorized_keys
PasswordAuthentication no
"@ | Out-File -Append $env:ProgramData\ssh\sshd_config
		Restart-Service sshd
		refreshenv
	}
	else {
		Write-Host "OpenSSH is already installed"
	}
}



# Make symbolic link to powershell profile
function script:Make-ProfileLink
{
	<#
		.SYNOPSIS
		Make symbolic link to powershell profile
		.DESCRIPTION
		Make symbolic link to powershell profile
		.EXAMPLE
		Make-ProfileLink
#>
	$rc = Join-Path ${ScriptDir} Microsoft.PowerShell_profile.ps1
	$TargetPath = Join-Path $PSHOME profile.ps1
	if (-not (Test-Path $TargetPath)) {
		Write-Host "Creating profile link"
		New-Item -ItemType SymbolicLink -Path $TargetPath -Value $rc
	}
	else {
		Write-Host "Profile link already exists"
	}
}

#function to install PSReadline module
function script:Install-PSReadline
{
	<#
		.SYNOPSIS
		Install PSReadline
		.DESCRIPTION
		Install PSReadline
		.EXAMPLE
		Install-PSReadline
#>
	# check if PSReadline is installed
	if (-not (Get-Module -Name PSReadline -ListAvailable -ErrorAction SilentlyContinue)) {
		Write-Host "Installing PSReadline"
		Install-Module PSReadLine -Force -AllowPrerelease -SkipPublisherCheck
		refreshenv
	}
	else {
		Write-Host "PSReadline is already installed"
	}
}


script:Install-Pwsh
script:Install-PSReadline
script:Install-Chocolatey
script:Install-Sysinternals
script:Install-GitHubCli
script:Install-Vim
script:Install-VimSetup
script:Install-Jq
script:Install-Make
script:Install-Fzf
# script:Install-OpenSSH
script:Make-ProfileLink
