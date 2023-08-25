param (
    [string]$folderPath
)

# Validate folder path
if (-not (Test-Path -Path $folderPath -PathType Container)) {
    Write-Host "Invalid folder path: $folderPath"
    exit
}

# Calculate hash of a file using SHA-256
function Calculate-FileHash {
    param (
        [string]$filePath
    )
    
    $hashAlgorithm = [System.Security.Cryptography.SHA256]::Create()
    $fileStream = [System.IO.File]::OpenRead($filePath)
    $hashBytes = $hashAlgorithm.ComputeHash($fileStream)
    $fileStream.Close()
    
    $hashString = [BitConverter]::ToString($hashBytes) -replace '-'
    return $hashString
}

# Recursively compute hashes of all files
$hashes = @{}
Get-ChildItem -Path $folderPath -File -Recurse | ForEach-Object {
    $filePath = $_.FullName
    $hash = Calculate-FileHash -filePath $filePath
    $hashes[$hash] += @($filePath)
}

# Identify and display duplicates
$table = @{}
foreach ($hash in $hashes.Keys) {
    $files = $hashes[$hash]
    if ($files.Count -gt 1) {
        $table[$hash] = $files
    }
}

if ($table.Count -gt 0) {
    Write-Host "Duplicate Files:"
    foreach ($hash in $table.Keys) {
        Write-Host ("Hash: $hash")
        $table[$hash] | ForEach-Object {
            Write-Host ("  $_")
        }
        Write-Host ("=" * 40)
    }
} else {
    Write-Host "No duplicate files found."
}
