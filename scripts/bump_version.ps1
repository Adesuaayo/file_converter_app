<#
.SYNOPSIS
    Bumps the version in pubspec.yaml and optionally creates a git tag.

.DESCRIPTION
    Updates the 'version:' line in pubspec.yaml to the specified semver+build
    and optionally commits + tags so you can push to trigger the CI release.

.PARAMETER Version
    Semantic version string, e.g. "1.0.1"

.PARAMETER Build
    Integer build/version-code number, e.g. 2

.PARAMETER Tag
    If set, commits the change and creates a git tag (v<Version>).

.EXAMPLE
    .\scripts\bump_version.ps1 -Version "1.0.1" -Build 2
    .\scripts\bump_version.ps1 -Version "1.1.0" -Build 3 -Tag
#>
param(
    [Parameter(Mandatory)][string]$Version,
    [Parameter(Mandatory)][int]$Build,
    [switch]$Tag
)

$pubspec = Join-Path $PSScriptRoot "..\pubspec.yaml"
if (-not (Test-Path $pubspec)) {
    Write-Error "pubspec.yaml not found at $pubspec"
    exit 1
}

$content = Get-Content $pubspec -Raw

$oldPattern = 'version:\s*\S+'
$newValue   = "version: $Version+$Build"

if ($content -notmatch $oldPattern) {
    Write-Error "Could not find 'version:' line in pubspec.yaml"
    exit 1
}

$updated = $content -replace $oldPattern, $newValue
Set-Content $pubspec $updated -NoNewline

Write-Host "Updated pubspec.yaml -> $newValue" -ForegroundColor Green

if ($Tag) {
    git add $pubspec
    git commit -m "chore: bump version to $Version+$Build"
    git tag "v$Version"
    Write-Host "Created tag v$Version — push with:  git push origin main --tags" -ForegroundColor Cyan
}
