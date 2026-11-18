# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

function Copy-UpdatedXsds {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$sourceDirectoryPaths,

        [Parameter(Mandatory = $true)]
        [string]$targetDirectoryPath
    )

    Get-ChildItem -Path $targetDirectoryPath | Remove-Item -Recurse -Force

    foreach ($sourceDirectoryPath in $sourceDirectoryPaths) {
        Copy-Item -Path "$sourceDirectoryPath/*" -Destination $targetDirectoryPath -Recurse -Force
    }
}

function Get-GitStatus {
    param(
        [Parameter(Mandatory = $true)]
        [string]$edfiModelRepoPath,

        [Parameter(Mandatory = $true)]
        [string]$edfiStandardRepoPath
    )

    $hasChanges = $false
    $gitStatus = Invoke-Execute { git -C $edfiStandardRepoPath status --porcelain }
    if (-not [string]::IsNullOrWhiteSpace($gitStatus)) {
        $hasChanges = $true
    }

    $lastEdFiStandardCommitHash = Invoke-Execute { git -C $edfiStandardRepoPath rev-parse HEAD }
    $lastEdFiModelCommitHash = Invoke-Execute { git -C $edfiModelRepoPath rev-parse HEAD }
    $lastEdFiModelCommitHashShort = Invoke-Execute { git -C $edfiModelRepoPath rev-parse --short HEAD }

    return @{
        hasChanges                   = $hasChanges
        lastEdFiStandardCommitHash   = $lastEdFiStandardCommitHash
        lastEdFiModelCommitHash      = $lastEdFiModelCommitHash
        lastEdFiModelCommitHashShort = $lastEdFiModelCommitHashShort
        headBranchName               = "xsd-update-$lastEdFiModelCommitHashShort"
    }
}

function Add-GithubBranch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$commitHash,

        [Parameter(Mandatory = $true)]
        [string]$branchName
    )

    Assert-EnvironmentVariablesInitialized(@("GITHUB_TOKEN"))

    Write-Host "Attempting to create the '$branchName' branch in the Ed-Fi-Data-Standard repository."

    $headers = @{
        Authorization          = "Bearer $Env:GITHUB_TOKEN"
        Accept                 = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
    }
    $body = @{
        ref = "refs/heads/$branchName"
        sha = $commitHash
    }

    Invoke-WebRequest `
        -Method Post `
        -ContentType 'application/json' `
        -Uri "https://api.github.com/repos/Ed-Fi-Alliance-OSS/Ed-Fi-Data-Standard/git/refs" `
        -Body @($body | ConvertTo-Json) `
        -Headers $headers
    | Out-Null
}

function Open-PullRequest {
    param(
        [Parameter(Mandatory = $true)]
        [string]$lastEdFiModelCommitHash,

        [Parameter(Mandatory = $true)]
        [string]$lastEdFiModelCommitHashShort,

        [Parameter(Mandatory = $true)]
        [string]$baseBranchName,

        [Parameter(Mandatory = $true)]
        [string]$headBranchName
    )

    Write-Host "Creating pull request..."
    $prTitle = "[XSD Update] Update from Ed-Fi-Model's ``$lastEdFiModelCommitHashShort`` commit"
    $prBody = "The [$lastEdFiModelCommitHashShort commit](https://github.com/Ed-Fi-Alliance-OSS/Ed-Fi-Model/commit/$lastEdFiModelCommitHash) got recently merged into the Ed-Fi-Model repository.`nThis PR brings the updated XSD files."

    $prUrl = Invoke-Execute { gh pr create --repo 'Ed-Fi-Alliance-OSS/Ed-Fi-Data-Standard' --title $prTitle --body $prBody --base $baseBranchName --head $headBranchName }
    Write-Host "Pull request created: $prUrl"

    Write-Host "Checking for outdated xsd-update PRs..."
    $outdatedPRs = Invoke-Execute { gh pr list --repo 'Ed-Fi-Alliance-OSS/Ed-Fi-Data-Standard' --base $baseBranchName --state open --json 'number,headRefName,createdAt' } | ConvertFrom-Json | Where-Object { $_.headRefName -like "xsd-update-*" -and $_.headRefName -ne $headBranchName }

    if ($outdatedPRs) {
        $mostRecentPR = $outdatedPRs | Sort-Object createdAt -Descending | Select-Object -First 1

        Write-Host "Found outdated xsd-update PR #$($mostRecentPR.number). Adding comment..."
        $commentBody = "There's a more recent XSD update PR: $prUrl`nThis PR may be outdated, consider closing it."
        Invoke-Execute { gh pr comment --repo 'Ed-Fi-Alliance-OSS/Ed-Fi-Data-Standard' $mostRecentPR.number --body $commentBody }
    }
}

function Invoke-Execute {
    param (
        [ScriptBlock]
        $Command
    )

    $global:lastexitcode = 0
    Invoke-Command -ScriptBlock $Command

    if ($lastexitcode -ne 0) {
        throw "Error executing command: $Command"
    }
}

function Assert-EnvironmentVariablesInitialized {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Names
    )

    foreach ($name in $Names) {
        if (-not (Test-Path "Env:$name")) {
            throw "The environment variable '$name' must be initialized."
        }
    }
}
