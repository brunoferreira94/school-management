#!/bin/bash
# Validador simples de frontmatter OpenSpec (estilo YAML front-matter em markdown).
# Verifica:
#   1. Primeira linha exatamente "---"
#   2. Fechada por um segundo "---" (após a linha 1)
#   3. Ao menos uma linha de conteúdo (não vazia) entre eles
# Nota: este é um sanity-check local de estrutura. A validação de schema oficial
# é feita pela CLI: npx @fission-ai/openspec validate <change> --strict
# Corrige o bug da versão anterior: `grep -c ... || echo 0` emitia "0\n0" quando
# havia 0 matches (grep -c imprime "0" e sai com rc=1), quebrando o teste `[ -ne 2 ]`.

FILE="$1"

if [ -z "$FILE" ]; then
  echo "Usage: $0 <file.md>"
  exit 1
fi

if [ ! -f "$FILE" ]; then
  echo "ERROR: File not found: $FILE"
  exit 1
fi

L1=$(sed -n '1p' "$FILE")
if [ "$L1" != "---" ]; then
  echo "OK (sem frontmatter): $FILE"
  exit 0
fi

CLOSE=$(awk 'NR>1 && $0=="---"{print NR; exit}' "$FILE")
if [ -z "$CLOSE" ] || [ "$CLOSE" -lt 3 ]; then
  echo "ERROR: '---' de fechamento (com conteúdo entre os marcadores) não encontrado em $FILE"
  exit 1
fi

CONTENT=$(sed -n "2,$((CLOSE-1))p" "$FILE" | sed '/^[[:space:]]*$/d;/^[[:space:]]*#/d')
if [ -z "$CONTENT" ]; then
  echo "ERROR: frontmatter vazio em $FILE"
  exit 1
fi

echo "SUCCESS: frontmatter válido em $FILE"
exit 0
