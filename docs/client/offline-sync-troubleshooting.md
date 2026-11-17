# Guia de Troubleshooting — Sincronização Offline (Cliente)

Referência para desenvolvedores de clientes (app mobile/desktop) consumindo o
contrato de sync offline. Pares de "sintoma → causa → ação".

## 422 Unprocessable Entity — "Idempotency key already used"

**Causa**: a tentativa anterior com esta `Idempotency-Key` **foi bem-sucedida** —
a operação já foi aplicada (a API consome a chave em resposta 2xx; 4xx/5xx a
liberam para retry).

**Ação**:
- **NUNCA faça retry automático com a mesma chave** — a operação já está aplicada.
- Cada operação de negócio nova recebe uma chave nova (UUID v4).
- Para retransmitir a MESMA operação após **falha de rede**, reenvie com a
  **mesma chave** — se a tentativa anterior não chegou a aplicar nada (nunca
  respondeu 2xx), a chave continua livre e a retentativa executa normalmente.

## 412 Precondition Failed — "Revision conflict... Current: N"

**Causa**: outro cliente (ou outro dispositivo) alterou o recurso depois que
você o leu; sua revisão está desatualizada.

**Ação** (único status com retry permitido — mas só depois do rebase):
1. Busque o recurso atualizado (re-read).
2. Reaplique a mudança do usuário sobre o estado novo (merge UX: diálogo
   "o registro foi alterado por outro usuário" é aceitável).
3. Reenvie a operação com o **novo** ETag/revisão.
4. **Nunca** retente 412 em loop sem re-fetch — vai conflitar de novo.

No `sync-batch`, o 412 não derruba o lote: ele aparece como
`outcome.status = "conflict"` com `"error": "Revision conflict... Current: N"`.
Processe os outcomes elemento a elemento.

Nos **endpoints individuais**, o 412 vem do `OptimisticRevisionMiddleware` com
corpo `{message, code: "revision-conflict", currentRevision: N}` — o ETag
corrente para o reenvio está no header `ETag` do `GET` do recurso. Fluxo
completo: `GET` → guarde o `ETag` do header → `PUT`/`POST` com
`If-Match: <etag>` → resposta 2xx traz o ETag **novo** (guarde para a próxima
edição). Sem `If-Match` a requisição ainda passa (flag Enforce desligada), mas
o ideal é sempre enviar.

> **Dois clientes, o mesmo ETag**: a reserva da revisão é **atômica** — quando
> duas mutações com o mesmo `If-Match` chegam juntas, **uma** é aplicada e a
> outra recebe 412. Ou seja: o 412 também pode chegar **sem** um GET
> intermediário do outro cliente (era o comportamento antes do CAS).
>
> **Falha do endpoint ≠ conflito**: se a mutação falhou (4xx/5xx) **depois** da
> verificação do `If-Match`, a API **desfaz** a reserva da revisão — o cliente
> pode reenviar com o **mesmo** ETag. Já em um 412 (conflito), a revisão
> avançou: reenviar com o ETag antigo vai conflitar de novo — faça o re-fetch.

## Outcome `rejected` no sync-batch

**Causa**: operação inválida — payload não-JSON, tipo de operação desconhecido
(só `CREATE`/`UPDATE`/`DELETE`), ETag mal-formado (`{rev}-1.0.0-{hash}`) ou
`DELETE` de entidade que o servidor não conhece.

**Ação**: corrija o problema e reenvie com **Idempotency-Key nova** (o lote
original foi parcialmente processado; o lote corrigido é uma nova requisição).

## Outcome `unchanged` no sync-batch

**Causa**: você reenviou um estado idêntico ao já armazenado no servidor
(replay offline comum após reconexão).

**Ação**: nenhuma — é sucesso sem efeito. Sincronize o estado local com o
`newETag` retornado e avance para as próximas operações pendentes.

## Relógio do dispositivo dessincronizado

**Sintoma**: timestamps locais divergentes dos logs do servidor; TTL da
Idempotency-Key calculado errado.

**Ação**:
- Leia `X-Server-Time` (Unix segundos) em **qualquer** resposta, ou
  `serverTimeUtc` no corpo de `GET /api/support/health`.
- Calcule o offset: `offset = serverTime - deviceTime` e ajuste os timestamps
  enviados nos metadados das operações.
- Recalcule o offset a cada sessão (NTP do dispositivo não é garantia).

## API indisponível / falha de rede durante o sync

**Ação**:
- Mantenha a fila de operações pendentes localmente **com as chaves originais**
  (não gere chaves novas a cada tentativa — isso quebra a idempotência).
- Retente ao reconectar com a **mesma chave**: se a tentativa anterior terminou
  em erro (4xx/5xx) ou nunca respondeu, a API liberou a chave e a retentativa
  executa; se a resposta 2xx foi perdida no caminho, a retentativa recebe 422 —
  a operação **já foi aplicada** no servidor, trate como sucesso e sincronize
  o estado local.
- Lote parcialmente processado (algum `rejected`): corrija e reenvie como lote
  novo com chave nova.

## Referência rápida de status

| Status | Significado | Retry automático? |
|--------|-------------|-------------------|
| 200 | Lote processado (veja `outcomes`) | — |
| 400 | Payload da requisição inválido | Não — corrigir |
| 412 | Revisão desatualizada | Só após re-fetch/rebase |
| 422 | Idempotency-Key reutilizada | **Nunca** |
| 5xx | Erro do servidor | Sim, com backoff, mesma chave |
