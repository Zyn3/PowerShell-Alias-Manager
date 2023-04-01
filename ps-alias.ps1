# Set alias file path
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$aliasFile = Join-Path $scriptPath 'aliases.csv'

if (!(Test-Path $aliasFile)) {
    New-Item -ItemType File $aliasFile -Force | Out-Null
}

# Function to add a new alias
function Add-Alias {
    param(
        [Parameter(Mandatory=$true)]
        [string]$name,
        [Parameter(Mandatory=$true)]
        [string]$path,
        [switch]$Global
    )

    $guid = [guid]::NewGuid().ToString()

    $aliases = Import-Csv $aliasFile -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne $name }

    $alias = New-Object PSObject -Property @{
        ID = $guid
        Name = $name
        Path = $path
    }

    $aliases += $alias | Sort-Object Name

    $aliases | Export-Csv $aliasFile -NoTypeInformation -Force

    if ($Global) {
        $linkPath = Join-Path 'C:\Windows\System32' $name
    }
    else {
        $linkPath = Join-Path $env:USERPROFILE $name
    }

    if (Test-Path $linkPath) {
        Remove-Item $linkPath -Force
    }

    New-Item -ItemType SymbolicLink -Path $linkPath -Value $path -Force -ErrorAction Stop | Out-Null

}

# Function to remove an alias
function Remove-Alias {
    param(
        [Parameter(Mandatory=$true)]
        [string]$name,
        [switch]$Global
    )

    $aliases = Import-Csv $aliasFile -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne $name }

    if ($aliases) {
        $aliases | Export-Csv $aliasFile -NoTypeInformation -Force
    }
    else {
        if ($Global) {
            $linkPath = Join-Path 'C:\Windows\System32' $name
        }
        else {
            $linkPath = Join-Path $env:USERPROFILE $name
        }
        Remove-Item -ItemType SymbolicLink -Path $linkPath -Recurse -Force
    }
}

# Function to list all aliases
function List-Alias {
    $aliases = Import-Csv $aliasFile -ErrorAction SilentlyContinue | Sort-Object Name

    if ($aliases) {
        $aliases | Select-Object @{n='Global';e={$_.Global}}, @{n='Name';e={$_.Name}}, Path, ID | Format-Table -AutoSize
    } else {
        Write-Host "No aliases configured."
    }
}

# Main
if ($args.Count -eq 0) {
    Write-Host "Usage: .\ps-alias.ps1 [add|remove|list]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  add    Adds an alias. Required parameters: --name, --path. Optional parameter: --global."
    Write-Host "  remove Removes an alias. Required parameter: --name."
    Write-Host "  list   Lists all aliases."
}
elseif ($args[0] -eq "add") {
    if ($args.Length -ne 5 -and $args.Length -ne 6) {
        Write-Host "Invalid number of arguments. Usage: .\ps-alias.ps1 add --name <name> --path <path> [--global <true/false>]"
        exit
    }

    if ($args[1] -ne "--name" -or $args[3] -ne "--path") {
        Write-Host "Invalid arguments. Usage: .\ps-alias.ps1 add --name <name> --path <path> [--global <true/false>]"
        exit
    }

    $name = $args[2]
    $path = $args[4]
    $global = $false

    if ($args.Length -eq 6) {
        if ($args[5] -ne "--global") {
            Write-Host "Invalid argument. Usage: .\ps-alias.ps1 add --name <name> --path <path> [--global <true/false>]"
            exit
        }

        $global = $true
    }

    Add-Alias -Name $name -Path $path -Global $global
}
elseif ($args[0] -eq "remove") {
    if ($args.Length -ne 2) {
        Write-Host "Invalid number of arguments. Usage: .\ps-alias.ps1 remove --name <name>"
        exit
    }

    if ($args[1] -ne "--name") {
        Write-Host "Invalid arguments. Usage: .\ps-alias.ps1 remove --name <name>"
        exit
    }

    $name = $args[2]

    Remove-Alias -Name $name
}
elseif ($args[0] -eq "list") {
    List-Alias
}
else {
    Write-Host "Invalid command. Usage: .\ps-alias.ps1 [add|remove|list]"
}
