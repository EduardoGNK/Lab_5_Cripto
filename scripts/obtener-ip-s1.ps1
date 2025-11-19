# Script para obtener la IP del servidor S1
# Uso: .\scripts\obtener-ip-s1.ps1

Write-Host "Obteniendo IP del servidor S1..." -ForegroundColor Yellow

$s1Running = docker ps --format "{{.Names}}" | Select-String "lab5-s1"

if (-not $s1Running) {
    Write-Host "[!] Error: Contenedor lab5-s1 no está corriendo" -ForegroundColor Red
    Write-Host "    Ejecuta: docker compose up -d" -ForegroundColor Yellow
    exit 1
}

# Obtener IP usando docker inspect
$ip = docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' lab5-s1

if ($ip) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "IP del Servidor S1: $ip" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usa esta IP en los comandos SSH:" -ForegroundColor Yellow
    Write-Host "  ssh prueba@$ip" -ForegroundColor White
    Write-Host ""
    
    # Copiar al portapapeles si está disponible
    try {
        $ip | Set-Clipboard
        Write-Host "[+] IP copiada al portapapeles" -ForegroundColor Green
    } catch {
        # Ignorar si no se puede copiar
    }
    
    return $ip
} else {
    Write-Host "[!] Error: No se pudo obtener la IP" -ForegroundColor Red
    exit 1
}

