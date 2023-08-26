param (
    [string]$folderPath,
    [string]$fileType,
    [switch]$deleteDuplicates  # New switch parameter to enable deleting duplicate files
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

$files = Get-ChildItem -Path $folderPath -File -Recurse -Filter $fileType
$totalFiles = $files.Count
$currentFileIndex = 0

$hashes = @{}
$filesToDelete = @()  # Initialize an array to store files to be deleted

foreach ($file in $files) {
    $filePath = $file.FullName
    
    $currentFileIndex++
    $percentComplete = ($currentFileIndex / $totalFiles) * 100
    Write-Progress -Activity "Calculating Hashes" -Status "Processing: $($currentFileIndex) of $($totalFiles)" -PercentComplete $percentComplete

    $hash = Calculate-FileHash -filePath $filePath
    
    if ($hashes.ContainsKey($hash)) {
        $hashes[$hash] += @($filePath)
    } else {
        $hashes[$hash] = @($filePath)
    }
}

Write-Progress -Completed

if ($deleteDuplicates) {
    foreach ($hash in $hashes.Keys) {
        $filesList = $hashes[$hash]
        if ($filesList.Count -gt 1) {
            # Keep the first file (original) and delete the rest
            for ($i = 1; $i -lt $filesList.Count; $i++) {
                $fileToDelete = $filesList[$i]
                $filesToDelete += $fileToDelete
            }
        }
    }

    foreach ($fileToDelete in $filesToDelete) {
        Remove-Item -Path $fileToDelete -Force
        Write-Host "Deleted: $fileToDelete"
    }
} else {
    # Identify and display duplicates
    $table = @{}
    foreach ($hash in $hashes.Keys) {
        $filesList = $hashes[$hash]
        if ($filesList.Count -gt 1) {
            $table[$hash] = $filesList
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
}
