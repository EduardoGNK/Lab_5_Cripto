# 🔐 Laboratorio 5 – Criptografía y Análisis de Tráfico SSH  
### Universidad Diego Portales — Criptografía Aplicada  
**Repositorio:** https://github.com/EduardoGNK/Lab_5_Cripto.git

---

## 📌 Descripción General

Este repositorio contiene el desarrollo completo del **Laboratorio 5 de Criptografía Aplicada**, cuyo objetivo es analizar el comportamiento del protocolo **SSH** durante su negociación inicial utilizando diferentes versiones de **OpenSSH** en contenedores Docker.

Durante el laboratorio se estudia:

- La estructura del handshake SSH antes del cifrado.
- Cómo el mensaje **SSH_MSG_KEXINIT** expone el fingerprint criptográfico del cliente.
- Identificación de clientes SSH mediante **HASSH**.
- Análisis comparativo entre versiones antiguas y modernas de OpenSSH.
- Replicación de tráfico de un “informante” para determinar la versión del cliente.
- Reducción del tamaño del KEXINIT mediante configuración mínima.
- Evaluación de qué propiedades de seguridad cumple realmente SSH.

---

## 🧩 Arquitectura del Laboratorio

Se emplean cuatro contenedores Docker:

```
C1 → Ubuntu 16.10  (OpenSSH 7.3p1)  
C2 → Ubuntu 18.10  (OpenSSH 8.3p1)  
C3 → Ubuntu 20.10  (OpenSSH 7.7p1)  
C4/S1 → Ubuntu 22.10 (OpenSSH 9.0p1 + SSH Server)
```

Cada cliente se conecta a S1 (que también actúa como C4), generando tráfico SSH real capturado con `tcpdump` para análisis en Wireshark.

---

## 📁 Estructura del Proyecto

La estructura real del repositorio es la siguiente:

```
Lab_5_Cripto/
│
├── captures/
│   ├── c1_verificacion_final.pcap
│   ├── c2_traffic_final.pcap
│   ├── c3_traffic_final.pcap
│   ├── c4_traffic_final.pcap
│   └── informante_replicado.pcap
│
├── docker/
│   ├── Dockerfile.c1
│   ├── Dockerfile.c2
│   ├── Dockerfile.c3
│   ├── Dockerfile.c4
│   └── sshd_config_minimal
│
├── scripts/
│   ├── bootstrap-ssh.sh
│   ├── capturar-trafico.ps1
│   ├── obtener-ip-s1.ps1
│   ├── setup-completo.ps1
│   └── verificar-docker.ps1
│
├── docker-compose.yml
│
└── README.md
```

---

## 🐳 Construcción de las Imágenes Docker

Cada cliente/servidor se construye ejecutando:

```bash
docker build -f docker/Dockerfile.c1 -t lab5-c1 .
docker build -f docker/Dockerfile.c2 -t lab5-c2 .
docker build -f docker/Dockerfile.c3 -t lab5-c3 .
docker build -f docker/Dockerfile.c4 -t lab5-s1 .
```

---

## ▶️ Ejecución del Ambiente con Docker Compose

Para crear toda la topología automáticamente:

```bash
docker compose up -d
```

Esto levanta los cuatro contenedores en la red `lab5-net` definida en `docker-compose.yml`.

---

## 📡 Captura de Tráfico SSH

Los scripts en `/scripts` automatizan la captura.

Ejemplo manual para C1:

```bash
docker exec -d lab5-s1 tcpdump -i any -w /workspace/c1_traffic.pcap 'tcp port 22'
docker exec -it lab5-c1 ssh -o StrictHostKeyChecking=no prueba@lab5-s1
```

Luego:

```bash
docker cp lab5-s1:/workspace/c1_traffic.pcap ./captures/c1_traffic_final.pcap
```

Este procedimiento se repite para C2, C3 y C4.

---

## 🔍 Análisis con Wireshark

Cada archivo `.pcap` contiene:

- Versiones SSH observadas:
  - C1 → OpenSSH 7.3p1  
  - C2 → OpenSSH 8.3p1  
  - C3 → OpenSSH 7.7p1  
  - C4/S1 → OpenSSH 9.0p1  
- Tamaños de:
  - `SSH_MSG_KEXINIT`
  - `SSH_MSG_KEXDH_INIT`
  - `SSH_MSG_KEXDH_REPLY`
  - `SSH_MSG_NEWKEYS`
- Algoritmos negociados en texto plano
- Fingerprint HASSH derivado de los algoritmos anunciados

Esto permite identificar con precisión las versiones del cliente sin necesidad de autenticación.

---

## 🔧 Configuración mínima del servidor (KEXINIT < 300 bytes)

El archivo `docker/sshd_config_minimal` reduce el KEXINIT a ~254 bytes usando:

```
KexAlgorithms curve25519-sha256@libssh.org
HostKeyAlgorithms ssh-ed25519
Ciphers chacha20-poly1305@openssh.com
MACs hmac-sha2-256
Compression no
```

Con esto se replica el requisito del laboratorio de reducir el tamaño del KEI.

---

## 📑 Scripts incluidos

Los scripts PowerShell automatizan tareas como:

- Levantar todo el laboratorio
- Obtener la IP del servidor
- Capturar tráfico automáticamente
- Verificar estado de contenedores

Ejemplo:

```bash
./scripts/capturar-trafico.ps1
```

---

## 🧠 Aprendizajes del Laboratorio

- El handshake SSH expone suficiente información para identificar versiones sin descifrar tráfico.
- El KEXINIT funciona como fingerprint criptográfico.
- OpenSSH ha ido endureciendo su superficie de negociación en versiones modernas.
- La configuración del servidor afecta directamente su fingerprint.
- SSH no garantiza anonimato ni no repudio.

---

## 📦 Requisitos

- Docker Desktop  
- PowerShell 7+ (para scripts .ps1)  
- Wireshark  
- Git  