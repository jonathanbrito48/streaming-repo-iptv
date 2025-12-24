#!/bin/bash

# Configurações
RAW_URL="https://raw.githubusercontent.com/Ramys/Iptv-Brasil-2025/refs/heads/master/VivoFibra.m3u8"
TEMP_FILE="external/original.m3u"
FINAL_FILE="external/My_list.m3u"
# Palavras-chave separadas por | (pipe) para o filtro
PALAVRAS_PROIBIDAS="Adultos|XXX|Porn|Sexy|18+|PLAYBOY|SEXTREME|SEX PRIVE|VENUS|Erotic|Adult|ADULTO"

# 1. Baixa o arquivo original
curl -sL "$RAW_URL" -o "$TEMP_FILE"

# 2. A Mágica: Remove a linha que contém a palavra E a linha subsequente (o link)
# Usamos o grep para identificar as linhas e o sed para remover o bloco
grep -Ei -B 1 "$PALAVRAS_PROIBIDAS" "$TEMP_FILE" | grep -v "^--" > demover.txt

# Mas uma forma mais robusta com AWK para garantir a integridade do M3U:
awk -v pattern="$PALAVRAS_PROIBIDAS" '
    BEGIN { IGNORECASE = 1 }
    /^#EXTINF/ { 
        header = $0; 
        if ($0 ~ pattern) { skip = 1; next } 
        else { skip = 0; print header; next }
    }
    { if (!skip) print }
' "$TEMP_FILE" > "$FINAL_FILE"

# 3. Limpeza
rm "$TEMP_FILE"