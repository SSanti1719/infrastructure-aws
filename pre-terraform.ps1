$currentPath = Get-Location
$apiPath = Join-Path -Path $currentPath -ChildPath "api"
$indexerPath = Join-Path -Path $currentPath -ChildPath "indexer"
$dataPath = Join-Path -Path $currentPath -ChildPath "files"
$zincsearchPath = Join-Path -Path $currentPath -ChildPath "zincsearch"

if (-not (Test-Path $apiPath)) {
    Write-Host "La carpeta 'api' no existe en la ubicación actual."
    exit 1
}
if (-not (Test-Path $indexerPath)) {
    Write-Host "La carpeta 'indexer' no existe en la ubicación actual."
    exit 1
}
if (-not (Test-Path $dataPath)) {
    Write-Host "La carpeta 'data' no existe en la ubicación actual."
    exit 1
}
if (-not (Test-Path $zincsearchPath)) {
    Write-Host "La carpeta 'zincsearch' no existe en la ubicación actual."
    exit 1
}

$srcFolder = Join-Path -Path $currentPath -ChildPath "terraform/src"
if (-not (Test-Path $srcFolder)) {
    New-Item -ItemType Directory -Path $srcFolder | Out-Null
}

try {
    Compress-Archive -Path "$apiPath\*" -DestinationPath (Join-Path -Path $srcFolder -ChildPath "api.zip") -Force
    Write-Host "El archivo ZIP $apiPath se ha creado correctamente."

    Compress-Archive -Path "$indexerPath\*" -DestinationPath (Join-Path -Path $srcFolder -ChildPath "indexer.zip") -Force
    Write-Host "El archivo ZIP $indexerPath se ha creado correctamente."

    Compress-Archive -Path "$dataPath\*" -DestinationPath (Join-Path -Path $srcFolder -ChildPath "data.zip") -Force
    Write-Host "El archivo ZIP $dataPath se ha creado correctamente."

    Compress-Archive -Path "$zincsearchPath\*" -DestinationPath (Join-Path -Path $srcFolder -ChildPath "zincsearch.zip") -Force
    Write-Host "El archivo ZIP $zincsearchPath se ha creado correctamente."
} catch {
    Write-Host "Se produjo un error al comprimir el archivo ZIP: $_"
}