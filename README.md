🔎 NMAP4ME
░▒▓ N M A P  4  M E ▓▒░
──[ Escaneo Interactivo de Red | v1.2 whatweb ]──


nmap4me.sh es un script en Bash que automatiza y facilita auditorías de red usando

Nmap

WhatWeb

fzf

Proporciona un menú interactivo, generación automática de logs en .txt y .xml, verificación de dependencias y comprobación de conectividad antes de iniciar el escaneo.

🚀 Características

✅ Verificación automática de dependencias

✅ Comprobación de usuario ROOT

✅ Validación de conectividad (host/ping)

✅ Menú interactivo con fzf

✅ Escaneos rápidos y avanzados

✅ Soporte para escaneo UDP

✅ Integración con WhatWeb

✅ Guardado automático de resultados en TXT y XML

✅ Organización automática por carpetas

📦 Requisitos

El script necesita:

nmap

whatweb

fzf

host

ping

sudo (ejecución como root)

Instalación rápida en sistemas Debian/Ubuntu:

sudo apt update
sudo apt install nmap whatweb fzf -y

⚙️ Instalación
git clone https://github.com/DanSanMar/nmap4me.git
cd nmap4me
chmod +x nmap4me.sh

🖥️ Uso

El script debe ejecutarse como root:

sudo ./nmap4me.sh <TARGET>


Ejemplo:

sudo ./nmap4me.sh 10.10.10.1
sudo ./nmap4me.sh ejemplo.com

📋 Opciones del Menú

El menú interactivo permite seleccionar distintos tipos de escaneo:

1️⃣ Reconocimiento Rápido
-sS -O -sV -Pn -T4


Escaneo SYN

Detección de sistema operativo

Detección de versiones

Sin ping previo

Timing agresivo

2️⃣ Escaneo de Todos los Puertos
-sS -p- -Pn


Escanea los 65535 puertos TCP.

3️⃣ Enumeración de Servicios
-sSCV -Pn -p <PUERTOS>


Scripts por defecto

Detección de versiones

Puertos definidos por el usuario

Ejemplo:

80,443,22

4️⃣ Escaneo de Vulnerabilidades
--script vuln -Pn -p <PUERTOS>


Ejecuta scripts NSE de vulnerabilidades en puertos específicos.

5️⃣ UDP Discovery (Top 20)
-sU -Pn --top-ports 20 -T4


Descubre los 20 puertos UDP más comunes.

6️⃣ UDP Investigación (Versiones)
-sU -sV -Pn -p <PUERTOS>


Escaneo UDP detallado con detección de versión.

7️⃣ WhatWeb

Ejecuta:

whatweb <TARGET>


Ideal para identificar:

CMS

Frameworks

Tecnologías web

Versiones expuestas

8️⃣ Salir

Cierra el script de forma segura.

📂 Estructura de Resultados

Cada ejecución crea automáticamente una carpeta:

Auditoria_<TARGET>/


Dentro se generan:

nmap_<TARGET>_YYYY-MM-DD.txt
nmap_<TARGET>_YYYY-MM-DD.xml
whatweb_<TARGET>_YYYY-MM-DD.txt


📄 .txt → Salida legible

🌐 .xml → Para importar en herramientas como:

Metasploit

Faraday

🛡️ Flujo de Seguridad

Antes de iniciar la auditoría el script:

Verifica que se ejecuta como root

Comprueba dependencias

Verifica conectividad con el objetivo

Solicita confirmación si el host no responde

🎯 Casos de Uso

🔍 Reconocimiento en CTFs

🛡️ Auditorías internas de red

🌐 Enumeración inicial en pentesting

📊 Generación rápida de reportes base

🔎 Descubrimiento de tecnologías web

⚠️ Advertencia Legal

Este script está destinado únicamente para:

Entornos de laboratorio

CTFs

Auditorías autorizadas

El uso contra sistemas sin permiso puede ser ilegal. El autor no se hace responsable del mal uso.

👨‍💻 Autor

Proyecto creado para facilitar auditorías rápidas con una interfaz cómoda en terminal.

Si te gusta el proyecto ⭐ ¡dale una estrella en GitHub!