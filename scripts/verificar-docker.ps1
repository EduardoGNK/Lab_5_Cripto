# Script para verificar y ayudar a iniciar Docker Desktop
# Uso: .\scripts\verificar-docker.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Verificación de Docker Desktop" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si Docker está instalado
Write-Host "[1/4] Verificando instalación de Docker..." -ForegroundColor Yellow
$dockerVersion = docker --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "    $dockerVersion" -ForegroundColor Green
} else {
    Write-Host "[!] Error: Docker no está instalado" -ForegroundColor Red
    Write-Host "    Descarga Docker Desktop desde: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Verificar si el daemon responde
Write-Host ""
Write-Host "[2/4] Verificando conexión al daemon de Docker..." -ForegroundColor Yellow
$dockerInfo = docker info 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[+] Docker daemon está corriendo" -ForegroundColor Green
    $dockerRunning = $true
} else {
    Write-Host "[!] Docker daemon no responde" -ForegroundColor Red
    $dockerRunning = $false
}

# Verificar proceso de Docker Desktop
Write-Host ""
Write-Host "[3/4] Verificando proceso de Docker Desktop..." -ForegroundColor Yellow
$dockerProcess = Get-Process -Name "*Docker Desktop*" -ErrorAction SilentlyContinue
if ($dockerProcess) {
    Write-Host "[+] Docker Desktop está corriendo (PID: $($dockerProcess.Id))" -ForegroundColor Green
} else {
    Write-Host "[!] Docker Desktop no está corriendo" -ForegroundColor Yellow
    Write-Host "    Intentando iniciar Docker Desktop..." -ForegroundColor Yellow
    
    # Intentar rutas comunes de Docker Desktop
    $dockerPaths = @(
        "C:\Program Files\Docker\Docker\Docker Desktop.exe",
        "$env:LOCALAPPDATA\Programs\Docker\Docker\Docker Desktop.exe",
        "${env:ProgramFiles(x86)}\Docker\Docker\Docker Desktop.exe"
    )
    
    $dockerFound = $false
    foreach ($path in $dockerPaths) {
        if (Test-Path $path) {
            Write-Host "    Iniciando desde: $path" -ForegroundColor Gray
            Start-Process $path
            $dockerFound = $true
            break
        }
    }
    
    if (-not $dockerFound) {
        Write-Host ""
        Write-Host "[!] No se pudo encontrar Docker Desktop automáticamente" -ForegroundColor Red
        Write-Host "    Por favor inicia Docker Desktop manualmente:" -ForegroundColor Yellow
        Write-Host "    1. Busca 'Docker Desktop' en el menú de inicio" -ForegroundColor White
        Write-Host "    2. O busca el ícono en el escritorio" -ForegroundColor White
        Write-Host "    3. Espera hasta que el ícono muestre 'Docker Desktop is running'" -ForegroundColor White
        Write-Host ""
        Write-Host "    Luego ejecuta este script nuevamente" -ForegroundColor Yellow
        exit 1
    } else {
        Write-Host "[+] Docker Desktop iniciado" -ForegroundColor Green
        Write-Host "    Esperando a que Docker Desktop esté listo..." -ForegroundColor Yellow
        Write-Host "    (Esto puede tardar 1-2 minutos)" -ForegroundColor Gray
        
        # Esperar hasta que Docker responda (máximo 2 minutos)
        $maxWait = 120
        $waited = 0
        $interval = 5
        
        while ($waited -lt $maxWait) {
            Start-Sleep -Seconds $interval
            $waited += $interval
            $testDocker = docker info 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] Docker está listo!" -ForegroundColor Green
                $dockerRunning = $true
                break
            }
            Write-Host "    Esperando... ($waited segundos)" -ForegroundColor Gray
        }
        
        if (-not $dockerRunning) {
            Write-Host ""
            Write-Host "[!] Timeout: Docker Desktop no respondió en 2 minutos" -ForegroundColor Red
            Write-Host "    Verifica manualmente que Docker Desktop esté corriendo" -ForegroundColor Yellow
            exit 1
        }
    }
}

# Verificación final
Write-Host ""
Write-Host "[4/4] Verificación final..." -ForegroundColor Yellow
$finalCheck = docker ps 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[+] Docker está funcionando correctamente" -ForegroundColor Green
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Docker está listo para usar" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Puedes continuar con:" -ForegroundColor Yellow
    Write-Host "  docker compose build" -ForegroundColor White
    Write-Host "  docker compose up -d" -ForegroundColor White
    Write-Host ""
    exit 0
} else {
    Write-Host "[!] Error: Docker no responde correctamente" -ForegroundColor Red
    Write-Host "    Revisa SOLUCION_DOCKER.md para más ayuda" -ForegroundColor Yellow
    exit 1
}

