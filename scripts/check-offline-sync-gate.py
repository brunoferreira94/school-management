#!/usr/bin/env python3
"""Verificação do gate de adesão do contrato de sincronização offline (Bloco 5).

Uso:
  scripts/check-offline-sync-gate.py --env staging
  scripts/check-offline-sync-gate.py --env staging --window 24h
  scripts/check-offline-sync-gate.py --env staging --snapshot /tmp/base.json
  scripts/check-offline-sync-gate.py --env staging --baseline /tmp/base.json

Modos:
  (padrão)     lê as queries do gate na janela e mostra o veredito
  --snapshot   grava os contadores cumulativos em JSON (para usar como base)
  --baseline   compara com um snapshot anterior e julga os DELTAS da janela

Regras (docs/runbooks/offline-sync-rollout.md §Checkpoint):
  1) missing_key (batch) < 1%   — série ausente = 0 missing (passa)
  2) revision_missing < 1%       — série ausente = 0 missing (passa)
  3) adesão por rota ≥ 99%       — "provided" sobre o total da rota
  4) nenhum alerta "firing"
  5) conflitos < 1% do total     (verificação pós-ligação)

Variáveis:
  PROMETHEUS_URL (default: http://127.0.0.1:9090)
"""
from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request

PROMETHEUS_URL = os.environ.get("PROMETHEUS_URL", "http://127.0.0.1:9090")

# Contadores cumulativos lidos no snapshot (rótulo → valor).
COUNTERS = {
    "idempotency_key_missing": ["source"],
    "idempotency_key_provided": ["source"],
    "idempotency_key_reused": [],
    "revision_missing": [],
    "revision_adherence": ["route", "state"],
    "offline_sync_total": [],
    "offline_sync_success": [],
    "offline_sync_conflicts": [],
}


def query(promql: str):
    url = f"{PROMETHEUS_URL}/api/v1/query?" + urllib.parse.urlencode({"query": promql})
    try:
        with urllib.request.urlopen(url, timeout=30) as resp:
            payload = json.load(resp)
    except (urllib.error.URLError, TimeoutError) as exc:
        raise SystemExit(f"Prometheus indisponível em {PROMETHEUS_URL}: {exc}")
    return payload.get("data", {}).get("result", [])


def label_key(metric: dict, labels: list[str]) -> str:
    return "|".join(f"{name}={metric.get(name, '')}" for name in labels)


def snapshot(environment: str) -> dict:
    """Lê os contadores cumulativos do ambiente."""
    data = {"environment": environment, "counters": {}, "alerts": 0}
    for name, labels in COUNTERS.items():
        rows = query(f'{name}{{environment="{environment}"}}')
        for row in rows:
            metric = row.get("metric", {})
            key = label_key(metric, labels)
            try:
                value = float(row["value"][1])
            except (TypeError, ValueError):
                continue
            data["counters"][f"{name}[{key}]"] = value
    data["alerts"] = len(query(f'ALERTS{{alertstate="firing", environment="{environment}"}}'))
    return data


def delta(base: dict, now: dict) -> dict:
    """Diferença entre dois snapshots (só deltas positivos contam)."""
    out = {}
    for key, value in now.get("counters", {}).items():
        previous = float(base.get("counters", {}).get(key, 0.0))
        diff = value - previous
        if diff < 0:  # reset de contador (deploy) — ignora
            diff = 0.0
        out[key] = diff
    return out


def counter(delta_map: dict, name: str, **labels) -> float:
    """Soma os deltas de um contador que casam com os rótulos informados."""
    total = 0.0
    for key, value in delta_map.items():
        if not key.startswith(name + "["):
            continue
        inner = key[len(name) + 1 : -1]
        pairs = dict(part.split("=", 1) for part in inner.split("|") if part)
        if all(pairs.get(k) == v for k, v in labels.items()):
            total += value
    return total


def pct(numerator: float, denominator: float):
    if denominator <= 0:
        return None
    return numerator / denominator


def report_window(environment: str, window: str) -> int:
    print(f"== gate offline-sync | environment={environment} | janela={window}")
    print()

    missing = query(
        f'sum(rate(idempotency_key_missing{{environment="{environment}", source="batch"}}[{window}]))'
        f' / (sum(rate(idempotency_key_missing{{environment="{environment}", source="batch"}}[{window}]))'
        f' + sum(rate(idempotency_key_provided{{environment="{environment}", source="batch"}}[{window}])))'
    )
    revision = query(
        f'sum(rate(revision_missing{{environment="{environment}"}}[{window}]))'
        f' / sum(rate(offline_sync_total{{environment="{environment}"}}[{window}]))'
    )
    adherence = query(
        f'sum by (route) (rate(revision_adherence{{state="provided", environment="{environment}"}}[{window}]))'
        f' / sum by (route) (rate(revision_adherence{{environment="{environment}"}}[{window}]))'
    )
    conflicts = query(
        f'sum(rate(offline_sync_conflicts{{environment="{environment}"}}[{window}]))'
        f' / sum(rate(offline_sync_total{{environment="{environment}"}}[{window}]))'
    )
    alerts = query(f'ALERTS{{alertstate="firing", environment="{environment}"}}')

    def value_of(rows):
        return float(rows[0]["value"][1]) if rows else None

    missing_ratio = value_of(missing)
    revision_ratio = value_of(revision)
    conflict_ratio = value_of(conflicts)

    def show(label, ratio, threshold=0.01):
        if ratio is None:
            print(f"  ✓ {label}: sem eventos na janela (0%)")
            return True
        if ratio != ratio:  # NaN
            print(f"  ✓ {label}: sem tráfego na janela")
            return True
        ok = ratio < threshold
        print(f"  {'✓' if ok else '✗'} {label}: {ratio * 100:.3f}% (limite {threshold * 100:.0f}%)")
        return ok

    results = [
        show("missing_key (batch)", missing_ratio),
        show("revision_missing", revision_ratio),
        show("conflitos/total", conflict_ratio),
    ]

    print("  adesão por rota:")
    if not adherence:
        print("    - (sem tráfego medido na janela)")
    for row in adherence:
        route = row["metric"].get("route", "?")
        ratio = float(row["value"][1])
        if ratio != ratio:
            print(f"    - {route}: sem tráfego na janela")
            continue
        ok = ratio >= 0.99
        results.append(ok)
        print(f"    {'✓' if ok else '✗'} {route}: {ratio * 100:.2f}% provided")

    firing = len(alerts)
    results.append(firing == 0)
    print(f"  {'✓' if firing == 0 else '✗'} alertas firing: {firing}")

    print()
    print("Nota: contadores cumulativos — as sondas do próprio gate (400/428) ficam")
    print("gravadas como 'missing'. Use --baseline para medir o delta da janela.")
    return 0 if all(results) else 1


