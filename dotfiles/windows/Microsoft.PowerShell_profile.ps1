function prompt {
    $hostname = [System.Net.Dns]::GetHostName()
    $username = $env:USERNAME
    $path = $executionContext.SessionState.Path.CurrentLocation.Path
    $path = $path.Replace($HOME, "~")
    $branch = ""

    # Detect git branch anywhere inside a repo
    if (git rev-parse --is-inside-work-tree 2>$null) {
        $branchName = git rev-parse --abbrev-ref HEAD 2>$null
        if ($branchName) {
            $branch = " [$branchName]"
        }
    }

    Write-Host $username -NoNewLine -ForegroundColor Green
    Write-Host "@" -NoNewLine -ForegroundColor Green
    Write-Host $hostname -NoNewLine -ForegroundColor Green
    Write-Host ":" -NoNewLine -ForegroundColor White
    Write-Host $path -NoNewLine -ForegroundColor Blue

    if ($branch) {
        Write-Host $branch -NoNewLine -ForegroundColor DarkYellow
    }

    Write-Host "$" -NoNewLine -ForegroundColor White
    return " "
}

function rm {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Position = 0)]
        [string[]]$Path,

        [switch]$r,
        [switch]$f
    )

    if (-not $Path) {
        Write-Error "rm: missing operand"
        return
    }

    $params = @{
        Path = $Path
    }

    if ($r) {
        $params.Recurse = $true
    }

    if ($f) {
        $params.Force = $true
        $params.ErrorAction = 'SilentlyContinue'
    }

    Remove-Item @params
}

function touch {
    param(
        [Parameter(Mandatory)]
        [string]$FileName
    )

    if (-not (Test-Path $FileName)) {
        New-Item -ItemType File -Path $FileName | Out-Null
    } else {
        (Get-Item $FileName).LastWriteTime = Get-Date
    }
}

function ll {
    param([string[]]$Args)
    Get-ChildItem -Force @Args
}

function update {
Write-Host ">>> EMPTY RECYCLE BIN <<<"
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

Write-Host ">>> UPDATE WINGET APPS <<<"
winget upgrade --all --include-unknown

# Check for Administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Warning "Skipping Windows and driver updates (not running as Administrator)"
    return
}

# Check for PSWindowsUpdate
if (-not (Get-Module -ListAvailable PSWindowsUpdate)) {
    Write-Warning "Skipping Windows and driver updates (PSWindowsUpdate not installed)"
    return
}

Import-Module PSWindowsUpdate -ErrorAction Stop

Write-Host ">>> UPDATE WINDOWS <<<"
Install-WindowsUpdate `
    -MicrosoftUpdate `
    -NotCategory "Drivers" `
    -AcceptAll

Write-Host ">>> UPDATE DRIVERS <<<"
Install-WindowsUpdate `
    -MicrosoftUpdate `
    -Category "Drivers" `
    -AcceptAll

Write-Host ">>> UPDATE COMPLETE <<<"

}

Set-Location -Path "~"
Clear-Host
