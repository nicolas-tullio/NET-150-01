param($network, $server)

for ($ip = 1; $ip -le 254; $ip++){
    $ipv4 = "$network.$ip"
    $name = Resolve-DnsName -DnsOnly $ipv4 -Server $server -ErrorAction Ignore | select  -ExpandProperty NameHost 

    if ($name){
        Write-Host "$ipv4 $name"
    } 
}
