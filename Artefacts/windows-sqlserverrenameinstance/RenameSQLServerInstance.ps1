

stop-service "SQLSERVERAGENT"
[INT]$ServiceNb = 0
[String]$Service = get-service -Name "MSSQLSERVER" | foreach {$_.Status}

If ($Service -eq "Stopped")
{
    start-service "MSSQLSERVER"  
}
[ARRAY]$ServiceMSSQL
$ServiceNb = 0


SQLCMD -S "HYDRA" -Q "EXEC SP_DROPSERVER 'HYDRATEST'"
SQLCMD -S "HYDRA" -Q "EXEC SP_ADDSERVER 'HYDRA','local'"
stop-service "MSSQLSERVER"

$ServiceNb = 0
While ($ServiceNb -eq 0)
{
    $ServiceMSSQL = get-service -Name "MSSQLSERVER" | Where-Object {$_.Status -eq "Stopped"}  | foreach {$_.Status}
    $ServiceNb = $ServiceMSSQL.count
    Write-host $ServiceMSSQL.count
    get-service -Name "MSSQLSERVER" | Where-Object {$_.Status -eq "Stopped"}  | foreach ($_.Status)
}

start-service "MSSQLSERVER"
$ServiceNb = 0
While ($ServiceNb -eq 0)
{
    $ServiceMSSQL = get-service -Name "MSSQLSERVER" | Where-Object {$_.Status -eq "Running"}  | foreach {$_.Status}
    $ServiceNb = $ServiceMSSQL.count
    Write-host $ServiceMSSQL.count
    get-service -Name "MSSQLSERVER" | Where-Object {$_.Status -eq "Running"}  | foreach ($_.Status)
}
Start-service "SQLSERVERAGENT"




