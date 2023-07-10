$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
trap {
    Write-Host "ERROR: $_"
    Write-Host (($_.ScriptStackTrace -split '\r?\n') -replace '^(.*)$','ERROR: $1')
    Write-Host (($_.Exception.ToString() -split '\r?\n') -replace '^(.*)$','ERROR EXCEPTION: $1')
    Exit 1
}

$serviceName = 'mediamtx'
$serviceUsername = "NT SERVICE\$serviceName"
$serviceHome = "$env:ProgramData\$serviceName"

function nssm {
    nssm.exe @Args
    if ($LASTEXITCODE) {
        throw "$(@('nssm')+$Args | ConvertTo-Json -Compress -Depth 100) failed with exit code $LASTEXITCODE"
    }
}

function Install-Service {
    Uninstall-Service
    Write-Output "Installing the $serviceName service..."
    nssm install $serviceName "$toolsPath\mediamtx\mediamtx.exe"
    nssm set $serviceName Start SERVICE_AUTO_START
    nssm set $serviceName AppDirectory $serviceHome
    nssm set $serviceName AppEnvironmentExtra NO_COLOR=1
    [string[]]$result = sc.exe sidtype $serviceName unrestricted
    if ($result -ne '[SC] ChangeServiceConfig2 SUCCESS') {
        throw "sc.exe sidtype failed with $result"
    }
    [string[]]$result = sc.exe config $serviceName obj= $serviceUsername
    if ($result -ne '[SC] ChangeServiceConfig SUCCESS') {
        throw "sc.exe config failed with $result"
    }
    [string[]]$result = sc.exe failure $serviceName reset= 0 actions= restart/60000
    if ($result -ne '[SC] ChangeServiceConfig2 SUCCESS') {
        throw "sc.exe failure failed with $result"
    }
    nssm set $serviceName AppRotateFiles 1
    nssm set $serviceName AppRotateOnline 1
    nssm set $serviceName AppRotateSeconds 86400
    nssm set $serviceName AppRotateBytes (10*1024*1024)
    nssm set $serviceName AppStdout "$serviceHome\logs\stdout.log"
    nssm set $serviceName AppStderr "$serviceHome\logs\stderr.log"
    @('logs') | ForEach-Object {
        $path = "$serviceHome\$_"
        mkdir -Force $path | Out-Null
        Disable-CAclInheritance $path
        'Administrators',$serviceUsername | ForEach-Object {
            Write-Host "Granting $_ FullControl to $path..."
            Grant-CPermission `
                -Identity $_ `
                -Permission FullControl `
                -Path $path
        }
    }
    Write-Host "Granting the SeServiceLogonRight privilege to the $serviceUsername user..."
    Grant-CPrivilege -Privilege SeServiceLogonRight -Identity $serviceUsername
    Write-Host "Starting the $serviceName service..."
    Start-Service $serviceName
}

function Uninstall-Service {
    while ($true) {
        $service = Get-Service -ErrorAction SilentlyContinue $serviceName
        if (!$service) {
            break
        }
        if ($service.Status -eq 'Stopped') {
            Write-Host "Uninstalling the $serviceName service..."
            nssm remove $serviceName confirm
            break
        }
        Write-Host "Stopping the $serviceName service..."
        Stop-Service -ErrorAction SilentlyContinue $serviceName
    }
    if (Test-CIdentity -Name $serviceUsername) {
        Write-Host "Revoking the SeServiceLogonRight privilege from the $serviceUsername user..."
        Revoke-CPrivilege -Privilege SeServiceLogonRight -Identity $serviceUsername
    }
}
