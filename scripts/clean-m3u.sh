#!/bin/bash

# 1. Configurações
# Usando a URL otimizada
RAW_URL="https://raw.githubusercontent.com/Ramys/Iptv-Brasil-2026/refs/heads/master/CanaisBR%20-%20Completo.m3u8"
EXTERNAL_DIR="external"
TEMP_FILE="$EXTERNAL_DIR/original.m3u8"
FINAL_FILE="$EXTERNAL_DIR/My_list.m3u8"

# Lista de bloqueio (ajuste conforme necessário)
PALAVRAS_PROIBIDAS="Adultos|XXX|Porn|Sexy|18+|PLAYBOY|SEXTREME|SEX PRIVE|VENUS|Erotic|Adult|ADULTO"

# 2. Garantir infraestrutura
mkdir -p "$EXTERNAL_DIR"

echo "Iniciando download de: $RAW_URL"

# 3. Download com headers de User-Agent (alguns servidores bloqueiam curl puro)
curl -f -sL -A "Mozilla/5.0" "$RAW_URL" -o "$TEMP_FILE"

# Verificação de integridade
if [ ! -s "$TEMP_FILE" ]; then
    echo "ERRO: Arquivo baixado está vazio ou não foi encontrado!"
    exit 1
fi

echo "Limpando a lista... Removendo termos: $PALAVRAS_PROIBIDAS"

# 4. Processamento AWK
# Esta lógica remove o par: a linha do #EXTINF que contém o termo e a linha do link logo abaixo
awk -v pattern="$PALAVRAS_PROIBIDAS" '
    BEGIN { IGNORECASE = 1 }
    /^#EXTINF/ { 
        if ($0 ~ pattern) { skip = 1; next } 
        else { skip = 0; print; next }
    }
    { if (!skip) print }
' "$TEMP_FILE" > "$FINAL_FILE"

# 5. Limpeza final
rm "$TEMP_FILE"
echo "Sucesso! Lista gerada em $FINAL_FILE"
