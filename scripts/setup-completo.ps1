# Script de configuración completa del laboratorio
# Uso: .\scripts\setup-completo.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuración Completa - Laboratorio 5" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Paso 1: Verificar Docker
Write-Host "[1/5] Verificando Docker..." -ForegroundColor Yellow
$dockerVersion = docker --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] Error: Docker no está instalado o no está en el PATH" -ForegroundColor Red
    exit 1
}
Write-Host "    $dockerVersion" -ForegroundColor Green

# Paso 2: Construir imágenes
Write-Host ""
Write-Host "[2/5] Construyendo imágenes Docker..." -ForegroundColor Yellow
Write-Host "    Esto puede tardar varios minutos..." -ForegroundColor Gray
docker compose build

if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] Error al construir las imágenes" -ForegroundColor Red
    exit 1
}
Write-Host "[+] Imágenes construidas exitosamente" -ForegroundColor Green

# Paso 3: Iniciar contenedores
Write-Host ""
Write-Host "[3/5] Iniciando contenedores..." -ForegroundColor Yellow
docker compose up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] Error al iniciar los contenedores" -ForegroundColor Red
    exit 1
}

# Esperar a que los contenedores estén listos
Write-Host "    Esperando a que los contenedores estén listos..." -ForegroundColor Gray
Start-Sleep -Seconds 5

Write-Host "[+] Contenedores iniciados" -ForegroundColor Green

# Paso 4: Verificar estado
Write-Host ""
Write-Host "[4/5] Verificando estado de contenedores..." -ForegroundColor Yellow
docker compose ps

# Paso 5: Obtener IP del servidor
Write-Host ""
Write-Host "[5/5] Obteniendo información del servidor..." -ForegroundColor Yellow
$ip = docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' lab5-s1

if ($ip) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Configuración Completada" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Contenedores activos:" -ForegroundColor Yellow
    Write-Host "  - lab5-c1 (Ubuntu 16.10 - Cliente)" -ForegroundColor White
    Write-Host "  - lab5-c2 (Ubuntu 18.10 - Cliente)" -ForegroundColor White
    Write-Host "  - lab5-c3 (Ubuntu 20.10 - Cliente)" -ForegroundColor White
    Write-Host "  - lab5-s1 (Ubuntu 22.10 - Servidor)" -ForegroundColor White
    Write-Host ""
    Write-Host "IP del Servidor S1: $ip" -ForegroundColor Green
    Write-Host ""
    Write-Host "Próximos pasos:" -ForegroundColor Yellow
    Write-Host "  1. Crear directorio de capturas: New-Item -ItemType Directory -Force -Path ./captures" -ForegroundColor White
    Write-Host "  2. Capturar tráfico: .\scripts\capturar-trafico.ps1 -Cliente C1 -IP_S1 $ip" -ForegroundColor White
    Write-Host "  3. Ver guía completa: Get-Content GUIA_EJECUCION.md" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "[!] Advertencia: No se pudo obtener la IP del servidor" -ForegroundColor Yellow
    Write-Host "    Ejecuta: .\scripts\obtener-ip-s1.ps1" -ForegroundColor White
}

