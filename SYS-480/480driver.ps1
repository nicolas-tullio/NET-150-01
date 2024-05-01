Import-Module '/home/nicolas/Documents/Tech-Journal/SYS-480/modules/480-utils' -Force
#Call the Banner Function
480Banner
$conf = Get-480Config -config_path "/home/nicolas/Documents/Tech-Journal/SYS-480/480.json"
480Connect -server $conf.vcenter_server
LinkedClone -conf $conf