# Lab 5 – Fingerprinting SSH con Docker

Este repositorio contiene un entorno reproducible para el laboratorio 5 de Criptografía. Se incluye un `docker-compose.yml` con cuatro contenedores (C1–C4/S1) que ejecutan distintas versiones de Ubuntu y del cliente OpenSSH, además del servidor `S1` con las credenciales solicitadas (`prueba` / `prueba`).

## 🚀 Inicio Rápido

### ⚠️ IMPORTANTE: Verificar Docker Primero

Antes de comenzar, asegúrate de que Docker Desktop está corriendo:

```powershell
# Verificar e iniciar Docker si es necesario
.\scripts\verificar-docker.ps1
```

Si obtienes errores de conexión, consulta `SOLUCION_DOCKER.md`.

### Opción 1: Script Automatizado (Recomendado)

```powershell
# Configuración completa automática
.\scripts\setup-completo.ps1
```

Este script:
- Verifica Docker
- Construye todas las imágenes
- Inicia los contenedores
- Muestra la IP del servidor

### Opción 2: Manual

1. **Construir las imágenes**
   ```powershell
   docker compose build
   ```

2. **Levantar el escenario**
   ```powershell
   docker compose up -d
   ```

3. **Obtener IP del servidor**
   ```powershell
   .\scripts\obtener-ip-s1.ps1
   # O manualmente:
   docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' lab5-s1
   ```

## 📡 Captura de Tráfico

### Usando Scripts (Recomendado)

```powershell
# Obtener IP primero
$ip = .\scripts\obtener-ip-s1.ps1

# Capturar tráfico de cada cliente
.\scripts\capturar-trafico.ps1 -Cliente C1 -IP_S1 $ip
.\scripts\capturar-trafico.ps1 -Cliente C2 -IP_S1 $ip
.\scripts\capturar-trafico.ps1 -Cliente C3 -IP_S1 $ip
.\scripts\capturar-trafico.ps1 -Cliente C4 -IP_S1 $ip
```

### Manual

1. **Abrir una sesión en un cliente** (ejemplo con C1):
   ```powershell
   docker exec -it lab5-c1 bash
   ```

2. **Conectarse al servidor S1**
   ```bash
   ssh prueba@<IP_S1>   # contraseña: prueba
   ```

3. **Capturar tráfico** desde otra terminal:
   ```powershell
   docker exec -d lab5-s1 tcpdump -i any -w /workspace/captura.pcap 'tcp port 22'
   # ... realizar conexión SSH ...
   docker exec lab5-s1 pkill tcpdump
   docker cp lab5-s1:/workspace/captura.pcap ./captures/
   ```

## 📚 Documentación

- **Guía Completa de Ejecución:** `GUIA_EJECUCION.md` - Paso a paso detallado de toda la actividad
- **Guía de Wireshark:** `GUIA_WIRESHARK.md` - **Cómo usar Wireshark para extraer datos del informe** ⭐
- **Informe Técnico:** `docs/informe_lab5.md` - Análisis completo según la rúbrica
- **Scripts de Automatización:** `scripts/` - Scripts PowerShell para facilitar la ejecución

## 📁 Estructura del Proyecto

```
Lab 5 cripto/
├── docker/              # Dockerfiles para cada contenedor
│   ├── Dockerfile.c1    # Ubuntu 16.10 - OpenSSH 7.3
│   ├── Dockerfile.c2    # Ubuntu 18.10 - OpenSSH 7.7
│   ├── Dockerfile.c3    # Ubuntu 20.10 - OpenSSH 8.3
│   └── Dockerfile.c4    # Ubuntu 22.10 - OpenSSH 9.0 (también S1)
├── scripts/             # Scripts de automatización
│   ├── bootstrap-ssh.sh        # Script de inicio del servidor SSH
│   ├── setup-completo.ps1      # Configuración automática
│   ├── capturar-trafico.ps1    # Captura automatizada de tráfico
│   └── obtener-ip-s1.ps1        # Obtener IP del servidor
├── docs/                # Documentación
│   └── informe_lab5.md  # Informe técnico completo
├── captures/            # Archivos .pcap generados (crear manualmente)
├── docker-compose.yml   # Orquestación de contenedores
├── README.md            # Este archivo
└── GUIA_EJECUCION.md    # Guía paso a paso detallada
```

## 🔧 Comandos Útiles

```powershell
# Ver estado de contenedores
docker compose ps

# Ver logs del servidor
docker compose logs s1

# Reiniciar contenedores
docker compose restart

# Detener todo
docker compose down

# Limpiar todo (eliminar contenedores e imágenes)
docker compose down --rmi local
```

## ⚠️ Notas Importantes

- Las capturas se guardan en `./captures/` (crear el directorio si no existe)
- El servidor S1 expone el puerto 22 internamente y 2222 en el host
- Las credenciales son: usuario `prueba`, contraseña `prueba`
- El servidor está configurado con algoritmos mínimos para cumplir KEI < 300 bytes

## 🐛 Problemas Comunes

Si encuentras errores durante la ejecución:

1. **Error de repositorios Ubuntu 404:** Los Dockerfiles ya están configurados para usar `old-releases`. Ver `PROBLEMAS_COMUNES.md`
2. **Error de política de PowerShell:** Ejecuta `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process`. Ver `SOLUCION_POWERSHELL.md`
3. **Docker Desktop no responde:** Inicia Docker Desktop manualmente. Ver `SOLUCION_DOCKER.md`
4. **KEXINIT del servidor > 300 bytes:** Reconstruye el servidor con `docker compose build s1`. Ver `SOLUCION_KEI_300_BYTES.md`

**Ver todos los problemas comunes en:** `PROBLEMAS_COMUNES.md`

## 📖 Para más detalles

- **Guía de Ejecución Completa:** Ver `GUIA_EJECUCION.md`
- **Análisis Técnico:** Ver `docs/informe_lab5.md`

