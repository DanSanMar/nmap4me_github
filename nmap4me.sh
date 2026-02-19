#!/usr/bin/env bash

export TERM=xterm-256color

# Colores (Cambiados a \033 para mayor compatibilidad)
BLANCO="\033[1;37m"
AZUL="\033[1;36m"
AMARILLO="\033[1;33m"
ROJO="\033[1;31m"
VERDE="\033[1;32m"
RESET="\033[0m"
CYAN="\033[1;36m"
MAGENTA="\033[1;35m"

# --- VARIABLE DE ESTADO XML ---
xml_status="OFF"

# --- FUNCIÓN LOGO ---
function mostrar_logo() {
    clear
    echo -e "${CYAN}"
    echo "      █████╗ ██╗      ██╗      ██╗  ██╗███╗   ███╗███████╗"
    echo "     ██╔══██╗██║      ██║      ██║  ██║████╗ ████║██╔════╝"
    echo -e "${VERDE}"
    echo "     ███████║██║      ██║      ███████║██╔████╔██║█████╗  "
    echo "     ██╔══██║██║      ██║      ╚════██║██║╚██╔╝██║██╔══╝  "
    echo -e "${MAGENTA}"
    echo "     ██║  ██║███████╗███████╗      ██║██║ ╚═╝ ██║███████╗"
    echo "     ╚═╝  ╚═╝╚══════╝╚══════╝      ╚═╝╚═╝     ╚═╝╚══════╝"
    echo ""
    echo -e "${BLANCO}              ░▒▓ N M A P  4  M E ▓▒░"
    echo -e "${AZUL}        ──[ Escaneo Interactivo de Red | v1.5 Web Recon ]──${RESET}"
    echo ""
}

function despedida() {
    echo -e "\n"
    echo -e "${AZUL}%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%${RESET}"
    echo -e "${BLANCO}     ¡Gracias por usar nmap4me! Bye!      ${RESET}"
    echo -e "${AZUL}%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%${RESET}"
    exit 0
}

trap despedida SIGINT
# Comprobación usuario root
if [[ $EUID -ne 0 ]]; then
   echo -e "${ROJO}❌ Este script debe ejecutarse con sudo.${RESET}" 
   echo -e "${AMARILLO}Ejemplo: sudo $0 10.10.10.1${RESET}"
   exit 1
fi

target=$1

if [ -z "$target" ]; then
    echo -e "${ROJO}❌ Error: debe introducir la IP o Dominio para empezar${RESET}"
    echo "Uso: ./nmap4me.sh <TARGET>"
    exit 1
fi

# Comprobando dependencias (Añadido whatweb)
dependencies=(fzf nmap whatweb)
for tool in "${dependencies[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo -e "${ROJO}❌ Error: '$tool' no está instalado.${RESET}"
        echo -e "${AMARILLO}💡 Instálalo con: sudo apt install $tool -y${RESET}"
        exit 1
    fi
done

# Comprobar si el objetivo es alcanzable (IP o Dominio)
echo ""
echo -e "${AZUL}🔍 Verificando conexión $target...Esto no debería llevar más de 3 segundos...${RESET}"
if ! host "$target" &>/dev/null && ! ping -c 1 -W 1 -q "$target" &>/dev/null; then
    echo -e "${ROJO}⚠️  Atención: No se puede resolver o no hay respuesta de '$target'.${RESET}"
    echo -e -n "${AMARILLO}¿Deseas continuar de todos modos? (s/n): ${RESET}"
    read confirm
    [[ "$confirm" != "s" ]] && exit 1
fi

echo -e "${VERDE}🔍 Comprobación de programas instalados: OK ✅${RESET}"
echo -e "${VERDE}🔍 Conectividad ping con host: OK ✅${RESET}"
echo -e "${VERDE}🔍 Comprobación usuario ROOT: OK ✅${RESET}"
echo -e "${VERDE}✅ Sistema listo! Empezando Auditoria 🚀${RESET}"

sleep 2

# BUCLE DEL MENÚ INTERACTIVO

