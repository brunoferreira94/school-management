# Mediator Landscape 2026

Pesquisa baseada em fontes oficiais consultadas em 22/04/2026.

## Escopo

- MediatR
- Cortex.Mediator
- Wolverine
- LiteBus
- Concordia
- DispatchR
- ModernMediator

## Resumo Executivo

- MediatR tem evidência oficial de licenciamento comercial por chave.
- Wolverine, LiteBus e DispatchR têm boa aderência funcional ao cenário, mas a licença exata não ficou confirmada nas fontes oficiais recuperadas nesta coleta.
- Cortex.Mediator e ModernMediator não tiveram correspondência oficial inequívoca como bibliotecas .NET de mediator/CQRS.
- Concordia teve correspondência oficial, mas fora do universo .NET mediator/CQRS.

## Fontes oficiais principais

### Fontes - MediatR

- GitHub: [https://github.com/luckypennysoftware/mediatr](https://github.com/luckypennysoftware/mediatr)
- README: [https://github.com/luckypennysoftware/mediatr/blob/main/README.md](https://github.com/luckypennysoftware/mediatr/blob/main/README.md)
- Wiki: [https://github.com/luckypennysoftware/mediatr/wiki/Home](https://github.com/luckypennysoftware/mediatr/wiki/Home)
- License Key Configuration: [https://github.com/luckypennysoftware/mediatr/wiki/License-Key-Configuration](https://github.com/luckypennysoftware/mediatr/wiki/License-Key-Configuration)
- NuGet: [https://www.nuget.org/packages/MediatR](https://www.nuget.org/packages/MediatR)

### Fontes - Wolverine

- GitHub: [https://github.com/jasperfx/wolverine](https://github.com/jasperfx/wolverine)
- From MediatR: [https://github.com/jasperfx/wolverine/blob/main/docs/introduction/from-mediatr.md](https://github.com/jasperfx/wolverine/blob/main/docs/introduction/from-mediatr.md)
- Handlers: [https://github.com/jasperfx/wolverine/blob/main/docs/guide/handlers/index.md](https://github.com/jasperfx/wolverine/blob/main/docs/guide/handlers/index.md)
- Configuration: [https://github.com/jasperfx/wolverine/blob/main/docs/guide/configuration.md](https://github.com/jasperfx/wolverine/blob/main/docs/guide/configuration.md)
- NuGet: [https://www.nuget.org/packages/WolverineFx](https://www.nuget.org/packages/WolverineFx)

### Fontes - LiteBus

- GitHub: [https://github.com/litenova/litebus](https://github.com/litenova/litebus)
- Wiki Getting Started: [https://github.com/litenova/litebus/wiki/Getting-Started](https://github.com/litenova/litebus/wiki/Getting-Started)
- Cheat Sheet: [https://github.com/litenova/litebus/wiki/LiteBus-Cheat-Sheet](https://github.com/litenova/litebus/wiki/LiteBus-Cheat-Sheet)
- Migration Guide v4: [https://github.com/litenova/litebus/wiki/Migration-Guide-v4](https://github.com/litenova/litebus/wiki/Migration-Guide-v4)
- Commands DI: [https://www.nuget.org/packages/LiteBus.Commands.Extensions.Microsoft.DependencyInjection](https://www.nuget.org/packages/LiteBus.Commands.Extensions.Microsoft.DependencyInjection)
- Queries DI: [https://www.nuget.org/packages/LiteBus.Queries.Extensions.Microsoft.DependencyInjection](https://www.nuget.org/packages/LiteBus.Queries.Extensions.Microsoft.DependencyInjection)
- Events DI: [https://www.nuget.org/packages/LiteBus.Events.Extensions.Microsoft.DependencyInjection](https://www.nuget.org/packages/LiteBus.Events.Extensions.Microsoft.DependencyInjection)

### Fontes - DispatchR

- GitHub: [https://github.com/hasanxdev/dispatchr](https://github.com/hasanxdev/dispatchr)
- README: [https://github.com/hasanxdev/dispatchr/blob/main/README.md](https://github.com/hasanxdev/dispatchr/blob/main/README.md)
- NuGet: [https://www.nuget.org/packages/DispatchR.Mediator](https://www.nuget.org/packages/DispatchR.Mediator)
- NuGet Abstractions: [https://www.nuget.org/packages/DispatchR.Mediator.Abstractions](https://www.nuget.org/packages/DispatchR.Mediator.Abstractions)

### Fontes - Concordia

- GitHub: [https://github.com/google-deepmind/concordia](https://github.com/google-deepmind/concordia)
- PyPI: [https://pypi.org/project/gdm-concordia/](https://pypi.org/project/gdm-concordia/)

## Notas por biblioteca

### MediatR

- Licença/custo: existe commercial license key oficialmente documentada. Preço exato não confirmado nesta coleta.
- Manutenção: wiki e README ativos; guia de migração 11.x para 12.0 disponível.
- Aderência funcional: request/response, notifications, pipeline behaviors, DI ASP.NET Core.
- Migração incremental: alta.

### Wolverine

- Licença/custo: não confirmado nas fontes recuperadas.
- Manutenção: documentação ampla, inclusive guia de migração a partir de MediatR e integrações modernas.
- Aderência funcional: request/response, pub/sub, middleware, DI ASP.NET Core.
- Migração incremental: média a alta.

### LiteBus

- Licença/custo: não confirmado nas fontes recuperadas.
- Manutenção: wiki ativa, migration guide v4 e changelog/referências de linha 4.x.
- Aderência funcional: commands, queries, events, extensões DI, pre/post/error handlers.
- Migração incremental: alta.

### DispatchR

- Licença/custo: não confirmado nas fontes recuperadas.
- Manutenção: README atual com DI, notifications, stream handlers e pipeline behaviors.
- Aderência funcional: request/response, notifications, pipelines, DI ASP.NET Core.
- Migração incremental: alta.

### Cortex.Mediator

- Correspondência oficial: não confirmada.
- Risco principal: due diligence insuficiente para adoção enterprise.

### Concordia

- Correspondência oficial confirmada, mas é projeto Python da Google DeepMind e não mediator/CQRS para .NET.

### ModernMediator

- Correspondência oficial: não confirmada.
- Possível confusão com o projeto Mediator de Martin Othamar, mas isso não foi tratado como equivalência.