def report_delta(environment: str, base: dict, now: dict) -> int:
    diff = delta(base, now)
    print(f"== gate offline-sync | DELTA da janela | environment={environment}")
    print(f"   base: {base.get('counters') and 'snapshot carregado' or 'snapshot vazio'}")
    print()

    missing_batch = counter(diff, "idempotency_key_missing", source="batch")
    provided_batch = counter(diff, "idempotency_key_provided", source="batch")
    revision_missing = counter(diff, "revision_missing")
    total = counter(diff, "offline_sync_total")
    conflicts = counter(diff, "offline_sync_conflicts")
    success = counter(diff, "offline_sync_success")

    results = []
    ratio = pct(missing_batch, missing_batch + provided_batch)
    ok = missing_batch == 0 or (ratio is not None and ratio < 0.01)
    results.append(ok)
    print(f"  {'✓' if ok else '✗'} missing_key (batch): Δmissing={missing_batch:.0f} "
          f"Δprovided={provided_batch:.0f}" + (f" ({ratio * 100:.3f}%)" if ratio is not None else ""))

    ratio = pct(revision_missing, total)
    ok = revision_missing == 0 or (ratio is not None and ratio < 0.01)
    results.append(ok)
    print(f"  {'✓' if ok else '✗'} revision_missing: Δ={revision_missing:.0f} de Δtotal={total:.0f}"
          + (f" ({ratio * 100:.3f}%)" if ratio is not None else ""))

    ratio = pct(conflicts, total)
    ok = conflicts == 0 or (ratio is not None and ratio < 0.01)
    results.append(ok)
    print(f"  {'✓' if ok else '✗'} conflitos: Δ={conflicts:.0f} de Δtotal={total:.0f}"
          + (f" ({ratio * 100:.3f}%)" if ratio is not None else ""))

    routes = sorted({key.split("route=", 1)[1].split("|")[0]
                     for key in diff if key.startswith("revision_adherence[")})
    if not routes:
        print("  - adesão por rota: sem tráfego de UI na janela (nenhum PUT medido)")
    for route in routes:
        provided = counter(diff, "revision_adherence", route=route, state="provided")
        missing = counter(diff, "revision_adherence", route=route, state="missing")
        wildcard = counter(diff, "revision_adherence", route=route, state="wildcard")
        ratio = pct(provided, provided + missing + wildcard)
        if ratio is None:
            print(f"  - {route}: sem tráfego na janela")
            continue
        ok = ratio >= 0.99 and wildcard == 0
        results.append(ok)
        print(f"  {'✓' if ok else '✗'} {route}: {ratio * 100:.2f}% provided "
              f"(Δprovided={provided:.0f} Δmissing={missing:.0f} Δwildcard={wildcard:.0f})")

    firing = int(now.get("alerts", 0)) - int(base.get("alerts", 0))
    results.append(firing <= 0)
    print(f"  {'✓' if firing <= 0 else '✗'} alertas firing novos: {firing}")

    print()
    print(f"  totais da janela: {total:.0f} ops | {success:.0f} applied/success")
    return 0 if all(results) else 1


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--env", default="staging", choices=["staging", "production"])
    parser.add_argument("--window", default="1h", help="janela do Prometheus (ex.: 1h, 24h)")
    parser.add_argument("--snapshot", metavar="PATH", help="grava um snapshot dos contadores")
    parser.add_argument("--baseline", metavar="PATH", help="compara com um snapshot anterior")
    args = parser.parse_args()

    if args.snapshot:
        data = snapshot(args.env)
        with open(args.snapshot, "w", encoding="utf-8") as fh:
            json.dump(data, fh, indent=2, ensure_ascii=False)
        print(f"snapshot gravado em {args.snapshot} ({len(data['counters'])} séries)")
        return 0

    if args.baseline:
        with open(args.baseline, encoding="utf-8") as fh:
            base = json.load(fh)
        now = snapshot(args.env)
        return report_delta(args.env, base, now)

    return report_window(args.env, args.window)


if __name__ == "__main__":
    sys.exit(main())
