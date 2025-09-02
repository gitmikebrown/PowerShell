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
Distro vs Distribution in WSL
-----------------------------
Distribution: Refers to the upstream Linux OS, such as Ubuntu, Debian, or Alpine.
              It defines the base system and version (e.g., Ubuntu 20.04, Debian 12).
Distro: A specific, named instance of a distribution that you've installed in WSL.
        Each distro has its own filesystem, configuration, and identity.
Example:
  wsl --install -d Ubuntu-20.04 --name myUbuntu
    - 'Ubuntu-20.04' is the distribution (the Linux OS and version).
    - 'myUbuntu' is the distro name (your installed instance tracked by WSL).

  You can install multiple distros based on the same distribution, each with its own name and purpose.

--no-launch Note:
-----------------------------
  - Using --no-launch prevents the automatic setup of a username and password during installation. 
  - You will need to run `wsl -d <DistroName>` manually to complete the setup.
#>

<#
🛠️ WSL Install-Time Options

Short Flag   | Long Option         | Description
------------ | ------------------- | ------------------------------------------------------------
-d           | --distribution      | Specifies which Linux distribution to install
-l           | --list              | Lists available or installed distributions
-o           | --online            | Used with --list to show online distros
             | --install           | Installs WSL and optionally a distribution
             | --name              | Assigns a custom name to the installed distro
             | --no-launch         | Prevents auto-launch after install. Requires manual setup.
             | --web-download      | Installs from online source instead of Store

🔎 Notes:
- Short flags are great for quick CLI use.
- Long options are preferred in scripts for clarity and handoff.
- Some options (like --install, --set-default) have no short equivalent.
#>

# ─────────────────────────────────────────────
# 🚀 Install Ubuntu with a custom wsl name
# ─────────────────────────────────────────────
wsl --install -d Ubuntu --name $(Read-Host "Enter a custom name for your Ubuntu install")

# ─────────────────────────────────────────────
# 📦 Install additional distributions
# ─────────────────────────────────────────────
wsl --install -d Ubuntu-24.04

# ─────────────────────────────────────────────
# 📋 List distros available for install
# ─────────────────────────────────────────────
wsl -l -o


# ─────────────────────────────────────────────
# 🧭 Set default distro
# ─────────────────────────────────────────────
wsl --set-default Ubuntu

<#
🧪 WSL Runtime Options

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
#>

# ─────────────────────────────────────────────
# 📋 List installed distros with version info
# ─────────────────────────────────────────────
wsl -l -v     

# ─────────────────────────────────────────────
# 📤 Export a distro to a .tar file
# ─────────────────────────────────────────────
wsl --export Ubuntu D:\Backups\UbuntuBackup.tar

# ─────────────────────────────────────────────
# 📥 Import a distro from a .tar file
# ─────────────────────────────────────────────
wsl --import UbuntuRestored D:\WSL\UbuntuRestored D:\Backups\UbuntuBackup.tar --version 2

# ─────────────────────────────────────────────
# 🧾 Run a command inside the default distro
# ─────────────────────────────────────────────
wsl -c "sudo apt update && sudo apt upgrade -y"

# ─────────────────────────────────────────────
# 🧹 Unregister a distro (destructive!) TOTAL DELETION
# ─────────────────────────────────────────────
# wsl --unregister <DistroName>

# ─────────────────────────────────────────────
# 🛑 Terminate or shut down WSL
# ─────────────────────────────────────────────
wsl --terminate Ubuntu
wsl --shutdown

# ─────────────────────────────────────────────
# 📊 Check WSL system status
# ─────────────────────────────────────────────
wsl --status
wsl --version



# ─────────────────────────────────────────────
# 📊 Steps to refresh an install
# ─────────────────────────────────────────────
wsl --terminate bash
wsl --unregister bash
wsl --install -d Ubuntu --name bash

$confirm = Read-Host "This will permanently delete the 'bash' distro. Type YES to confirm"
if ($confirm -eq "YES") {
    wsl --terminate bash
    wsl --unregister bash
}