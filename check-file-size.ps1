# Function to get folder size in specified unit
function Get-FolderSize($path, $unit) {
    if (Test-Path $path) {
        $size = (Get-ChildItem $path -Recurse | Measure-Object -Property Length -Sum).Sum
        if ($size -ne $null) {
            switch ($unit.ToUpper()) {
                "KB" { return [math]::Round($size / 1KB, 2) }
                "MB" { return [math]::Round($size / 1MB, 2) }
                "GB" { return [math]::Round($size / 1GB, 2) }
                default { return [math]::Round($size / 1MB, 2) } # Default to MB
            }
        }
    }
    return 0
}

# Function to display folder contents and size
function Show-FolderContents($path, $unit) {
    if (Test-Path $path) {
        $folderSize = Get-FolderSize $path $unit
        Write-Host "Size of '$path' folder: $folderSize $unit"

        Write-Host "`nContents of the '$path' folder:"
        Get-ChildItem $path | ForEach-Object {
            $itemSize = if ($_.PSIsContainer) { Get-FolderSize $_.FullName $unit } else { Get-FolderSize $_.FullName $unit }
            [PSCustomObject]@{
                Name          = $_.Name
                LastWriteTime = $_.LastWriteTime
                Size          = $itemSize
            }
        } | Format-Table Name, LastWriteTime, @{Name = "Size ($unit)"; Expression = { $_.Size }; Alignment = "Right" }
    }
    else {
        Write-Host "The folder '$path' does not exist."
    }
}

# Check if arguments are provided
if ($args.Count -lt 2) {
    Write-Host "Please provide the size unit (KB, MB, or GB) and one or more folder paths as arguments."
    Write-Host "Usage: .\script.ps1 <unit> <folder_path1> <folder_path2> ..."
    exit
}

# Get the size unit from the first argument
$sizeUnit = $args[0]

# Validate the size unit
if ($sizeUnit -notin @("KB", "MB", "GB")) {
    Write-Host "Invalid size unit. Please use KB, MB, or GB."
    exit
}

# Process each provided path (skipping the first argument which is the size unit)
for ($i = 1; $i -lt $args.Count; $i++) {
    Show-FolderContents $args[$i] $sizeUnit
    Write-Host "`n------------------------`n"
}

# Print current directory for context
Write-Host "Current directory: $(Get-Location)"