#!/bin/bash

# 1. Configurações
RAW_URL="LINK_DO_ARQUIVO_DO_REPO_X_AQUI"
EXTERNAL_DIR="external"
TEMP_FILE="$EXTERNAL_DIR/original.m3u"
FINAL_FILE="$EXTERNAL_DIR/My_list.m3u"
PALAVRAS_PROIBIDAS="Adultos|XXX|Porn|Sexy|18+|PLAYBOY|SEXTREME|SEX PRIVE|VENUS|Erotic|Adult|ADULTO"

# 2. GARANTIR QUE A PASTA EXISTE (O segredo para o erro sumir)
mkdir -p "$EXTERNAL_DIR"

echo "Iniciando download..."
# 3. Baixa o arquivo original
curl -sL "$RAW_URL" -o "$TEMP_FILE"

# Verifica se o download funcionou
if [ ! -f "$TEMP_FILE" ]; then
    echo "Erro: Falha ao baixar o arquivo original!"
    exit 1
fi

echo "Limpando a lista..."
# 4. A Mágica do AWK (Processamento robusto)
awk -v pattern="$PALAVRAS_PROIBIDAS" '
    BEGIN { IGNORECASE = 1 }
    /^#EXTINF/ { 
        header = $0; 
        if ($0 ~ pattern) { skip = 1; next } 
        else { skip = 0; print header; next }
    }
    { if (!skip) print }
' "$TEMP_FILE" > "$FINAL_FILE"

echo "Limpando arquivos temporários..."
# 5. Limpeza
rm "$TEMP_FILE"

echo "Sucesso! Arquivo gerado em $FINAL_FILE"