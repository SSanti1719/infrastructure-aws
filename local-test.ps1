$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"

$variables = @{
    "ZINCSEARCH_IP"="localhost"
    "ZINCSEARCH_PORT"="4080"
    "ZINCSEARCH_INDEX"="emailIndex"
    "ZINCSEARCH_FILES_DIR"="C:\Users\Asus\Documents\Technical_test\files"
    "ZINC_FIRST_ADMIN_USER"="admin"
    "ZINC_FIRST_ADMIN_PASSWORD"="Complexpass123"
    "ZINC_SERVER_PORT"="4080"
    "ENTRYPOINT_APIREST_ENABLED"="true"
    "ENTRYPOINT_APIREST_PORT"="3000"
    "BASIC_AUTH_USER"="API_USER"
    "BASIC_AUTH_PASS"="q1w2e3r4t5y6u7_internal"
    "JWT_AUTH_SECRET"="G4T0P3R00123ABC"
    "EXTERNAL_USER"="ssanti2001@gmail.com"
    "EXTERNAL_PASS"="admin"
}

foreach ($key in $variables.Keys) {
    $value = $variables[$key]
    Set-ItemProperty -Path $regPath -Name $key -Value $value
    $env:key = $value
}

Write-Host "Las variables de entorno se han definido de manera global en el sistema."
Start-Sleep -Seconds 5
Start-Process "powershell" -ArgumentList "-NoExit", "-Command", "zincsearch" -WindowStyle Normal
Start-Sleep -Seconds 5
Start-Process "powershell" -ArgumentList "-NoExit", "-Command", "cd indexer; go run ." -WindowStyle Normal
Start-Sleep -Seconds 5
Start-Process "powershell" -ArgumentList "-NoExit", "-Command", "cd api; go run ./application" -WindowStyle Normal
Start-Sleep -Seconds 5
Start-Process "powershell" -ArgumentList "-NoExit", "-Command", "cd email-front; npm install; npm run dev" -WindowStyle Normal