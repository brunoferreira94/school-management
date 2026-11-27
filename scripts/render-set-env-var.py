#!/usr/bin/env python3
"""Setter seguro de env var no Render.

O endpoint PUT /env-vars SUBSTITUI o conjunto inteiro e o GET pagina em 20.
Este script faz GET ?limit=100 -> merge de UMA chave -> PUT com todas as vars,
sem imprimir valores (segredos nunca vao para o chat nem para logs).

Uso:
  RENDER_API_KEY=... scripts/render-set-env-var.py \
      --service srv-xxxxxxxx --key Entitlement__Enforce --value true
"""

import argparse
import json
import os
import sys
import urllib.parse
import urllib.request

API = "https://api.render.com/v1"


def request(url: str, headers: dict, method: str = "GET", body: bytes | None = None):
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    with urllib.request.urlopen(req, timeout=45) as response:
        return json.load(response)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--service", required=True, help="ID do serviço no Render")
    parser.add_argument("--key", required=True, help="Nome da env var")
    parser.add_argument("--value", required=True, help="Valor da env var (não impresso)")
    parser.add_argument("--api-key-env", default="RENDER_API_KEY")
    args = parser.parse_args()

    token = os.environ.get(args.api_key_env)
    if not token:
        sys.exit(f"Chave {args.api_key_env} não encontrada no ambiente")

    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

    # GET paginado: 100 por página (o default é 20).
    all_vars: list[dict] = []
    cursor: str | None = None
    while True:
        url = f"{API}/services/{args.service}/env-vars?limit=100"
        if cursor:
            url += f"&cursor={urllib.parse.quote(cursor)}"
        page = request(url, headers)
        items = page if isinstance(page, list) else page.get("items", page.get("data", []))
        for item in items:
            all_vars.append(item.get("envVar", item))
        cursor = None if isinstance(page, list) else page.get("nextCursor")
        if not cursor:
            break

    print(f"GET ok: {len(all_vars)} env vars (chaves não exibidas)")

    found = False
    for entry in all_vars:
        if entry.get("key") == args.key:
            entry["value"] = args.value
            found = True
            break
    if not found:
        all_vars.append({"key": args.key, "value": args.value})

    # PUT recebe apenas pares key/value.
    payload = json.dumps(
        [{"key": e["key"], "value": e["value"]} for e in all_vars]
    ).encode("utf-8")
    result = request(
        f"{API}/services/{args.service}/env-vars",
        headers,
        method="PUT",
        body=payload,
    )
    updated = result if isinstance(result, list) else result.get("envVars", result.get("items", []))
    print(f"PUT ok: chave '{args.key}' {'atualizada' if found else 'adicionada'}; total {len(updated)} vars")


if __name__ == "__main__":
    main()
