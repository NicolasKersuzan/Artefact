Function WaitForStartService($name)
{
    [ARRAY]$ServiceMSSQL
    $ServiceNb = 0
    While ($ServiceNb -eq 0)
    {
        $ServiceMSSQL = get-service -Name $name | Where-Object {$_.Status -eq "Running"}  | foreach {$_.Status}
        $ServiceNb = $ServiceMSSQL.count
        Write-host "Attente du démarrage du service $name"
        get-service -Name $name | Where-Object {$_.Status -eq "Running"}  | foreach ($_.Status)
    }
}

Function IsStartSQLServer($name)
{
    [ARRAY]$ServiceMSSQL
    $ServiceMSSQL = get-service -Name $name | Where-Object {$_.Status -eq "Running"}  | foreach {$_.Status}
    $ServiceNb =$ServiceMSSQL.count
    If  ($ServiceNb -gt 0)
    {
        return $true
    }
    Else
    {
        return $false
    }
    
}
Function IsStopSQLServer($name)
{
    [ARRAY]$ServiceMSSQL    
    $ServiceMSSQL = get-service -Name $name | Where-Object {$_.Status -eq "Stopped"}  | foreach {$_.Status}
    $ServiceNb = $ServiceMSSQL.count
    If  ($ServiceNb -gt 0)
    {
        return $true
    }
    Else
    {
        return $false
    }
}

Function WaitForStopService($name)
{
    [ARRAY]$ServiceMSSQL
    $ServiceNb = 0
    While ($ServiceNb -eq 0)
    {
        $ServiceMSSQL = get-service -Name $name | Where-Object {$_.Status -eq "Stopped"}  | foreach {$_.Status}
        $ServiceNb = $ServiceMSSQL.count
        Write-host "Attente de l'arrêt du service $name"
        get-service -Name $name | Where-Object {$_.Status -eq "Stopped"}  | foreach ($_.Status)
    }
}

#MSSQLSERVER
#SQLSERVERAGENT

Try { 

    if (IsStartSQLServer("SQLSERVERAGENT") -eq $true)
    {
        stop-service "SQLSERVERAGENT"
    }
    WaitForStopService("SQLSERVERAGENT")
    
    if (IsStartSQLServer("SQLSERVERAGENT") -eq $false)
    {
       start-service "MSSQLSERVER" 
    }

    $ComputerName = $env:COMPUTERNAME
    $Result = $(sqlcmd -S $ComputerName -Q "SELECT Name FROM sys.servers WHERE Server_Id = 0")
    $OldComputerName = $Result[2]

    # suppression de l'ancien nom de l'instance
    $cmd = 'EXEC SP_DROPSERVER ' + "`'$($OldComputerName) + `'"
    SQLCMD -S  $($ComputerName) -Q `"$($cmd)`"

    # ajout du nouveau nom de l'instance
    $cmd = "EXEC SP_ADDSERVER  `'$($ComputerName)`', `'local`'" 
    SQLCMD -S $($ComputerName) -Q $($cmd)
    stop-service "MSSQLSERVER"

    if (IsStopSQLServer("MSSQLSERVER") -eq $true)
    {
        start-service "MSSQLSERVER"
    }

    WaitForStartService("MSSQLSERVER")
    Start-service "SQLSERVERAGENT"
    WaitForStartService("SQLSERVERAGENT")
}
catch
{
    throw ($Error[0])
}







