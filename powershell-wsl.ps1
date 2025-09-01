<#
.SYNOPSIS
Menu-driven Ubuntu update/upgrade manager for WSL with logging, input validation, and help.

.DESCRIPTION
This PowerShell script provides a structured interface for managing Ubuntu updates inside WSL.
Includes logging, input validation, and contextual help prompts.

.FILENAME
ubuntu-UPDATE.ps1

.AUTHOR
Michael Brown

.VERSION
1.2.0

.LASTUPDATED
September 1, 2025

.NOTES
Help simplify the WSL system.
#>

<#

WSL Install-Time Options

Short Flag   | Long Option         | Description
------------ | ------------------- | ------------------------------------------------------------
-d           | --distribution      | Specifies which Linux distribution to install
-l           | --list              | Lists available or installed distributions
-o           | --online            | Used with --list to show online distros
             | --install           | Installs WSL and optionally a distribution
             | --name              | Assigns a custom name to the installed distro
             | --no-launch         | Prevents auto-launch after install
             | --web-download      | Installs from online source instead of Store


WSL Runtime Options

Short Flag   | Long Option         | Description
------------ | ------------------- | ------------------------------------------------------------
-v           | --verbose           | Shows detailed info (name, state, WSL version)
             | --set-default       | Sets the default distro used by `wsl`
             | --set-version       | Sets WSL version (1 or 2) for a distro
             | --export            | Exports a distro to a `.tar` file
             | --import            | Imports a distro from a `.tar` file
             | --unregister        | Removes a distro from WSL
             | --terminate         | Stops a running distro
             | --shutdown          | Shuts down all WSL instances
             | --mount             | Mounts a physical disk into WSL
             | --status            | Shows WSL system status
             | --version           | Displays WSL version info
             | --help              | Displays help info for WSL
-c           | *(no long form)*    | Executes a command inside the default distro (e.g. `wsl -c "ls -la"`)
           

Note:
- Short flags are great for quick CLI use.
- Long options are preferred in scripts for clarity and handoff.
- Some options (like --install, --set-default) have no short equivalent.
#>

#Install a wsl
wsl --install --no-launch -d Ubuntu --name $(Read-Host "Enter a custom name for your Ubuntu install")


#change the distribution installed and/or
#install additional Linux distributions after the initial install
#wsl --install -d <Distribution Name>
wsl --install -d Ubuntu-24.04


#list of available Linux distributions available for download through the online store
wsl --list --online 
#or wsl -l -o

#list your installed Linux distributions and check the version of WSL each is set to
wsl -l -v

#To set the default Linux distribution used with the wsl command
#wsl -s <DistributionName>
wsl -s Ubuntu
#or wsl --set-default <DistributionName>