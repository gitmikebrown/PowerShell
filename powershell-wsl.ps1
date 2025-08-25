


#Install wsl
wsl --install


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