# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

# ValidateSQL.ps1

param (
    [string]$Workspace,
    [string]$MetaEdExtensionName
)

function Test-SQL {
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null

    $script:databseCSB   = New-Object System.Data.Common.DbConnectionStringBuilder $true
    $databseCSB.Server   = 'localhost'
    $databseCSB.Provider = 'SQLNCLI11'
    $databseCSB.Database = "MetaEd_SQL_Validation_Test"

    $server   = New-Object 'Microsoft.SqlServer.Management.Smo.Server' $databseCSB.Server
    try {
        $server.KillDatabase($databseCSB.Database)
    } catch {
        Write-Host $_
        $Error.Clear()
    }

    $database = New-Object 'Microsoft.SqlServer.Management.Smo.Database' ($server, $databseCSB.Database)
    $database.RecoveryModel = [Microsoft.SqlServer.Management.Smo.RecoveryModel]::Simple
    $database.Create()

    $conn = new-object Microsoft.SqlServer.Management.Common.ServerConnection
    $conn.ConnectionString = "Database=$($databseCSB.Database); Data Source=$($databseCSB.Server); Persist Security Info=True; Trusted_Connection=True; Connection Timeout=120"
    $conn.StatementTimeout = 60
    $srv = New-Object 'Microsoft.SqlServer.Management.Smo.Server' ($conn)

    $scripts = @()

    $basePath = Join-Path $Workspace 'MetaEdOutput'
    $latestSqlServerScriptPath = Join-Path $basePath 'EdFi/Database/SQLServer/ODS'
    $deprecatedScriptPath = Join-Path $basePath 'ODS-SQLServer'

    if (Test-Path $latestSqlServerScriptPath) {
        $structurePath = Join-Path $latestSqlServerScriptPath 'Structure'
        $dataPath = Join-Path $latestSqlServerScriptPath 'Data'

        if (Test-Path $structurePath) {
            $scripts += Get-ChildItem $structurePath -Filter '*.sql'
        }
        if (Test-Path $dataPath) {
            $scripts += Get-ChildItem $dataPath -Filter '*.sql'
        }

        if (Test-Path $structurePath) {
            $structureSubTypePaths = Get-ChildItem $structurePath -Directory
            foreach ($subTypePath in $structureSubTypePaths) {
                $scripts += Get-ChildItem $subTypePath.FullName -Filter '*.sql' -Recurse
            }
        }
        if (Test-Path $dataPath) {
            $dataSubTypePaths = Get-ChildItem $dataPath -Directory
            foreach ($subTypePath in $dataSubTypePaths) {
                $scripts += Get-ChildItem $subTypePath.FullName -Filter '*.sql' -Recurse
            }
        }
    }
    elseif (Test-Path $deprecatedScriptPath) {
        $scripts = Get-ChildItem $deprecatedScriptPath -Filter '*.sql'
    }

	if (-not [string]::IsNullOrWhiteSpace($MetaEdExtensionName)) {
        $extensionSqlServerScriptPath = Join-Path $basePath "$MetaEdExtensionName\Database\SQLServer\ODS"
        if (Test-Path $extensionSqlServerScriptPath) {
            $structurePath = Join-Path $extensionSqlServerScriptPath 'Structure'
            $dataPath = Join-Path $extensionSqlServerScriptPath 'Data'

            if (Test-Path $structurePath) {
                $scripts += Get-ChildItem $structurePath -Filter '*.sql'
            }
            if (Test-Path $dataPath) {
                $scripts += Get-ChildItem $dataPath -Filter '*.sql'
            }

            if (Test-Path $structurePath) {
                $structureSubTypePaths = Get-ChildItem $structurePath -Directory
                foreach ($subTypePath in $structureSubTypePaths) {
                    $scripts += Get-ChildItem $subTypePath.FullName -Filter '*.sql' -Recurse
                }
            }
            if (Test-Path $dataPath) {
                $dataSubTypePaths = Get-ChildItem $dataPath -Directory
                foreach ($subTypePath in $dataSubTypePaths) {
                    $scripts += Get-ChildItem $subTypePath.FullName -Filter '*.sql' -Recurse
                }
            }
        }
    }

    foreach ($script in $scripts) {
        try {
            $elapsed = Use-StopWatch {
                $contents = Get-Content "$($script.FullName)"
                $sql = [string]::Join([Environment]::NewLine, $contents);
                $srv.ConnectionContext.ExecuteNonQuery($sql) | Out-Null
            }
            Write-Result $true $script.Name $elapsed
        } catch {
            Write-Result $false $script.Name $elapsed $_.Exception
        }
    }
}

function Write-Result {
    [CmdletBinding()]
    param(
        [parameter(mandatory = $true)]
        [boolean] $Passed,

        [parameter(mandatory = $true)]
        [string] $Name,

        [parameter(mandatory = $false)]
        [string] $Elapsed,

        [parameter(mandatory = $false)]
        $Exception
    )
    if ($Elapsed -ne $null) {
        $Elapsed = "($Elapsed`ms)"
    }
    if ($Passed) {
        Write-Host " PASS " -BackgroundColor Green -ForegroundColor Black -NoNewline
        Write-Host " $Name $Elapsed"
    } else {
        Write-Host " FAIL " -BackgroundColor Red -ForegroundColor Black -NoNewline
        Write-Host " $Name $Elapsed`r`n"
        if ($Exception -ne $null) {
            Write-Error $Exception
        }
    }
}

function Use-StopWatch {
    param(
        [parameter(mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [scriptblock] $ScriptBlock
    )
    $elapsed = [System.Diagnostics.Stopwatch]::StartNew()
    . $ScriptBlock
    return $elapsed.ElapsedMilliseconds
}

$Error.Clear()
Write-Host " "
$elapsed = Use-StopWatch {
    Test-SQL
}
Write-Host "`r`n Validation finished in $elapsed`ms. `r`n"
if ($Error.Count -gt 0) {
    exit 1
}
