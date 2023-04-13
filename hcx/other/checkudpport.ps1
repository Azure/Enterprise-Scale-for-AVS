$sourceIP = "127.0.0.1" # Replace with source IP address
$destinationIP = "127.0.0.2" # Replace with destination IP address
$PORT = 8080  # Replace with target port
$MESSAGE = "test message"

$socket = New-Object System.Net.Sockets.UdpClient($sourceIP, 0)
$socket.Connect($destinationIP, $PORT)
$socket.Send([System.Text.Encoding]::ASCII.GetBytes($MESSAGE), $MESSAGE.Length)

$data = $socket.Receive([ref]$remoteEP)
Write-Host "Received from $($remoteEP.Address): $($([System.Text.Encoding]::ASCII.GetString($data)))"
