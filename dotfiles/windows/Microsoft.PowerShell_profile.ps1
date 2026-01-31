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
    winget update --all --include-unknown

    # Only attempt Windows Update if elevated and module exists
    $isAdmin = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if ($isAdmin -and (Get-Module -ListAvailable PSWindowsUpdate)) {
        Write-Host ">>> WINDOWS UPDATES <<<"
        Import-Module PSWindowsUpdate -ErrorAction SilentlyContinue
        Get-WindowsUpdate | Out-Null
        Install-WindowsUpdate -AcceptAll
    } elseif (-not $isAdmin) {
        Write-Warning "Skipping Windows Update (not running as Administrator)"
    } else {
        Write-Warning "Skipping Windows Update (PSWindowsUpdate not installed)"
    }
}

Set-Location -Path "~"
Clear-Host