while true; do
    mostrar_logo
    # Indicador visual del estado XML
    xml_color="${ROJO}"
    [[ "$xml_status" == "ON" ]] && xml_color="${VERDE}"
    echo -e "${VERDE}🎯 Objetivo actual: ${BLANCO}$target${RESET} | ${AZUL}XML: ${xml_color}[$xml_status]${RESET}\n"
    
    options=(
        "0. [TOGGLE] Guardar XML: $xml_status"
        "1. Reconocimiento Rápido (OS/Versión) | -sS -O -sV -Pn -T4"
        "2. Escaneo de Puertos Totales (p-)    | -sS -p- -Pn"
        "3. Enumeración de Servicios (sCV)     | -sSCV -Pn -p"
        "4. Escaneo de Vulnerabilidades (Vuln) | --script vuln -Pn -p"
        "5. UDP Discovery (Top 20 Puertos)     | -sU -Pn --top-ports 20 -T4"
        "6. UDP Investigación (Versiones)      | -sU -sV -Pn -p"
        "7. Web Recon (Nmap Scripts)           | NMAP_WEB_RECON"
        "8. Whatweb                            | whatweb"
        "9. SALIR                              | exit"
    )

    selection=$(printf "%s\n" "${options[@]}" | fzf --prompt="🔍 [Target: $target] Selecciona tu escaneo: " --height=15% --layout=reverse --border)

    if [ -z "$selection" ] || [[ "$selection" == *"SALIR"* ]]; then
        despedida
    fi

    # Lógica del conmutador XML
    if [[ "$selection" == *"TOGGLE"* ]]; then
        if [[ "$xml_status" == "OFF" ]]; then xml_status="ON"; else xml_status="OFF"; fi
        continue
    fi

    # Carpeta de logs común
    folder="Auditoria_$target"
    mkdir -p "$folder"
    # ARCHIVO ÚNICO DE REPORTE (TXT)
    reporte_txt="$folder/Auditoria_Completa_${target}.txt"

    # --- OPCIÓN 7: NMAP WEB RECON (NUEVA) ---
    if [[ "$selection" == *"Web Recon"* ]]; then
        echo -e "\n${AZUL}══════════════════════════════════════════════════${RESET}" | tee -a "$reporte_txt"
        echo -e "🕒 INICIO WEB RECON (Nmap): $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$reporte_txt"
        echo -e "🚀 OBJETIVO: $target (Puertos 80, 443)" | tee -a "$reporte_txt"
        echo -e "${AZUL}══════════════════════════════════════════════════${RESET}\n" | tee -a "$reporte_txt"

        if [[ "$xml_status" == "ON" ]]; then
            archivo_xml="$folder/web_recon_${target}_$(date +%H%M%S).xml"
            nmap -p 80,443 -Pn -sV --script http-enum,http-title,http-methods,http-server-header -oX "$archivo_xml" "$target" | tee -a "$reporte_txt"
            echo -e "\n${VERDE}🌐 XML guardado en: $archivo_xml${RESET}"
        else
            nmap -p 80,443 -Pn -sV --script http-enum,http-title,http-methods,http-server-header "$target" | tee -a "$reporte_txt"
        fi

        echo -e "\n${VERDE}✅ Resultados añadidos a: $reporte_txt${RESET}"
        echo ""
        read -n 1 -s -r -p "Pulsa cualquier tecla para volver al menú..."
        continue
    fi

    # --- OPCIÓN 8: WHATWEB (ANTIGUA) ---
    if [[ "$selection" == *"Whatweb"* ]]; then
        echo -e "\n${MAGENTA}══════════════════════════════════════════════════${RESET}" | tee -a "$reporte_txt"
        echo -e "🕒 INICIO WHATWEB: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$reporte_txt"
        echo -e "🚀 COMANDO: ${VERDE}whatweb -a 1 -t 1 -v --no-errors --open-timeout=5 --read-timeout=5 $target${RESET}" | tee -a "$reporte_txt"
        echo -e "${MAGENTA}══════════════════════════════════════════════════${RESET}\n" | tee -a "$reporte_txt"

        whatweb -a 1 -t 1 -v --no-errors --open-timeout=5 --read-timeout=5 "$target" | tee -a "$reporte_txt"
        
        echo -e "\n${VERDE}✅ Resultados en: $reporte_txt${RESET}"
        echo ""
        read -n 1 -s -r -p "Pulsa cualquier tecla para volver al menú..."
        continue
    fi

    # Extraer flags para Nmap (Opciones 1-6)
    # He corregido las comillas aquí para evitar errores de interpretación
    flags=$(echo "$selection" | awk -F "|" "{print \$2}" | xargs)

    # Lógica de puertos dinámicos
    if [[ "$flags" == *"-p" ]]; then
        echo -e -n "${AMARILLO}🔢 Introduce los puertos (ej: 80,443): ${RESET}"
        read -r ports
        if [ -z "$ports" ]; then
            echo -e "${ROJO}❌ Error: Para esta opción debes indicar puertos.${RESET}"
            sleep 1
            continue 
        fi
        flags="${flags} ${ports}"
    fi

    echo -e "\n${AZUL}══════════════════════════════════════════════════${RESET}" | tee -a "$reporte_txt"
    echo -e "🕒 INICIO NMAP: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$reporte_txt"
    echo -e "🚀 COMANDO: nmap $flags $target" | tee -a "$reporte_txt"
    echo -e "${AZUL}══════════════════════════════════════════════════${RESET}\n" | tee -a "$reporte_txt"

    # Lógica automatizada XML basada en el interruptor de la Opción 0
    if [[ "$xml_status" == "ON" ]]; then
        archivo_xml="$folder/nmap_${target}_$(date +%H%M%S).xml"
        nmap $flags -oX "$archivo_xml" "$target" | tee -a "$reporte_txt"
        echo -e "\n${VERDE}🌐 XML guardado en: $archivo_xml${RESET}"
    else
        nmap $flags "$target" | tee -a "$reporte_txt"
    fi
    
    echo -e "\n${VERDE}📄 Reporte guardado en: $reporte_txt${RESET}"
    echo -e "\n${AZUL}--------------------------------------------------${RESET}"
    echo -e "${VERDE}✅ Escaneo finalizado.${RESET}"
    echo ""
    read -n 1 -s -r -p "Pulsa cualquier tecla para volver al menú..."
done
