$projectPath = "C:\Users\IT\motogate V 1\motogate_api"
$pidFile     = "$projectPath\tmp\pids\server.pid"

Set-Location $projectPath

if (Test-Path $pidFile) {
    $serverPid = Get-Content $pidFile
    $proc = Get-Process -Id $serverPid -ErrorAction SilentlyContinue

    if ($proc) {
        Write-Host "Stopping Rails server (PID $serverPid)..." -ForegroundColor Yellow
        Stop-Process -Id $serverPid -Force
        Remove-Item $pidFile -ErrorAction SilentlyContinue
        Write-Host "Server stopped." -ForegroundColor Red
    } else {
        Write-Host "PID file found but process not running. Cleaning up..." -ForegroundColor Gray
        Remove-Item $pidFile -ErrorAction SilentlyContinue
        Write-Host "Starting Rails server..." -ForegroundColor Green
        Start-Process "powershell" -ArgumentList "-NoExit -Command Set-Location '$projectPath'; ruby bin/rails server" -WindowStyle Normal
    }
} else {
    Write-Host "Starting Rails server..." -ForegroundColor Green
    Start-Process "powershell" -ArgumentList "-NoExit -Command Set-Location '$projectPath'; ruby bin/rails server" -WindowStyle Normal
}
