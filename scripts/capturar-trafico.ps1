# Script para capturar tráfico SSH entre clientes y servidor
# Uso: .\scripts\capturar-trafico.ps1 -Cliente C1 -IP_S1 172.18.0.2

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("C1","C2","C3","C4")]
    [string]$Cliente,
    
    [Parameter(Mandatory=$true)]
    [string]$IP_S1,
    
    [string]$OutputDir = "./captures"
)

$containerName = "lab5-$($Cliente.ToLower())"
$captureFile = "${Cliente.ToLower()}_traffic.pcap"
$capturePath = "/workspace/$captureFile"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Captura de Tráfico SSH: $Cliente -> S1" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Crear directorio de salida si no existe
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    Write-Host "[+] Directorio creado: $OutputDir" -ForegroundColor Green
}

# Verificar que los contenedores están corriendo
Write-Host "[*] Verificando contenedores..." -ForegroundColor Yellow
$s1Running = docker ps --format "{{.Names}}" | Select-String "lab5-s1"
$clientRunning = docker ps --format "{{.Names}}" | Select-String $containerName

if (-not $s1Running) {
    Write-Host "[!] Error: Contenedor lab5-s1 no está corriendo" -ForegroundColor Red
    Write-Host "    Ejecuta: docker compose up -d" -ForegroundColor Yellow
    exit 1
}

if (-not $clientRunning) {
    Write-Host "[!] Error: Contenedor $containerName no está corriendo" -ForegroundColor Red
    Write-Host "    Ejecuta: docker compose up -d" -ForegroundColor Yellow
    exit 1
}

Write-Host "[+] Contenedores verificados" -ForegroundColor Green

# Iniciar captura en el servidor
Write-Host "[*] Iniciando captura de tráfico en S1..." -ForegroundColor Yellow
docker exec -d lab5-s1 tcpdump -i any -w $capturePath 'tcp port 22' 2>&1 | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] Error al iniciar tcpdump" -ForegroundColor Red
    exit 1
}

Start-Sleep -Seconds 2
Write-Host "[+] Captura iniciada" -ForegroundColor Green

# Establecer conexión SSH
Write-Host "[*] Estableciendo conexión SSH desde $Cliente..." -ForegroundColor Yellow
Write-Host "    IP del servidor: $IP_S1" -ForegroundColor Gray
Write-Host "    Usuario: prueba" -ForegroundColor Gray
Write-Host "    Contraseña: prueba" -ForegroundColor Gray
Write-Host ""

if ($Cliente -eq "C4") {
    # C4 se conecta por loopback
    Write-Host "[*] C4 usa conexión loopback (localhost)" -ForegroundColor Yellow
    docker exec -it $containerName ssh -o StrictHostKeyChecking=no prueba@localhost
} else {
    docker exec -it $containerName ssh -o StrictHostKeyChecking=no prueba@$IP_S1
}

Write-Host ""
Write-Host "[*] Conexión cerrada" -ForegroundColor Yellow

# Esperar a que termine la captura
Write-Host "[*] Esperando finalización de captura..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Detener tcpdump
docker exec lab5-s1 pkill tcpdump 2>&1 | Out-Null
Start-Sleep -Seconds 2

# Copiar archivo al host
Write-Host "[*] Copiando archivo de captura..." -ForegroundColor Yellow
$outputFile = Join-Path $OutputDir $captureFile
docker cp "lab5-s1:$capturePath" $outputFile 2>&1 | Out-Null

if (Test-Path $outputFile) {
    $fileSize = (Get-Item $outputFile).Length
    Write-Host "[+] Captura completada: $outputFile ($([math]::Round($fileSize/1KB, 2)) KB)" -ForegroundColor Green
} else {
    Write-Host "[!] Error: No se pudo copiar el archivo de captura" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Captura finalizada exitosamente" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Abre el archivo en Wireshark: $outputFile" -ForegroundColor White
Write-Host "  2. Aplica el filtro: ssh" -ForegroundColor White
Write-Host "  3. Analiza los tamaños de paquetes SSH MSG KEXINIT" -ForegroundColor White

