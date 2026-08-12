# Prompt securely for Render API key and list services
$sec = Read-Host 'Paste your Render API key (input hidden)' -AsSecureString
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
$token = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
$headers = @{ Authorization = "Bearer $token" }
try {
  $services = Invoke-RestMethod -Uri 'https://api.render.com/v1/services' -Headers $headers
  $services | Select-Object id, name, "serviceDetails.repository" | Format-Table -AutoSize
} catch {
  Write-Error "Failed to list services: $_"
}
