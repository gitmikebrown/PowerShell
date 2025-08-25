


#Powershell command to see if port is working
$address = "192.168.1.212";
$port = 22;
Test-NetConnection $address -Port $port;