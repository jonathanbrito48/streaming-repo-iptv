#!/bin/bash

# 1. Configurações
# Usando a URL otimizada
RAW_URL="https://raw.githubusercontent.com/Ramys/Iptv-Brasil-2025/master/VivoFibra.m3u8"
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

# 4. Processamento AWK Otimizado
awk -v pattern="$PALAVRAS_PROIBIDAS" '
    BEGIN { IGNORECASE = 1 }
    # Se a linha for metadado de canal
    /^#EXTINF/ { 
        if ($0 ~ pattern) { skip = 1; next } 
        else { skip = 0; print; next }
    }
    # Se a linha for qualquer outra tag (ex: #EXTM3U)
    /^#/ { 
        if (!skip) print; next 
    }
    # Se a linha for a URL e não estivermos em modo "skip"
    { 
        if (!skip) {
            # Remove espaços em branco e anexa .ts
            sub(/[[:space:]]+$/, "", $0)
            print $0 ".ts"
        }
    }
' "$TEMP_FILE" > "$FINAL_FILE"

rm "$TEMP_FILE"
echo "Sucesso! Lista gerada em $FINAL_FILE"
